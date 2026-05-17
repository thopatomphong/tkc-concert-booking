import 'package:concert_mini_app/src/domain/entities/concert.dart';
import 'package:concert_mini_app/src/domain/repositories/concert_repository.dart';

class GetConcertDetailUseCase {
  const GetConcertDetailUseCase(this._repository);

  final ConcertRepository _repository;

  Future<Concert> call(int id) => _repository.getConcert(id);
}
