import 'package:dio/dio.dart';

class ConcertApiService {
  const ConcertApiService(this._dio);

  final Dio _dio;

  Future<List<dynamic>> fetchConcerts() async {
    final res = await _dio.get<List<dynamic>>('/concert');
    return res.data ?? <dynamic>[];
  }

  Future<Map<String, dynamic>> fetchConcert(int id) async {
    final res = await _dio.get<Map<String, dynamic>>('/concert/$id');
    return res.data!;
  }

  Future<Map<String, dynamic>> createBooking({
    required int concertId,
    required int quantity,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/booking',
      data: <String, dynamic>{
        'concertId': concertId,
        'quantity': quantity,
      },
    );
    return res.data!;
  }

  Future<List<dynamic>> fetchBookings() async {
    final res = await _dio.get<List<dynamic>>('/booking');
    return res.data ?? <dynamic>[];
  }
}
