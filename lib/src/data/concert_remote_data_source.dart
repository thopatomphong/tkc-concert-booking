import 'package:concert_mini_app/src/domain/entities/booking.dart';
import 'package:concert_mini_app/src/domain/entities/concert.dart';
import 'package:dio/dio.dart';

class DioConcertRemoteDataSource {
  const DioConcertRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<Concert>> getConcerts() async {
    final res = await _dio.get<List<dynamic>>('/concert');
    return (res.data ?? <dynamic>[])
        .map((dynamic item) => Concert.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Concert> getConcert(int id) async {
    final res = await _dio.get<Map<String, dynamic>>('/concert/$id');
    return Concert.fromJson(res.data!);
  }

  Future<Booking> createBooking({
    required int concertId,
    required int quantity,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/booking',
      data: <String, dynamic>{'concertId': concertId, 'quantity': quantity},
    );
    return Booking.fromJson(res.data!);
  }

  Future<List<Booking>> getBookings() async {
    final res = await _dio.get<List<dynamic>>('/booking');
    return (res.data ?? <dynamic>[])
        .map((dynamic item) => Booking.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
