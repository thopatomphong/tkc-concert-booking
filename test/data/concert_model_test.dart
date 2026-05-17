import 'package:concert_mini_app/src/models/concert.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Concert parses the documented shape', () {
    final json = <String, dynamic>{
      'id': 1,
      'name': 'BORN PINK World Tour Bangkok',
      'artist': 'BLACKPINK',
      'venue': 'Rajamangala',
      'location': 'Bangkok',
      'date': '2026-07-12',
      'time': '19:00',
      'price': 4500,
      'totalSeats': 500,
      'availableSeats': 498,
      'image': 'http://x/born-pink.png',
    };
    final concert = Concert.fromJson(json);
    expect(concert.artist, 'BLACKPINK');
    expect(concert.availableSeats, 498);
  });
}
