import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/booking.dart';
import 'status_badge.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;

  const BookingCard({super.key, required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM d, h:mm a');
    final currency = NumberFormat.simpleCurrency(name: 'USD');
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      booking.reference.isEmpty
                          ? 'Booking #${booking.id}'
                          : booking.reference,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  StatusBadge(booking.status),
                ],
              ),
              if (booking.vehicleClass != null) ...[
                const SizedBox(height: 4),
                Text(
                  booking.vehicleClass!.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _line(Icons.trip_origin, booking.pickupLocation),
              if (booking.dropoffLocation != null) ...[
                const SizedBox(height: 6),
                _line(Icons.place_outlined, booking.dropoffLocation!),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 14,
                runSpacing: 8,
                children: [
                  if (booking.pickupAt != null)
                    _meta(Icons.schedule, dateFormat.format(booking.pickupAt!)),
                  if (booking.passengerCount != null)
                    _meta(Icons.people_outline, '${booking.passengerCount}'),
                  if (booking.total != null)
                    _meta(
                      Icons.payments_outlined,
                      currency.format(booking.total),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _line(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: Colors.white38),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _meta(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: Colors.white38),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    );
  }
}
