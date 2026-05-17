/// Thrown when the server rejects a booking because seats are unavailable.
class SeatsUnavailableException implements Exception {
  const SeatsUnavailableException(this.message);

  final String message;

  @override
  String toString() => message;
}
