import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/network/api_exception.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/booking.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bookings_provider.dart';

class CreateBookingScreen extends ConsumerStatefulWidget {
  const CreateBookingScreen({super.key});

  @override
  ConsumerState<CreateBookingScreen> createState() =>
      _CreateBookingScreenState();
}

class _CreateBookingScreenState extends ConsumerState<CreateBookingScreen> {
  static const _vehicleClasses = {
    'sedan': 'Luxury sedan',
    'suv': 'Executive SUV',
    'sprinter': 'Sprinter van',
    'limousine': 'Stretch limousine',
  };

  final _formKey = GlobalKey<FormState>();
  final _pickup = TextEditingController();
  final _dropoff = TextEditingController();
  final _hours = TextEditingController();
  final _passengers = TextEditingController(text: '1');
  final _notes = TextEditingController();
  final _phone = TextEditingController();

  DateTime _pickupAt = DateTime.now().add(const Duration(hours: 2));
  String _vehicleClass = 'sedan';
  PriceEstimate? _estimate;
  bool _estimating = false;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    final phone = ref.read(authControllerProvider).customer?.phone;
    if (phone != null) _phone.text = phone;
  }

  @override
  void dispose() {
    _pickup.dispose();
    _dropoff.dispose();
    _hours.dispose();
    _passengers.dispose();
    _notes.dispose();
    _phone.dispose();
    super.dispose();
  }

  BookingDraft? _draft() {
    if (!_formKey.currentState!.validate()) return null;
    return BookingDraft(
      pickupLocation: _pickup.text.trim(),
      dropoffLocation: _dropoff.text.trim(),
      pickupAt: _pickupAt,
      vehicleClass: _vehicleClass,
      contactPhone: _phone.text.trim(),
      hours: _hours.text.trim().isEmpty
          ? null
          : num.tryParse(_hours.text.trim()),
      passengerCount: _passengers.text.trim().isEmpty
          ? null
          : int.tryParse(_passengers.text.trim()),
      notes: _notes.text.trim(),
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _pickupAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_pickupAt),
    );
    if (time == null) return;

    setState(() {
      _pickupAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      _estimate = null;
    });
  }

  Future<void> _estimatePrice() async {
    final draft = _draft();
    if (draft == null) return;
    setState(() => _estimating = true);
    try {
      final estimate = await ref
          .read(bookingsRepositoryProvider)
          .estimate(draft);
      if (mounted) setState(() => _estimate = estimate);
    } catch (error) {
      if (!mounted) return;
      final message =
          error is ApiException &&
              (error.statusCode == 404 || error.statusCode == 405)
          ? 'Estimated pricing is unavailable right now. You can still confirm the booking.'
          : '$error';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _estimating = false);
    }
  }

  Future<void> _create() async {
    final draft = _draft();
    if (draft == null) return;
    setState(() => _creating = true);
    try {
      final booking = await ref.read(bookingsRepositoryProvider).create(draft);
      ref.invalidate(allBookingsProvider);
      if (mounted) context.go(Routes.booking(booking.id));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$error')));
      }
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM d, h:mm a');
    final currency = NumberFormat.simpleCurrency(
      name: _estimate?.currency ?? 'USD',
    );
    return Scaffold(
      appBar: AppBar(title: const Text('New booking')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              const Text(
                'Ride details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pickup,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Pickup location',
                  prefixIcon: Icon(Icons.trip_origin),
                ),
                onChanged: (_) => setState(() => _estimate = null),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a pickup location'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _dropoff,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Drop-off location',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
                onChanged: (_) => setState(() => _estimate = null),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a drop-off location'
                    : null,
              ),
              const SizedBox(height: 14),
              _DateTimeTile(
                label: dateFormat.format(_pickupAt),
                onTap: _pickDateTime,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _vehicleClass,
                decoration: const InputDecoration(
                  labelText: 'Vehicle class',
                  prefixIcon: Icon(Icons.directions_car_outlined),
                ),
                items: _vehicleClasses.entries
                    .map(
                      (entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _vehicleClass = value;
                    _estimate = null;
                  });
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _hours,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Hours',
                        prefixIcon: Icon(Icons.timelapse),
                      ),
                      onChanged: (_) => setState(() => _estimate = null),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return null;
                        final hours = num.tryParse(value.trim());
                        return hours == null || hours <= 0
                            ? 'Enter valid hours'
                            : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _passengers,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Passengers',
                        prefixIcon: Icon(Icons.people_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return null;
                        final count = int.tryParse(value.trim());
                        return count == null || count <= 0
                            ? 'Enter a count'
                            : null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Contact phone',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) => value == null || value.trim().length < 7
                    ? 'Enter a contact phone'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _notes,
                minLines: 3,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  prefixIcon: Icon(Icons.sticky_note_2_outlined),
                ),
              ),
              const SizedBox(height: 18),
              if (_estimate != null)
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.payments_outlined,
                      color: AppTheme.gold,
                    ),
                    title: const Text('Estimated total'),
                    subtitle: const Text(
                      'Final fare may adjust after dispatch review.',
                    ),
                    trailing: Text(
                      currency.format(_estimate!.total),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.goldSoft,
                      ),
                    ),
                  ),
                ),
              if (_estimate != null) const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _estimating || _creating ? null : _estimatePrice,
                icon: _estimating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.calculate_outlined),
                label: const Text('Check estimate'),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _creating ? null : _create,
                icon: _creating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Icon(Icons.check),
                label: const Text('Confirm booking'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateTimeTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DateTimeTile({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Pickup date and time',
          prefixIcon: Icon(Icons.schedule),
        ),
        child: Row(
          children: [
            Expanded(child: Text(label)),
            const Icon(Icons.edit_calendar_outlined, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}
