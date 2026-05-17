class ValidateBookingQuantityUseCase {
  const ValidateBookingQuantityUseCase();

  String? call(int quantity, {required int availableSeats}) {
    if (quantity < 1) {
      return 'Choose at least 1 ticket';
    }
    if (availableSeats <= 0) {
      return 'This concert is sold out';
    }
    if (quantity > availableSeats) {
      return 'Only $availableSeats seat(s) left';
    }
    return null;
  }
}
