import 'package:concert_mini_app/src/domain/entities/booking.dart';
import 'package:concert_mini_app/src/domain/repositories/concert_repository.dart';

class CreateBookingUseCase {
  const CreateBookingUseCase(this._repository);

  final ConcertRepository _repository;

  Future<Booking> call({
    required int concertId,
    required int quantity,
  }) {
    return _repository.createBooking(
      concertId: concertId,
      quantity: quantity,
    );
  }
}
