import 'package:concert_mini_app/src/domain/entities/concert.dart';
import 'package:concert_mini_app/src/domain/repositories/concert_repository.dart';

class GetConcertsUseCase {
  const GetConcertsUseCase(this._repository);

  final ConcertRepository _repository;

  Future<List<Concert>> call() => _repository.getConcerts();
}
