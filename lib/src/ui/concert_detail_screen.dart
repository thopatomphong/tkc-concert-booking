import 'package:concert_mini_app/src/domain/entities/concert.dart';
import 'package:concert_mini_app/src/host_provider.dart';
import 'package:concert_mini_app/src/presentation/providers/concert_view_model_providers.dart';
import 'package:concert_mini_app/src/presentation/view_models/concert_detail_view_model.dart';
import 'package:concert_mini_app/src/ui/widgets/states.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ConcertDetailScreen extends ConsumerWidget {
  const ConcertDetailScreen({required this.concertId, super.key});

  final int concertId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(concertDetailViewModelProvider(concertId));
    final host = ref.watch(concertHostProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: state.concert.when(
        loading: () => const LoadingState(),
        error: (error, _) => ErrorStateView(
          message: '$error',
          onRetry: () => ref
              .read(concertDetailViewModelProvider(concertId).notifier)
              .load(),
        ),
        data: (item) => _ConcertDetailView(
          concert: item,
          state: state,
          viewModel: ref.read(
            concertDetailViewModelProvider(concertId).notifier,
          ),
          imageUrl: _resolveImageUrl(item.image, host.apiBaseUrl),
        ),
      ),
    );
  }
}

class _ConcertDetailView extends ConsumerWidget {
  const _ConcertDetailView({
    required this.concert,
    required this.state,
    required this.viewModel,
    required this.imageUrl,
  });

  final Concert concert;
  final ConcertDetailState state;
  final ConcertDetailViewModel viewModel;
  final String imageUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> book() async {
      final result = await viewModel.book();
      if (!context.mounted) {
        return;
      }
      switch (result) {
        case BookingValidationFailure(:final message):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        case BookingFailure(:final message):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        case BookingSuccess(:final booking):
          ref.invalidate(myBookingsViewModelProvider);
          ref.invalidate(concertDetailViewModelProvider(concert.id));
          ref.invalidate(concertListViewModelProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Booking #${booking.id} confirmed')),
          );
          Navigator.of(context).pop();
      }
    }

    final soldOut = concert.availableSeats <= 0;
    final quantity = state.quantity;
    return Column(
      children: <Widget>[
        _ConcertHero(imageUrl: imageUrl),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  concert.name,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF202124),
                    fontSize: 24,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  concert.artist,
                  style: const TextStyle(
                    color: Color(0xFF8A8A8A),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 28),
                _DetailInfoRow(
                  icon: Icons.calendar_today,
                  iconColor: Color(0xFFFFB300),
                  label: 'Date & Time',
                  value: _formatConcertDateTime(concert.date, concert.time),
                ),
                const Divider(height: 24, color: Color(0xFFEDEDED)),
                _DetailInfoRow(
                  icon: Icons.location_on,
                  iconColor: Color(0xFFF44336),
                  label: 'Venue',
                  value: concert.venue,
                ),
                const Divider(height: 24, color: Color(0xFFEDEDED)),
                _DetailInfoRow(
                  icon: Icons.add_box,
                  iconColor: Color(0xFF34A853),
                  label: 'Available Seats',
                  value: '${concert.availableSeats} / ${concert.totalSeats}',
                ),
                const Divider(height: 32, color: Color(0xFFEDEDED)),
                Row(
                  children: <Widget>[
                    const Text(
                      'Tickets',
                      style: TextStyle(
                        color: Color(0xFF202124),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    _QuantityButton(
                      icon: Icons.remove,
                      onPressed: !soldOut && quantity > 1
                          ? viewModel.decrementQuantity
                          : null,
                    ),
                    SizedBox(
                      width: 52,
                      child: Text(
                        '$quantity',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF202124),
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    _QuantityButton(
                      icon: Icons.add,
                      onPressed: !soldOut && quantity < concert.availableSeats
                          ? viewModel.incrementQuantity
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        _BookingBottomBar(
          total: concert.price * quantity,
          soldOut: soldOut,
          isBooking: state.isBooking,
          onBook: book,
        ),
      ],
    );
  }
}

class _ConcertHero extends StatelessWidget {
  const _ConcertHero({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      width: double.infinity,
      child: ColoredBox(
        color: const Color(0xFF171C36),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const _FallbackHeroArt(),
            ),
            SafeArea(
              bottom: false,
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 18, 20, 0),
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      minimumSize: const Size(0, 44),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.chevron_left, size: 24),
                    label: const Text(
                      'Concerts',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FallbackHeroArt extends StatelessWidget {
  const _FallbackHeroArt();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF171C36),
      child: Center(
        child: Icon(
          Icons.mic_external_on,
          color: Colors.white,
          size: 76,
        ),
      ),
    );
  }
}

class _DetailInfoRow extends StatelessWidget {
  const _DetailInfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: iconColor,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: Colors.white, size: 19),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF9A9A9A),
                  fontSize: 12,
                  height: 1.15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF202124),
                  fontSize: 15,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      width: 36,
      child: IconButton(
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white,
          disabledBackgroundColor: Colors.white,
          foregroundColor: const Color(0xFF888888),
          disabledForegroundColor: const Color(0xFFC8C8C8),
          side: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
          padding: EdgeInsets.zero,
        ),
        icon: Icon(icon, size: 18),
      ),
    );
  }
}

class _BookingBottomBar extends StatelessWidget {
  const _BookingBottomBar({
    required this.total,
    required this.soldOut,
    required this.isBooking,
    required this.onBook,
  });

  final int total;
  final bool soldOut;
  final bool isBooking;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE8E8E8)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 88,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Total',
                        style: TextStyle(
                          color: Color(0xFF9A9A9A),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatPrice(total),
                        style: const TextStyle(
                          color: Color(0xFFFF9800),
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 50,
                  width: 142,
                  child: FilledButton(
                    onPressed: soldOut || isBooking ? null : onBook,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFFA31A),
                      disabledBackgroundColor: const Color(0xFFE0E0E0),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: const Color(0xFF777777),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isBooking
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            soldOut ? 'Sold out' : 'Book Now',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
