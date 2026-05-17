import 'package:concert_mini_app/src/di/concert_dependencies.dart';
import 'package:concert_mini_app/src/domain/entities/booking.dart';
import 'package:concert_mini_app/src/domain/entities/concert.dart';
import 'package:concert_mini_app/src/presentation/view_models/concert_detail_view_model.dart';
import 'package:concert_mini_app/src/presentation/view_models/concert_list_view_model.dart';
import 'package:concert_mini_app/src/presentation/view_models/my_bookings_view_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final concertListViewModelProvider =
    StateNotifierProvider<ConcertListViewModel, AsyncValue<List<Concert>>>(
  (ref) {
    final viewModel = ConcertListViewModel(
      ref.watch(getConcertsUseCaseProvider),
    );
    viewModel.load();
    return viewModel;
  },
);

final concertDetailViewModelProvider = StateNotifierProvider.family<
    ConcertDetailViewModel, ConcertDetailState, int>(
  (ref, concertId) {
    final viewModel = ConcertDetailViewModel(
      concertId: concertId,
      getConcertDetail: ref.watch(getConcertDetailUseCaseProvider),
      createBooking: ref.watch(createBookingUseCaseProvider),
      validateBookingQuantity:
          ref.watch(validateBookingQuantityUseCaseProvider),
    );
    viewModel.load();
    return viewModel;
  },
);

final myBookingsViewModelProvider =
    StateNotifierProvider<MyBookingsViewModel, AsyncValue<List<Booking>>>(
  (ref) {
    final viewModel = MyBookingsViewModel(
      ref.watch(getMyBookingsUseCaseProvider),
    );
    viewModel.load();
    return viewModel;
  },
);
