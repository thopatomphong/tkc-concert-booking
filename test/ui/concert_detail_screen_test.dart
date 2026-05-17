import 'dart:async';

import 'package:concert_mini_app/src/concert_host.dart';
import 'package:concert_mini_app/src/domain/entities/booking.dart';
import 'package:concert_mini_app/src/domain/entities/concert.dart';
import 'package:concert_mini_app/src/domain/repositories/concert_repository.dart';
import 'package:concert_mini_app/src/domain/use_cases/create_booking_use_case.dart';
import 'package:concert_mini_app/src/domain/use_cases/get_concert_detail_use_case.dart';
import 'package:concert_mini_app/src/domain/use_cases/validate_booking_quantity_use_case.dart';
import 'package:concert_mini_app/src/host_provider.dart';
import 'package:concert_mini_app/src/presentation/providers/concert_view_model_providers.dart';
import 'package:concert_mini_app/src/presentation/view_models/concert_detail_view_model.dart';
import 'package:concert_mini_app/src/ui/concert_detail_screen.dart';
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
  testWidgets('concert detail shows a spinner while loading', (tester) async {
    await _setPhoneSurface(tester);
    final repository = _FakeConcertRepository(
      concertCompleter: Completer<Concert>(),
    );

    await tester.pumpWidget(_app(repository: repository));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('concert detail renders loaded concert data', (tester) async {
    await _setPhoneSurface(tester);
    final repository = _FakeConcertRepository(
      concert: _concert(
        name: 'BORN PINK World Tour Bangkok',
        artist: 'BLACKPINK',
        venue: 'Rajamangala Stadium',
        price: 4500,
        availableSeats: 498,
        totalSeats: 500,
      ),
    );

    await tester.pumpWidget(_app(repository: repository));
    await tester.pump();

    expect(find.text('BORN PINK World Tour Bangkok'), findsOneWidget);
    expect(find.text('BLACKPINK'), findsOneWidget);
    expect(find.text('Jul 12, 2026 · 19:00'), findsOneWidget);
    expect(find.text('Rajamangala Stadium'), findsOneWidget);
    expect(find.text('498 / 500'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('฿4,500'), findsOneWidget);
  });

  testWidgets(
      'concert detail resolves relative image URLs against host base URL',
      (tester) async {
    await _setPhoneSurface(tester);
    final repository = _FakeConcertRepository(
      concert: _concert(image: '/images/concert-1.png'),
    );

    await tester.pumpWidget(_app(repository: repository));
    await tester.pump();

    final image = tester.widget<Image>(find.byType(Image).first);
    final provider = image.image as NetworkImage;
    expect(provider.url, 'http://test/images/concert-1.png');
  });

  testWidgets('concert detail header pops back to concerts', (tester) async {
    await _setPhoneSurface(tester);
    final repository = _FakeConcertRepository(concert: _concert());

    await tester.pumpWidget(
      _app(
        repository: repository,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ConcertDetailScreen(concertId: 1),
                  ),
                ),
                child: const Text('Open detail'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open detail'));
    await tester.pumpAndSettle();
    expect(find.text('Concerts'), findsOneWidget);

    await tester.tap(find.text('Concerts'));
    await tester.pumpAndSettle();

    expect(find.text('Open detail'), findsOneWidget);
  });

  testWidgets('concert detail quantity controls update total', (tester) async {
    await _setPhoneSurface(tester);
    final repository = _FakeConcertRepository(
      concert: _concert(price: 4500, availableSeats: 3),
    );

    await tester.pumpWidget(_app(repository: repository));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
    expect(find.text('฿9,000'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    expect(find.text('฿4,500'), findsOneWidget);
  });

  testWidgets('concert detail books selected quantity and pops on success',
      (tester) async {
    await _setPhoneSurface(tester);
    final repository = _FakeConcertRepository(
      concert: _concert(price: 4500, availableSeats: 3),
    );

    await tester.pumpWidget(
      _app(
        repository: repository,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ConcertDetailScreen(concertId: 1),
                  ),
                ),
                child: const Text('Open detail'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open detail'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    await tester.tap(find.text('Book Now'));
    await tester.pumpAndSettle();

    expect(repository.bookingCalls, <String>['1:2']);
    expect(find.text('Open detail'), findsOneWidget);
  });

  testWidgets('concert detail disables booking when sold out', (tester) async {
    await _setPhoneSurface(tester);
    final repository = _FakeConcertRepository(
      concert: _concert(availableSeats: 0),
    );

    await tester.pumpWidget(_app(repository: repository));
    await tester.pump();

    expect(find.text('0 / 500'), findsOneWidget);
    expect(find.text('Sold out'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.tap(find.text('Sold out'));
    await tester.pump();

    expect(find.text('2'), findsNothing);
    expect(repository.bookingCalls, isEmpty);
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
  required _FakeConcertRepository repository,
  Widget home = const ConcertDetailScreen(concertId: 1),
}) {
  return ProviderScope(
    overrides: <Override>[
      concertHostProvider.overrideWithValue(_StubHost()),
      concertDetailViewModelProvider.overrideWith((ref, concertId) {
        final viewModel = ConcertDetailViewModel(
          concertId: concertId,
          getConcertDetail: GetConcertDetailUseCase(repository),
          createBooking: CreateBookingUseCase(repository),
          validateBookingQuantity: const ValidateBookingQuantityUseCase(),
        );
        viewModel.load();
        return viewModel;
      }),
    ],
    child: MaterialApp(home: home),
  );
}

class _FakeConcertRepository implements ConcertRepository {
  _FakeConcertRepository({
    Concert? concert,
    Completer<Concert>? concertCompleter,
  })  : _concert = concert,
        _concertCompleter = concertCompleter;

  final Concert? _concert;
  final Completer<Concert>? _concertCompleter;
  final bookingCalls = <String>[];

  @override
  Future<Booking> createBooking({
    required int concertId,
    required int quantity,
  }) async {
    bookingCalls.add('$concertId:$quantity');
    final concert = _concert ?? await _concertCompleter!.future;
    return Booking(
      id: 55,
      concert: concert,
      quantity: quantity,
      total: concert.price * quantity,
      createdAt: DateTime(2026, 7, 12),
    );
  }

  @override
  Future<List<Booking>> getBookings() {
    throw UnimplementedError();
  }

  @override
  Future<Concert> getConcert(int id) {
    final concert = _concert;
    if (concert != null) {
      return Future<Concert>.value(concert);
    }
    return _concertCompleter!.future;
  }

  @override
  Future<List<Concert>> getConcerts() {
    throw UnimplementedError();
  }
}

Concert _concert({
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
    id: 1,
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
