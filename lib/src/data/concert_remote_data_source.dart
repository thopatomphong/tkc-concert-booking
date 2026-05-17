import 'package:concert_mini_app/src/data/concert_api_service.dart';
import 'package:concert_mini_app/src/domain/entities/booking.dart';
import 'package:concert_mini_app/src/domain/entities/concert.dart';

class DioConcertRemoteDataSource {
  const DioConcertRemoteDataSource(this._apiService);

  final ConcertApiService _apiService;

  Future<List<Concert>> getConcerts() async {
    final payload = await _apiService.fetchConcerts();
    return payload
        .map((dynamic item) => Concert.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Concert> getConcert(int id) async {
    final payload = await _apiService.fetchConcert(id);
    return Concert.fromJson(payload);
  }

  Future<Booking> createBooking({
    required int concertId,
    required int quantity,
  }) async {
    final payload = await _apiService.createBooking(
      concertId: concertId,
      quantity: quantity,
    );
    return Booking.fromJson(payload);
  }

  Future<List<Booking>> getBookings() async {
    final payload = await _apiService.fetchBookings();
    return payload
        .map((dynamic item) => Booking.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
