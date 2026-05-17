import 'package:concert_mini_app/src/concert_host.dart';
import 'package:concert_mini_app/src/data/concert_repository.dart';
import 'package:concert_mini_app/src/domain/repositories/concert_repository.dart';
import 'package:concert_mini_app/src/domain/use_cases/create_booking_use_case.dart';
import 'package:concert_mini_app/src/domain/use_cases/get_concert_detail_use_case.dart';
import 'package:concert_mini_app/src/domain/use_cases/get_concerts_use_case.dart';
import 'package:concert_mini_app/src/domain/use_cases/get_my_bookings_use_case.dart';
import 'package:concert_mini_app/src/domain/use_cases/validate_booking_quantity_use_case.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Holds the host injected by `ConcertMiniApp.create`. The base value throws;
/// it must always be overridden at the Mini App's ProviderScope.
final concertHostProvider = Provider<ConcertHost>((ref) {
  throw StateError('concertHostProvider must be overridden with a host');
});

final concertRepositoryProvider = Provider<ConcertRepository>((ref) {
  return DioConcertRepository.fromDio(
    ref.watch(concertHostProvider).httpClient,
  );
});

final getConcertsUseCaseProvider = Provider<GetConcertsUseCase>((ref) {
  return GetConcertsUseCase(ref.watch(concertRepositoryProvider));
});

final getConcertDetailUseCaseProvider =
    Provider<GetConcertDetailUseCase>((ref) {
  return GetConcertDetailUseCase(ref.watch(concertRepositoryProvider));
});

final createBookingUseCaseProvider = Provider<CreateBookingUseCase>((ref) {
  return CreateBookingUseCase(ref.watch(concertRepositoryProvider));
});

final getMyBookingsUseCaseProvider = Provider<GetMyBookingsUseCase>((ref) {
  return GetMyBookingsUseCase(ref.watch(concertRepositoryProvider));
});

final validateBookingQuantityUseCaseProvider =
    Provider<ValidateBookingQuantityUseCase>((ref) {
  return const ValidateBookingQuantityUseCase();
});
