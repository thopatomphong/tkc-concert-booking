import 'package:concert_mini_app/src/booking/booking_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('quantity of zero is rejected', () {
    expect(validateBookingQuantity(0, availableSeats: 100), isNotNull);
  });

  test('negative quantity is rejected', () {
    expect(validateBookingQuantity(-1, availableSeats: 100), isNotNull);
  });

  test('quantity above available seats is rejected', () {
    expect(validateBookingQuantity(5, availableSeats: 4), isNotNull);
  });

  test('quantity equal to available seats is accepted', () {
    expect(validateBookingQuantity(4, availableSeats: 4), isNull);
  });

  test('a valid quantity returns null (no error)', () {
    expect(validateBookingQuantity(2, availableSeats: 100), isNull);
  });

  test('booking when sold out is rejected', () {
    expect(validateBookingQuantity(1, availableSeats: 0), isNotNull);
  });
}
