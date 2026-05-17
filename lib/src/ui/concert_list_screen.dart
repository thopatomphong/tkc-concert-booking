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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Concerts'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.confirmation_num),
            tooltip: 'My bookings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const MyBookingsScreen(),
              ),
            ),
          ),
        ],
      ),
      body: concerts.when(
        loading: () => const LoadingState(),
        error: (error, _) => ErrorStateView(
          message: '$error',
          onRetry: () => ref.read(concertListViewModelProvider.notifier).load(),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState(message: 'No concerts available');
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(concertListViewModelProvider.notifier).load(),
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final concert = items[index];
                final soldOut = concert.availableSeats <= 0;
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: Image.network(
                      concert.image,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image),
                    ),
                    title: Text(concert.name),
                    subtitle: Text(
                      '${concert.artist}\n${concert.date} ${concert.time} - '
                      '${soldOut ? 'Sold out' : '${concert.availableSeats} seats left'}',
                    ),
                    isThreeLine: true,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            ConcertDetailScreen(concertId: concert.id),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
