import 'package:concert_mini_app/src/di/concert_dependencies.dart';
import 'package:concert_mini_app/src/domain/entities/booking.dart';
import 'package:concert_mini_app/src/domain/entities/concert.dart';
import 'package:concert_mini_app/src/domain/use_cases/create_booking_use_case.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

export 'package:concert_mini_app/src/presentation/providers/concert_view_model_providers.dart';

/// Compatibility providers for older internal tests/imports.
///
/// Screens use MVVM providers from `presentation/providers`; these remain
/// thin use-case adapters so existing package-internal overrides keep working.
final concertListProvider = FutureProvider<List<Concert>>((ref) {
  return ref.watch(getConcertsUseCaseProvider)();
});

final concertDetailProvider = FutureProvider.family<Concert, int>((ref, id) {
  return ref.watch(getConcertDetailUseCaseProvider)(id);
});

final myBookingsProvider = FutureProvider<List<Booking>>((ref) {
  return ref.watch(getMyBookingsUseCaseProvider)();
});

final bookingActionsProvider = Provider<CreateBookingUseCase>((ref) {
  return ref.watch(createBookingUseCaseProvider);
});
