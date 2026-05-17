import 'package:concert_mini_app/src/presentation/providers/concert_view_model_providers.dart';
import 'package:concert_mini_app/src/ui/widgets/states.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(myBookingsViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: bookings.when(
        loading: () => const LoadingState(),
        error: (error, _) => ErrorStateView(
          message: '$error',
          onRetry: () => ref.read(myBookingsViewModelProvider.notifier).load(),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState(message: 'No bookings yet');
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(myBookingsViewModelProvider.notifier).load(),
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final booking = items[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.confirmation_num),
                    title: Text(booking.concert.name),
                    subtitle: Text(
                      '${booking.concert.artist}\n'
                      '${booking.concert.date} ${booking.concert.time}\n'
                      '${booking.quantity} ticket(s) - THB ${booking.total}',
                    ),
                    isThreeLine: true,
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
