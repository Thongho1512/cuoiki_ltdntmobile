import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_auctions_usecase.dart';
import 'auction_list_event.dart';
import 'auction_list_state.dart';

class AuctionListBloc extends Bloc<AuctionListEvent, AuctionListState> {
  final GetAuctionsUseCase getAuctionsUseCase;

  AuctionListBloc({required this.getAuctionsUseCase})
    : super(AuctionListInitial()) {
    on<AuctionListLoadRequested>(_onLoadRequested);
    on<AuctionListRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    AuctionListLoadRequested event,
    Emitter<AuctionListState> emit,
  ) async {
    emit(AuctionListLoading());

    final result = await getAuctionsUseCase();

    result.fold(
      (failure) => emit(AuctionListError(failure.message)),
      (auctions) => emit(AuctionListLoaded(auctions)),
    );
  }

  Future<void> _onRefreshRequested(
    AuctionListRefreshRequested event,
    Emitter<AuctionListState> emit,
  ) async {
    final result = await getAuctionsUseCase();

    result.fold(
      (failure) => emit(AuctionListError(failure.message)),
      (auctions) => emit(AuctionListLoaded(auctions)),
    );
  }
}
