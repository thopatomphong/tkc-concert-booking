import 'package:concert_mini_app/src/domain/use_cases/validate_booking_quantity_use_case.dart';

/// Compatibility helper for existing callers. New code should depend on
/// [ValidateBookingQuantityUseCase] from the domain layer.
String? validateBookingQuantity(int quantity, {required int availableSeats}) {
  return const ValidateBookingQuantityUseCase()(
    quantity,
    availableSeats: availableSeats,
  );
}
