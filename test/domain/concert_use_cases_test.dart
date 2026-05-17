import 'package:concert_mini_app/src/domain/entities/booking.dart';
import 'package:concert_mini_app/src/domain/entities/concert.dart';
import 'package:concert_mini_app/src/domain/repositories/concert_repository.dart';
import 'package:concert_mini_app/src/domain/use_cases/create_booking_use_case.dart';
import 'package:concert_mini_app/src/domain/use_cases/get_concert_detail_use_case.dart';
import 'package:concert_mini_app/src/domain/use_cases/get_concerts_use_case.dart';
import 'package:concert_mini_app/src/domain/use_cases/get_my_bookings_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakeConcertRepository repository;

  setUp(() {
    repository = _FakeConcertRepository();
  });

  test('GetConcertsUseCase delegates to the repository contract', () async {
    final concerts = await GetConcertsUseCase(repository)();

    expect(concerts, repository.concerts);
    expect(repository.calls, <String>['getConcerts']);
  });

  test('GetConcertDetailUseCase delegates with the requested id', () async {
    final concert = await GetConcertDetailUseCase(repository)(7);

    expect(concert.id, 7);
    expect(repository.calls, <String>['getConcert:7']);
  });

  test('CreateBookingUseCase delegates with concert id and quantity', () async {
    final booking = await CreateBookingUseCase(repository)(
      concertId: 2,
      quantity: 3,
    );

    expect(booking.id, 10);
    expect(repository.calls, <String>['createBooking:2:3']);
  });

  test('GetMyBookingsUseCase delegates to the repository contract', () async {
    final bookings = await GetMyBookingsUseCase(repository)();

    expect(bookings, repository.bookings);
    expect(repository.calls, <String>['getBookings']);
  });
}

class _FakeConcertRepository implements ConcertRepository {
  final calls = <String>[];

  final concerts = <Concert>[
    _concert(1),
    _concert(7),
  ];

  late final bookings = <Booking>[
    Booking(
      id: 10,
      concert: concerts.first,
      quantity: 3,
      total: 9000,
      createdAt: DateTime(2026, 7, 12),
    ),
  ];

  @override
  Future<Booking> createBooking({
    required int concertId,
    required int quantity,
  }) async {
    calls.add('createBooking:$concertId:$quantity');
    return bookings.single;
  }

  @override
  Future<List<Booking>> getBookings() async {
    calls.add('getBookings');
    return bookings;
  }

  @override
  Future<Concert> getConcert(int id) async {
    calls.add('getConcert:$id');
    return concerts.firstWhere((concert) => concert.id == id);
  }

  @override
  Future<List<Concert>> getConcerts() async {
    calls.add('getConcerts');
    return concerts;
  }
}

Concert _concert(int id) {
  return Concert(
    id: id,
    name: 'Concert $id',
    artist: 'Artist',
    venue: 'Venue',
    location: 'Bangkok',
    date: '2026-07-12',
    time: '19:00',
    price: 3000,
    totalSeats: 100,
    availableSeats: 20,
    image: 'http://test/concert-$id.png',
  );
}
