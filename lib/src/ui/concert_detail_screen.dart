import 'package:concert_mini_app/src/domain/entities/concert.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Concert')),
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
  });

  final Concert concert;
  final ConcertDetailState state;
  final ConcertDetailViewModel viewModel;

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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Image.network(
          concert.image,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const SizedBox(height: 200, child: Icon(Icons.image)),
        ),
        const SizedBox(height: 16),
        Text(concert.name, style: Theme.of(context).textTheme.headlineSmall),
        Text(concert.artist, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('${concert.venue} - ${concert.location}'),
        Text('${concert.date} ${concert.time}'),
        Text('THB ${concert.price} per ticket'),
        Text('${concert.availableSeats} / ${concert.totalSeats} seats left'),
        const Divider(height: 32),
        if (soldOut)
          const Text('This concert is sold out')
        else ...<Widget>[
          Row(
            children: <Widget>[
              const Text('Tickets:'),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: quantity > 1 ? viewModel.decrementQuantity : null,
              ),
              Text('$quantity'),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: quantity < concert.availableSeats
                    ? viewModel.incrementQuantity
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: state.isBooking ? null : book,
            child: state.isBooking
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('Book - THB ${concert.price * quantity}'),
          ),
        ],
      ],
    );
  }
}
