import 'package:concert_mini_app/src/data/concert_repository.dart';
import 'package:concert_mini_app/src/domain/failures/booking_failure.dart';
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
  test('getConcerts parses the concert list', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://test'));
    final adapter = DioAdapter(dio: dio);
    adapter.onGet(
      '/concert',
      (server) => server.reply(200, <dynamic>[_concertJson(1, 498)]),
    );

    final repo = DioConcertRepository.fromDio(dio);
    final concerts = await repo.getConcerts();
    expect(concerts.single.id, 1);
    expect(concerts.single.availableSeats, 498);
  });

  test('getConcert parses concert detail', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://test'));
    final adapter = DioAdapter(dio: dio);
    adapter.onGet(
      '/concert/2',
      (server) => server.reply(200, _concertJson(2, 45)),
    );

    final repo = DioConcertRepository.fromDio(dio);
    final concert = await repo.getConcert(2);

    expect(concert.id, 2);
    expect(concert.availableSeats, 45);
  });

  test('getBookings parses the bookings list', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://test'));
    final adapter = DioAdapter(dio: dio);
    adapter.onGet(
      '/booking',
      (server) => server.reply(200, <dynamic>[
        <String, dynamic>{
          'id': 7,
          'concert': _concertJson(3, 25),
          'quantity': 2,
          'total': 9000,
          'createdAt': '2026-07-12T12:00:00.000Z',
        },
      ]),
    );

    final repo = DioConcertRepository.fromDio(dio);
    final bookings = await repo.getBookings();

    expect(bookings.single.id, 7);
    expect(bookings.single.concert.id, 3);
  });

  test('createBooking posts the requested booking and parses the response',
      () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://test'));
    final adapter = DioAdapter(dio: dio);
    adapter.onPost(
      '/booking',
      (server) => server.reply(200, <String, dynamic>{
        'id': 9,
        'concert': _concertJson(1, 496),
        'quantity': 2,
        'total': 9000,
        'createdAt': '2026-07-12T12:00:00.000Z',
      }),
      data: <String, dynamic>{'concertId': 1, 'quantity': 2},
    );

    final repo = DioConcertRepository.fromDio(dio);
    final booking = await repo.createBooking(concertId: 1, quantity: 2);

    expect(booking.id, 9);
    expect(booking.quantity, 2);
  });

  test('createBooking throws SeatsUnavailableException on 400', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://test'));
    final adapter = DioAdapter(dio: dio);
    adapter.onPost(
      '/booking',
      (server) =>
          server.reply(400, <String, dynamic>{'message': 'not enough seats'}),
      data: <String, dynamic>{'concertId': 1, 'quantity': 999},
    );

    final repo = DioConcertRepository.fromDio(dio);
    expect(
      () => repo.createBooking(concertId: 1, quantity: 999),
      throwsA(isA<SeatsUnavailableException>()),
    );
  });
}
