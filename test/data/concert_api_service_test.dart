import 'package:concert_mini_app/src/data/concert_api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

Map<String, dynamic> _concertJson(int id, int seats) => <String, dynamic>{
      'id': id,
      'name': 'Concert $id',
      'artist': 'Artist',
      'venue': 'Venue',
      'location': 'Bangkok',
      'date': '2026-07-12',
      'time': '19:00',
      'price': 4500,
      'totalSeats': 500,
      'availableSeats': seats,
      'image': 'x',
    };

void main() {
  test('fetchConcerts sends GET /concert and returns the raw list', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://test'));
    final adapter = DioAdapter(dio: dio);
    final payload = <dynamic>[_concertJson(1, 498)];
    adapter.onGet('/concert', (server) => server.reply(200, payload));

    final api = ConcertApiService(dio);
    final concerts = await api.fetchConcerts();

    expect(concerts, payload);
  });

  test('fetchConcert sends GET /concert/{id} with the numeric path id',
      () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://test'));
    final adapter = DioAdapter(dio: dio);
    final payload = _concertJson(2, 45);
    adapter.onGet('/concert/2', (server) => server.reply(200, payload));

    final api = ConcertApiService(dio);
    final concert = await api.fetchConcert(2);

    expect(concert, payload);
  });

  test('createBooking sends POST /booking with concertId and quantity',
      () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://test'));
    final adapter = DioAdapter(dio: dio);
    final payload = <String, dynamic>{
      'id': 9,
      'concert': _concertJson(1, 496),
      'quantity': 2,
      'total': 9000,
      'createdAt': '2026-07-12T12:00:00.000Z',
    };
    adapter.onPost(
      '/booking',
      (server) => server.reply(201, payload),
      data: <String, dynamic>{'concertId': 1, 'quantity': 2},
    );

    final api = ConcertApiService(dio);
    final booking = await api.createBooking(concertId: 1, quantity: 2);

    expect(booking, payload);
  });

  test('fetchBookings sends GET /booking and returns the raw list', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://test'));
    final adapter = DioAdapter(dio: dio);
    final payload = <dynamic>[
      <String, dynamic>{
        'id': 7,
        'concert': _concertJson(3, 25),
        'quantity': 2,
        'total': 9000,
        'createdAt': '2026-07-12T12:00:00.000Z',
      },
    ];
    adapter.onGet('/booking', (server) => server.reply(200, payload));

    final api = ConcertApiService(dio);
    final bookings = await api.fetchBookings();

    expect(bookings, payload);
  });
}
