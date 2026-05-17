import 'dart:async';

import 'package:concert_mini_app/src/concert_host.dart';
import 'package:concert_mini_app/src/domain/entities/booking.dart';
import 'package:concert_mini_app/src/domain/entities/concert.dart';
import 'package:concert_mini_app/src/domain/repositories/concert_repository.dart';
import 'package:concert_mini_app/src/domain/use_cases/get_concerts_use_case.dart';
import 'package:concert_mini_app/src/host_provider.dart';
import 'package:concert_mini_app/src/presentation/providers/concert_view_model_providers.dart';
import 'package:concert_mini_app/src/presentation/view_models/concert_list_view_model.dart';
import 'package:concert_mini_app/src/ui/concert_list_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class _StubHost implements ConcertHost {
  var exitCalls = 0;

  @override
  Dio get httpClient => Dio(BaseOptions(baseUrl: 'http://test'));

  @override
  String get apiBaseUrl => 'http://test';

  @override
  void onExit() {
    exitCalls += 1;
  }
}

void main() {
  testWidgets('concert list shows a spinner while loading', (tester) async {
    final pendingConcerts = Completer<List<Concert>>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          concertHostProvider.overrideWithValue(_StubHost()),
          concertListViewModelProvider.overrideWith((ref) {
            final viewModel = ConcertListViewModel(
              GetConcertsUseCase(_FakeConcertRepository(pendingConcerts)),
            );
            viewModel.load();
            return viewModel;
          }),
        ],
        child: const MaterialApp(home: ConcertListScreen()),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('concert list shows an empty state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          concertHostProvider.overrideWithValue(_StubHost()),
          concertListViewModelProvider.overrideWith((ref) {
            final viewModel = ConcertListViewModel(
              GetConcertsUseCase(_ImmediateConcertRepository(<Concert>[])),
            );
            viewModel.load();
            return viewModel;
          }),
        ],
        child: const MaterialApp(home: ConcertListScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('No concerts available'), findsOneWidget);
  });

  testWidgets('concert list renders loaded concert data', (tester) async {
    final host = _StubHost();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          concertHostProvider.overrideWithValue(host),
          concertListViewModelProvider.overrideWith((ref) {
            final viewModel = ConcertListViewModel(
              GetConcertsUseCase(_ImmediateConcertRepository(<Concert>[
                _concert(
                  1,
                  name: 'BORN PINK World Tour Bangkok',
                  artist: 'BLACKPINK',
                  venue: 'Rajamangala Stadium',
                  price: 4500,
                  availableSeats: 498,
                ),
              ])),
            );
            viewModel.load();
            return viewModel;
          }),
        ],
        child: const MaterialApp(home: ConcertListScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('BORN PINK World Tour Bangkok'), findsOneWidget);
    expect(find.text('BLACKPINK'), findsOneWidget);
    expect(find.text('Jul 12, 2026 · 19:00'), findsOneWidget);
    expect(find.text('Rajamangala Stadium'), findsOneWidget);
    expect(find.text('฿4,500'), findsOneWidget);
    expect(find.text('498 seats left'), findsOneWidget);
  });

  testWidgets('concert list header exits home and opens bookings',
      (tester) async {
    final host = _StubHost();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          concertHostProvider.overrideWithValue(host),
          concertListViewModelProvider.overrideWith((ref) {
            final viewModel = ConcertListViewModel(
              GetConcertsUseCase(_ImmediateConcertRepository(<Concert>[
                _concert(1),
              ])),
            );
            viewModel.load();
            return viewModel;
          }),
        ],
        child: const MaterialApp(home: ConcertListScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Home'));
    expect(host.exitCalls, 1);

    await tester.tap(find.text('My Bookings'));
    await tester.pumpAndSettle();
    expect(find.text('My Bookings'), findsOneWidget);
  });

  testWidgets('concert list resolves relative image URLs against host base URL',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          concertHostProvider.overrideWithValue(_StubHost()),
          concertListViewModelProvider.overrideWith((ref) {
            final viewModel = ConcertListViewModel(
              GetConcertsUseCase(_ImmediateConcertRepository(<Concert>[
                _concert(1, image: '/images/concert-1.png'),
              ])),
            );
            viewModel.load();
            return viewModel;
          }),
        ],
        child: const MaterialApp(home: ConcertListScreen()),
      ),
    );
    await tester.pump();

    final image = tester.widget<Image>(find.byType(Image).first);
    final provider = image.image as NetworkImage;
    expect(provider.url, 'http://test/images/concert-1.png');
  });
}

class _FakeConcertRepository implements ConcertRepository {
  const _FakeConcertRepository(this._concerts);

  final Completer<List<Concert>> _concerts;

  @override
  Future<Booking> createBooking({
    required int concertId,
    required int quantity,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<Booking>> getBookings() {
    throw UnimplementedError();
  }

  @override
  Future<Concert> getConcert(int id) {
    throw UnimplementedError();
  }

  @override
  Future<List<Concert>> getConcerts() => _concerts.future;
}

class _ImmediateConcertRepository implements ConcertRepository {
  const _ImmediateConcertRepository(this._concerts);

  final List<Concert> _concerts;

  @override
  Future<Booking> createBooking({
    required int concertId,
    required int quantity,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<Booking>> getBookings() {
    throw UnimplementedError();
  }

  @override
  Future<Concert> getConcert(int id) {
    throw UnimplementedError();
  }

  @override
  Future<List<Concert>> getConcerts() async => _concerts;
}

Concert _concert(
  int id, {
  String? name,
  String? artist,
  String? venue,
  int? price,
  int? availableSeats,
  String? image,
}) {
  return Concert(
    id: id,
    name: name ?? 'Concert $id',
    artist: artist ?? 'Artist',
    venue: venue ?? 'Venue',
    location: 'Bangkok',
    date: '2026-07-12',
    time: '19:00',
    price: price ?? 3000,
    totalSeats: 100,
    availableSeats: availableSeats ?? 20,
    image: image ?? 'http://test/concert-$id.png',
  );
}
