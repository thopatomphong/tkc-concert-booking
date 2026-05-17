import 'package:concert_mini_app/src/domain/entities/concert.dart';
import 'package:concert_mini_app/src/domain/use_cases/get_concerts_use_case.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ConcertListViewModel extends StateNotifier<AsyncValue<List<Concert>>> {
  ConcertListViewModel(this._getConcerts)
      : super(const AsyncValue<List<Concert>>.loading());

  final GetConcertsUseCase _getConcerts;

  Future<void> load() async {
    state = const AsyncValue<List<Concert>>.loading();
    state = await AsyncValue.guard(() => _getConcerts());
  }
}
