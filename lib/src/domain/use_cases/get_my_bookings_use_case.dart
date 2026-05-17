import 'package:concert_mini_app/src/domain/entities/booking.dart';
import 'package:concert_mini_app/src/domain/repositories/concert_repository.dart';

class GetMyBookingsUseCase {
  const GetMyBookingsUseCase(this._repository);

  final ConcertRepository _repository;

  Future<List<Booking>> call() => _repository.getBookings();
}
