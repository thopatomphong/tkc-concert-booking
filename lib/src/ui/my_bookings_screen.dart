import 'package:concert_mini_app/src/domain/entities/booking.dart';
import 'package:concert_mini_app/src/host_provider.dart';
import 'package:concert_mini_app/src/presentation/providers/concert_view_model_providers.dart';
import 'package:concert_mini_app/src/ui/widgets/states.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(myBookingsViewModelProvider);
    final host = ref.watch(concertHostProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _MyBookingsHeader(
              onBackPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: bookings.when(
                loading: () => const LoadingState(),
                error: (error, _) => ErrorStateView(
                  message: '$error',
                  onRetry: () =>
                      ref.read(myBookingsViewModelProvider.notifier).load(),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return const EmptyState(message: 'No bookings yet');
                  }
                  return RefreshIndicator(
                    onRefresh: () =>
                        ref.read(myBookingsViewModelProvider.notifier).load(),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final booking = items[index];
                        return _BookingCard(
                          booking: booking,
                          imageUrl: _resolveImageUrl(
                            booking.concert.image,
                            host.apiBaseUrl,
                          ),
                          accentColor: _bookingAccentColor(index),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyBookingsHeader extends StatelessWidget {
  const _MyBookingsHeader({required this.onBackPressed});

  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE3E4EA)),
        ),
      ),
      child: SizedBox(
        height: 84,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: <Widget>[
              TextButton.icon(
                onPressed: onBackPressed,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFFA000),
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 44),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.chevron_left, size: 24),
                label: const Text(
                  'Concerts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'My Bookings',
                style: TextStyle(
                  color: Color(0xFF202124),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.imageUrl,
    required this.accentColor,
  });

  final Booking booking;
  final String imageUrl;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final concert = booking.concert;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE8E8EE)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 14),
                child: Column(
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _BookingThumbnail(
                          imageUrl: imageUrl,
                          accentColor: accentColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                concert.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF202124),
                                  fontSize: 16,
                                  height: 1.18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                concert.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF8A8A8A),
                                  fontSize: 14,
                                  height: 1.2,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatConcertDateTime(
                                  concert.date,
                                  concert.time,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF777777),
                                  fontSize: 14,
                                  height: 1.2,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.confirmation_num_outlined,
                          color: Color(0xFF9E9E9E),
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _formatTicketCount(booking.quantity),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF777777),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          _formatPrice(booking.total),
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            color: Color(0xFFFF9800),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFEDEDF2)),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 16, 12),
                child: Row(
                  children: const <Widget>[
                    _ConfirmedChip(),
                    Spacer(),
                    Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xFFF44336),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingThumbnail extends StatelessWidget {
  const _BookingThumbnail({
    required this.imageUrl,
    required this.accentColor,
  });

  final String imageUrl;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 56,
        height: 56,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _FallbackBookingArt(
            color: accentColor,
          ),
        ),
      ),
    );
  }
}

class _FallbackBookingArt extends StatelessWidget {
  const _FallbackBookingArt({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: const Center(
        child: Icon(
          Icons.mic_external_on,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

class _ConfirmedChip extends StatelessWidget {
  const _ConfirmedChip();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFDDF7E5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const <Widget>[
            Icon(
              Icons.circle,
              color: Color(0xFF2EB65C),
              size: 7,
            ),
            SizedBox(width: 8),
            Text(
              'Confirmed',
              style: TextStyle(
                color: Color(0xFF2F9E52),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _bookingAccentColor(int index) {
  const colors = <Color>[
    Color(0xFF171C36),
    Color(0xFF6D1A54),
    Color(0xFF0F3A64),
    Color(0xFF4A2A65),
  ];
  return colors[index % colors.length];
}

String _formatTicketCount(int quantity) {
  return quantity == 1 ? '1 ticket' : '$quantity tickets';
}

String _formatPrice(int price) {
  final digits = price.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i += 1) {
    final fromRight = digits.length - i;
    buffer.write(digits[i]);
    if (fromRight > 1 && fromRight % 3 == 1) {
      buffer.write(',');
    }
  }
  return '฿$buffer';
}

String _formatConcertDateTime(String date, String time) {
  final parsed = DateTime.tryParse('${date}T$time');
  if (parsed == null) {
    return '$date · $time';
  }
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final month = months[parsed.month - 1];
  final hour = parsed.hour.toString().padLeft(2, '0');
  final minute = parsed.minute.toString().padLeft(2, '0');
  return '$month ${parsed.day}, ${parsed.year} · $hour:$minute';
}

String _resolveImageUrl(String image, String apiBaseUrl) {
  final uri = Uri.tryParse(image);
  if (uri != null && uri.hasScheme) {
    return image;
  }

  final base = Uri.parse(
    apiBaseUrl.endsWith('/') ? apiBaseUrl : '$apiBaseUrl/',
  );
  return base.resolve(image).toString();
}
