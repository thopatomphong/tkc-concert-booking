import 'package:concert_mini_app/src/domain/entities/booking.dart';
import 'package:concert_mini_app/src/domain/use_cases/get_my_bookings_use_case.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MyBookingsViewModel extends StateNotifier<AsyncValue<List<Booking>>> {
  MyBookingsViewModel(this._getMyBookings)
      : super(const AsyncValue<List<Booking>>.loading());

  final GetMyBookingsUseCase _getMyBookings;

  Future<void> load() async {
    state = const AsyncValue<List<Booking>>.loading();
    state = await AsyncValue.guard(() => _getMyBookings());
  }
}
