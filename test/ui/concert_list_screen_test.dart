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
  @override
  Dio get httpClient => Dio(BaseOptions(baseUrl: 'http://test'));

  @override
  String get apiBaseUrl => 'http://test';

  @override
  void onExit() {}
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
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          concertHostProvider.overrideWithValue(_StubHost()),
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

    expect(find.text('Concert 1'), findsOneWidget);
    expect(find.textContaining('20 seats left'), findsOneWidget);
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
