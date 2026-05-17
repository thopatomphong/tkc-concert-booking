import 'package:concert_mini_app/src/data/concert_api_service.dart';
import 'package:concert_mini_app/src/data/concert_remote_data_source.dart';
import 'package:concert_mini_app/src/domain/entities/booking.dart';
import 'package:concert_mini_app/src/domain/entities/concert.dart';
import 'package:concert_mini_app/src/domain/failures/booking_failure.dart';
import 'package:concert_mini_app/src/domain/repositories/concert_repository.dart';
import 'package:dio/dio.dart';

class DioConcertRepository implements ConcertRepository {
  const DioConcertRepository(this._remoteDataSource);

  factory DioConcertRepository.fromDio(Dio dio) {
    return DioConcertRepository(
      DioConcertRemoteDataSource(ConcertApiService(dio)),
    );
  }

  final DioConcertRemoteDataSource _remoteDataSource;

  @override
  Future<List<Concert>> getConcerts() => _remoteDataSource.getConcerts();

  @override
  Future<Concert> getConcert(int id) => _remoteDataSource.getConcert(id);

  @override
  Future<Booking> createBooking({
    required int concertId,
    required int quantity,
  }) async {
    try {
      return await _remoteDataSource.createBooking(
        concertId: concertId,
        quantity: quantity,
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 400) {
        final data = error.response?.data;
        final message = data is Map
            ? '${data['message'] ?? 'Not enough seats'}'
            : 'Not enough seats';
        throw SeatsUnavailableException(message);
      }
      rethrow;
    }
  }

  @override
  Future<List<Booking>> getBookings() => _remoteDataSource.getBookings();
}
