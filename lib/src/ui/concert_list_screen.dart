import 'package:concert_mini_app/src/domain/entities/concert.dart';
import 'package:concert_mini_app/src/host_provider.dart';
import 'package:concert_mini_app/src/presentation/providers/concert_view_model_providers.dart';
import 'package:concert_mini_app/src/ui/concert_detail_screen.dart';
import 'package:concert_mini_app/src/ui/my_bookings_screen.dart';
import 'package:concert_mini_app/src/ui/widgets/states.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ConcertListScreen extends ConsumerWidget {
  const ConcertListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final concerts = ref.watch(concertListViewModelProvider);
    final host = ref.watch(concertHostProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _ConcertListHeader(
              onHomePressed: host.onExit,
              onBookingsPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const MyBookingsScreen(),
                ),
              ),
            ),
            Expanded(
              child: concerts.when(
                loading: () => const LoadingState(),
                error: (error, _) => ErrorStateView(
                  message: '$error',
                  onRetry: () =>
                      ref.read(concertListViewModelProvider.notifier).load(),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return const EmptyState(message: 'No concerts available');
                  }
                  return RefreshIndicator(
                    onRefresh: () =>
                        ref.read(concertListViewModelProvider.notifier).load(),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final concert = items[index];
                        return _ConcertCard(
                          concert: concert,
                          imageUrl: _resolveImageUrl(
                            concert.image,
                            host.apiBaseUrl,
                          ),
                          accentColor: _concertAccentColor(index),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ConcertDetailScreen(
                                concertId: concert.id,
                              ),
                            ),
                          ),
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

class _ConcertListHeader extends StatelessWidget {
  const _ConcertListHeader({
    required this.onHomePressed,
    required this.onBookingsPressed,
  });

  final VoidCallback onHomePressed;
  final VoidCallback onBookingsPressed;

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
                onPressed: onHomePressed,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFFA000),
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 44),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.chevron_left, size: 24),
                label: const Text(
                  'Home',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'Concerts',
                style: TextStyle(
                  color: Color(0xFF202124),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onBookingsPressed,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFFA000),
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 44),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'My Bookings',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConcertCard extends StatelessWidget {
  const _ConcertCard({
    required this.concert,
    required this.imageUrl,
    required this.accentColor,
    required this.onTap,
  });

  final Concert concert;
  final String imageUrl;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final seatsText = concert.availableSeats <= 0
        ? 'Sold out'
        : '${concert.availableSeats} seats left';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _ConcertImageBanner(
                imageUrl: imageUrl,
                accentColor: accentColor,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      concert.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF202124),
                        fontSize: 18,
                        height: 1.15,
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
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ConcertInfoRow(
                      icon: Icons.calendar_today,
                      text: _formatConcertDateTime(concert.date, concert.time),
                    ),
                    const SizedBox(height: 6),
                    _ConcertInfoRow(
                      icon: Icons.location_on,
                      text: concert.venue,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF0E8DA)),
              Container(
                height: 48,
                color: const Color(0xFFFFF9EB),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: <Widget>[
                    Text(
                      _formatPrice(concert.price),
                      style: const TextStyle(
                        color: Color(0xFFFF9800),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        seatsText,
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF8A8A8A),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
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

class _ConcertImageBanner extends StatelessWidget {
  const _ConcertImageBanner({
    required this.imageUrl,
    required this.accentColor,
  });

  final String imageUrl;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      width: double.infinity,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _FallbackConcertArt(color: accentColor),
      ),
    );
  }
}

class _FallbackConcertArt extends StatelessWidget {
  const _FallbackConcertArt({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: const Center(
        child: Icon(
          Icons.mic_external_on,
          color: Colors.white,
          size: 54,
        ),
      ),
    );
  }
}

class _ConcertInfoRow extends StatelessWidget {
  const _ConcertInfoRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, color: const Color(0xFF9E9E9E), size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF777777),
              fontSize: 14,
              height: 1.25,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

Color _concertAccentColor(int index) {
  const colors = <Color>[
    Color(0xFF171C36),
    Color(0xFF6D1A54),
    Color(0xFF0F3A64),
    Color(0xFF4A2A65),
  ];
  return colors[index % colors.length];
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
