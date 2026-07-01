import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/network/endpoints.dart';
import '../models/booking.dart';
import 'core_providers.dart';

enum BookingFilter { upcoming, active, past }

class BookingsRepository {
  BookingsRepository(this._api);

  final ApiClient _api;

  Future<List<Booking>> list() async {
    final response = await _api.get(Endpoints.bookings);
    final list = _bookingListFromResponse(response);
    list.sort((a, b) {
      final aTime = a.pickupAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.pickupAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return List.unmodifiable(list);
  }

  Future<Booking> get(int id) async {
    final response = await _api.get(Endpoints.booking(id));
    return _bookingFromResponse(response);
  }

  Future<Booking> create(BookingDraft draft) async {
    final response = await _api.post(Endpoints.bookings, data: draft.toJson());
    return _bookingFromResponse(response);
  }

  Future<PriceEstimate> estimate(BookingDraft draft) async {
    final response = await _api.post(
      Endpoints.priceEstimate,
      data: draft.toJson(),
    );
    return _estimateFromResponse(response);
  }

  Future<Booking> cancel(int id) async {
    final response = await _api.post(Endpoints.cancelBooking(id));
    final json = _bookingJson(response);
    if (json == null) return get(id);
    return Booking.fromJson(json);
  }
}

final bookingsRepositoryProvider = Provider<BookingsRepository>((ref) {
  return BookingsRepository(ref.watch(apiClientProvider));
});

final allBookingsProvider = FutureProvider.autoDispose<List<Booking>>((ref) {
  return ref.watch(bookingsRepositoryProvider).list();
});

final bookingDetailProvider = FutureProvider.autoDispose.family<Booking, int>((
  ref,
  id,
) {
  return ref.watch(bookingsRepositoryProvider).get(id);
});

final filteredBookingsProvider = Provider.autoDispose
    .family<AsyncValue<List<Booking>>, BookingFilter>((ref, filter) {
      final bookings = ref.watch(allBookingsProvider);
      return bookings.whenData((list) {
        return list.where((booking) {
          switch (filter) {
            case BookingFilter.upcoming:
              return booking.status.isUpcoming && !booking.status.isActive;
            case BookingFilter.active:
              return booking.status.isActive;
            case BookingFilter.past:
              return booking.status.isTerminal;
          }
        }).toList();
      });
    });

List<Booking> _bookingListFromResponse(dynamic response) {
  final items = _listPayload(response);
  if (items == null) {
    throw ApiException('Invalid bookings response from the server.');
  }
  return items.map((item) {
    if (item is! Map) {
      throw ApiException('Invalid booking item received from the server.');
    }
    return Booking.fromJson(_stringMap(item));
  }).toList();
}

Booking _bookingFromResponse(dynamic response) {
  final json = _bookingJson(response);
  if (json == null) {
    throw ApiException('Invalid booking response from the server.');
  }
  return Booking.fromJson(json);
}

PriceEstimate _estimateFromResponse(dynamic response) {
  final json = _estimateJson(response);
  if (json == null) {
    throw ApiException('Pricing is unavailable for this ride.');
  }
  return PriceEstimate.fromJson(json);
}

List<dynamic>? _listPayload(dynamic value) {
  if (value is List) return value;
  if (value is! Map) return null;
  final map = _stringMap(value);
  for (final key in const ['data', 'bookings', 'items']) {
    final list = _listPayload(map[key]);
    if (list != null) return list;
  }
  return null;
}

Map<String, dynamic>? _bookingJson(dynamic value) {
  if (value is! Map) return null;
  final map = _stringMap(value);
  if (map.containsKey('id')) return map;
  for (final key in const ['booking', 'data']) {
    final booking = _bookingJson(map[key]);
    if (booking != null) return booking;
  }
  return null;
}

Map<String, dynamic>? _estimateJson(dynamic value) {
  if (value is! Map) return null;
  final map = _stringMap(value);
  if (map.containsKey('total') ||
      map.containsKey('estimated_total') ||
      map.containsKey('price')) {
    return map;
  }
  for (final key in const ['estimate', 'data', 'pricing']) {
    final estimate = _estimateJson(map[key]);
    if (estimate != null) return estimate;
  }
  return null;
}

Map<String, dynamic> _stringMap(Map<dynamic, dynamic> map) {
  return map.map((key, value) => MapEntry('$key', value));
}
