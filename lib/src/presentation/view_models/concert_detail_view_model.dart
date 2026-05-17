import 'package:concert_mini_app/src/domain/entities/booking.dart';
import 'package:concert_mini_app/src/domain/entities/concert.dart';
import 'package:concert_mini_app/src/domain/use_cases/create_booking_use_case.dart';
import 'package:concert_mini_app/src/domain/use_cases/get_concert_detail_use_case.dart';
import 'package:concert_mini_app/src/domain/use_cases/validate_booking_quantity_use_case.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ConcertDetailViewModel extends StateNotifier<ConcertDetailState> {
  ConcertDetailViewModel({
    required int concertId,
    required GetConcertDetailUseCase getConcertDetail,
    required CreateBookingUseCase createBooking,
    required ValidateBookingQuantityUseCase validateBookingQuantity,
  })  : _concertId = concertId,
        _getConcertDetail = getConcertDetail,
        _createBooking = createBooking,
        _validateBookingQuantity = validateBookingQuantity,
        super(const ConcertDetailState());

  final int _concertId;
  final GetConcertDetailUseCase _getConcertDetail;
  final CreateBookingUseCase _createBooking;
  final ValidateBookingQuantityUseCase _validateBookingQuantity;

  Future<void> load() async {
    state = state.copyWith(concert: const AsyncValue<Concert>.loading());
    final concert = await AsyncValue.guard(() => _getConcertDetail(_concertId));
    state = state.copyWith(
      concert: concert,
      quantity: _clampQuantity(state.quantity, concert.valueOrNull),
    );
  }

  void setQuantity(int quantity) {
    state = state.copyWith(quantity: quantity);
  }

  void incrementQuantity() {
    final concert = state.concert.valueOrNull;
    if (concert == null || state.quantity >= concert.availableSeats) {
      return;
    }
    state = state.copyWith(quantity: state.quantity + 1);
  }

  void decrementQuantity() {
    if (state.quantity <= 1) {
      return;
    }
    state = state.copyWith(quantity: state.quantity - 1);
  }

  Future<BookingResult> book() async {
    final concert = state.concert.valueOrNull;
    if (concert == null) {
      return const BookingFailure('Booking failed: concert unavailable');
    }

    final validationMessage = _validateBookingQuantity(
      state.quantity,
      availableSeats: concert.availableSeats,
    );
    if (validationMessage != null) {
      return BookingValidationFailure(validationMessage);
    }

    state = state.copyWith(isBooking: true);
    try {
      final booking = await _createBooking(
        concertId: concert.id,
        quantity: state.quantity,
      );
      return BookingSuccess(booking);
    } catch (error) {
      return BookingFailure('Booking failed: $error');
    } finally {
      state = state.copyWith(isBooking: false);
    }
  }

  int _clampQuantity(int quantity, Concert? concert) {
    if (concert == null) {
      return quantity;
    }
    if (concert.availableSeats <= 0) {
      return 1;
    }
    return quantity.clamp(1, concert.availableSeats);
  }
}

class ConcertDetailState {
  const ConcertDetailState({
    this.concert = const AsyncValue<Concert>.loading(),
    this.quantity = 1,
    this.isBooking = false,
  });

  final AsyncValue<Concert> concert;
  final int quantity;
  final bool isBooking;

  ConcertDetailState copyWith({
    AsyncValue<Concert>? concert,
    int? quantity,
    bool? isBooking,
  }) {
    return ConcertDetailState(
      concert: concert ?? this.concert,
      quantity: quantity ?? this.quantity,
      isBooking: isBooking ?? this.isBooking,
    );
  }
}

sealed class BookingResult {
  const BookingResult();
}

class BookingSuccess extends BookingResult {
  const BookingSuccess(this.booking);

  final Booking booking;
}

class BookingValidationFailure extends BookingResult {
  const BookingValidationFailure(this.message);

  final String message;
}

class BookingFailure extends BookingResult {
  const BookingFailure(this.message);

  final String message;
}
