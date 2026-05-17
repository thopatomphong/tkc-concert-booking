import 'package:concert_mini_app/src/domain/entities/booking.dart';
import 'package:concert_mini_app/src/domain/entities/concert.dart';

abstract interface class ConcertRepository {
  Future<List<Concert>> getConcerts();

  Future<Concert> getConcert(int id);

  Future<Booking> createBooking({
    required int concertId,
    required int quantity,
  });

  Future<List<Booking>> getBookings();
}
