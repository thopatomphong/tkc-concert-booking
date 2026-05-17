import 'package:freezed_annotation/freezed_annotation.dart';

part 'concert.freezed.dart';
part 'concert.g.dart';

@freezed
class Concert with _$Concert {
  const factory Concert({
    required int id,
    required String name,
    required String artist,
    required String venue,
    required String location,
    required String date,
    required String time,
    required int price,
    required int totalSeats,
    required int availableSeats,
    required String image,
  }) = _Concert;

  factory Concert.fromJson(Map<String, dynamic> json) =>
      _$ConcertFromJson(json);
}
