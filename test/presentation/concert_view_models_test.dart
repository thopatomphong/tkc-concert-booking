import 'package:concert_mini_app/src/domain/entities/booking.dart';
import 'package:concert_mini_app/src/domain/entities/concert.dart';
import 'package:concert_mini_app/src/domain/repositories/concert_repository.dart';
import 'package:concert_mini_app/src/domain/use_cases/create_booking_use_case.dart';
import 'package:concert_mini_app/src/domain/use_cases/get_concert_detail_use_case.dart';
import 'package:concert_mini_app/src/domain/use_cases/get_concerts_use_case.dart';
import 'package:concert_mini_app/src/domain/use_cases/get_my_bookings_use_case.dart';
import 'package:concert_mini_app/src/domain/use_cases/validate_booking_quantity_use_case.dart';
import 'package:concert_mini_app/src/presentation/view_models/concert_detail_view_model.dart';
import 'package:concert_mini_app/src/presentation/view_models/concert_list_view_model.dart';
import 'package:concert_mini_app/src/presentation/view_models/my_bookings_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ConcertListViewModel emits loaded concerts', () async {
    final repository = _FakeConcertRepository();
    final viewModel = ConcertListViewModel(GetConcertsUseCase(repository));

    expect(viewModel.state.isLoading, isTrue);

    await viewModel.load();

    expect(viewModel.state.value, repository.concerts);
  });

  test('MyBookingsViewModel emits loaded bookings', () async {
    final repository = _FakeConcertRepository();
    final viewModel = MyBookingsViewModel(GetMyBookingsUseCase(repository));

    await viewModel.load();

    expect(viewModel.state.value, repository.bookings);
  });

  test('ConcertDetailViewModel validates before creating a booking', () async {
    final repository = _FakeConcertRepository();
    final viewModel = ConcertDetailViewModel(
      concertId: 1,
      getConcertDetail: GetConcertDetailUseCase(repository),
      createBooking: CreateBookingUseCase(repository),
      validateBookingQuantity: const ValidateBookingQuantityUseCase(),
    );

    await viewModel.load();
    viewModel.setQuantity(99);
    final result = await viewModel.book();

    expect(result, isA<BookingValidationFailure>());
    expect(repository.bookingCalls, isEmpty);
  });

  test('ConcertDetailViewModel exposes booking confirmation on success',
      () async {
    final repository = _FakeConcertRepository();
    final viewModel = ConcertDetailViewModel(
      concertId: 1,
      getConcertDetail: GetConcertDetailUseCase(repository),
      createBooking: CreateBookingUseCase(repository),
      validateBookingQuantity: const ValidateBookingQuantityUseCase(),
    );

    await viewModel.load();
    viewModel.setQuantity(2);
    final result = await viewModel.book();

    expect(result, isA<BookingSuccess>());
    expect((result as BookingSuccess).booking.id, 55);
    expect(repository.bookingCalls, <String>['1:2']);
  });
}

class _FakeConcertRepository implements ConcertRepository {
  final bookingCalls = <String>[];

  final concerts = <Concert>[
    _concert(1, availableSeats: 4),
  ];

  late final bookings = <Booking>[
    Booking(
      id: 55,
      concert: concerts.single,
      quantity: 2,
      total: 6000,
      createdAt: DateTime(2026, 7, 12),
    ),
  ];

  @override
  Future<Booking> createBooking({
    required int concertId,
    required int quantity,
  }) async {
    bookingCalls.add('$concertId:$quantity');
    return bookings.single;
  }

  @override
  Future<List<Booking>> getBookings() async => bookings;

  @override
  Future<Concert> getConcert(int id) async => concerts.single;

  @override
  Future<List<Concert>> getConcerts() async => concerts;
}

Concert _concert(int id, {required int availableSeats}) {
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
    availableSeats: availableSeats,
    image: 'http://test/concert-$id.png',
  );
}
