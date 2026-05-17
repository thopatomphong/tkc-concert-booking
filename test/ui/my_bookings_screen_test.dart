import 'dart:async';

import 'package:concert_mini_app/src/concert_host.dart';
import 'package:concert_mini_app/src/domain/entities/booking.dart';
import 'package:concert_mini_app/src/domain/entities/concert.dart';
import 'package:concert_mini_app/src/domain/repositories/concert_repository.dart';
import 'package:concert_mini_app/src/domain/use_cases/get_my_bookings_use_case.dart';
import 'package:concert_mini_app/src/host_provider.dart';
import 'package:concert_mini_app/src/presentation/providers/concert_view_model_providers.dart';
import 'package:concert_mini_app/src/presentation/view_models/my_bookings_view_model.dart';
import 'package:concert_mini_app/src/ui/my_bookings_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class _StubHost implements ConcertHost {
  @override
  Dio get httpClient => Dio(BaseOptions(baseUrl: 'http://test'));

  @override
  String get apiBaseUrl => 'http://test';

  @override
  void onExit() {}
}

void main() {
  testWidgets('my bookings shows a spinner while loading', (tester) async {
    await _setPhoneSurface(tester);
    final repository = _FakeBookingRepository(
      bookingsCompleter: Completer<List<Booking>>(),
    );

    await tester.pumpWidget(_app(repository: repository));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('my bookings shows an empty state', (tester) async {
    await _setPhoneSurface(tester);
    final repository = _FakeBookingRepository(bookings: <Booking>[]);

    await tester.pumpWidget(_app(repository: repository));
    await tester.pump();

    expect(find.text('No bookings yet'), findsOneWidget);
  });

  testWidgets('my bookings renders loaded booking cards', (tester) async {
    await _setPhoneSurface(tester);
    final repository = _FakeBookingRepository(
      bookings: <Booking>[
        _booking(
          quantity: 2,
          total: 9000,
          concert: _concert(
            name: 'BORN PINK World Tour Bangkok',
            artist: 'BLACKPINK',
            date: '2026-07-12',
            time: '19:00',
          ),
        ),
        _booking(
          id: 2,
          quantity: 1,
          total: 5500,
          concert: _concert(
            id: 2,
            name: 'THE ERAS TOUR Bangkok',
            artist: 'Taylor Swift',
            date: '2026-08-20',
            time: '18:30',
          ),
        ),
      ],
    );

    await tester.pumpWidget(_app(repository: repository));
    await tester.pump();

    expect(find.text('BORN PINK World Tour Bangkok'), findsOneWidget);
    expect(find.text('BLACKPINK'), findsOneWidget);
    expect(find.text('Jul 12, 2026 · 19:00'), findsOneWidget);
    expect(find.text('2 tickets'), findsOneWidget);
    expect(find.text('฿9,000'), findsOneWidget);
    expect(find.text('Confirmed'), findsNWidgets(2));
    expect(find.text('Cancel'), findsNWidgets(2));

    expect(find.text('THE ERAS TOUR Bangkok'), findsOneWidget);
    expect(find.text('Taylor Swift'), findsOneWidget);
    expect(find.text('Aug 20, 2026 · 18:30'), findsOneWidget);
    expect(find.text('1 ticket'), findsOneWidget);
    expect(find.text('฿5,500'), findsOneWidget);
  });

  testWidgets('my bookings header pops back to concerts', (tester) async {
    await _setPhoneSurface(tester);
    final repository = _FakeBookingRepository(bookings: <Booking>[_booking()]);

    await tester.pumpWidget(
      _app(
        repository: repository,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const MyBookingsScreen(),
                  ),
                ),
                child: const Text('Open bookings'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open bookings'));
    await tester.pumpAndSettle();
    expect(find.text('Concerts'), findsOneWidget);

    await tester.tap(find.text('Concerts'));
    await tester.pumpAndSettle();

    expect(find.text('Open bookings'), findsOneWidget);
  });

  testWidgets('my bookings resolves relative image URLs against host base URL',
      (tester) async {
    await _setPhoneSurface(tester);
    final repository = _FakeBookingRepository(
      bookings: <Booking>[
        _booking(concert: _concert(image: '/images/concert-1.png')),
      ],
    );

    await tester.pumpWidget(_app(repository: repository));
    await tester.pump();

    final image = tester.widget<Image>(find.byType(Image).first);
    final provider = image.image as NetworkImage;
    expect(provider.url, 'http://test/images/concert-1.png');
  });
}

Future<void> _setPhoneSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(393, 852));
  tester.view.devicePixelRatio = 1;
  addTearDown(() async {
    tester.view.resetDevicePixelRatio();
    await tester.binding.setSurfaceSize(null);
  });
}

Widget _app({
  required _FakeBookingRepository repository,
  Widget home = const MyBookingsScreen(),
}) {
  return ProviderScope(
    overrides: <Override>[
      concertHostProvider.overrideWithValue(_StubHost()),
      myBookingsViewModelProvider.overrideWith((ref) {
        final viewModel = MyBookingsViewModel(
          GetMyBookingsUseCase(repository),
        );
        viewModel.load();
        return viewModel;
      }),
    ],
    child: MaterialApp(home: home),
  );
}

class _FakeBookingRepository implements ConcertRepository {
  _FakeBookingRepository({
    List<Booking>? bookings,
    Completer<List<Booking>>? bookingsCompleter,
  })  : _bookings = bookings,
        _bookingsCompleter = bookingsCompleter;

  final List<Booking>? _bookings;
  final Completer<List<Booking>>? _bookingsCompleter;

  @override
  Future<Booking> createBooking({
    required int concertId,
    required int quantity,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<Booking>> getBookings() {
    final bookings = _bookings;
    if (bookings != null) {
      return Future<List<Booking>>.value(bookings);
    }
    return _bookingsCompleter!.future;
  }

  @override
  Future<Concert> getConcert(int id) {
    throw UnimplementedError();
  }

  @override
  Future<List<Concert>> getConcerts() {
    throw UnimplementedError();
  }
}

Booking _booking({
  int id = 1,
  Concert? concert,
  int quantity = 2,
  int total = 9000,
}) {
  return Booking(
    id: id,
    concert: concert ?? _concert(),
    quantity: quantity,
    total: total,
    createdAt: DateTime(2026, 7, 12),
  );
}

Concert _concert({
  int id = 1,
  String name = 'BORN PINK World Tour Bangkok',
  String artist = 'BLACKPINK',
  String venue = 'Rajamangala Stadium',
  String location = 'Bangkok',
  String date = '2026-07-12',
  String time = '19:00',
  int price = 4500,
  int totalSeats = 500,
  int availableSeats = 498,
  String image = 'http://test/concert-1.png',
}) {
  return Concert(
    id: id,
    name: name,
    artist: artist,
    venue: venue,
    location: location,
    date: date,
    time: time,
    price: price,
    totalSeats: totalSeats,
    availableSeats: availableSeats,
    image: image,
  );
}
