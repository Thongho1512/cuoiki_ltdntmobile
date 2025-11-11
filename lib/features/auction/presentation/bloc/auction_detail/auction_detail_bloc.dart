import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_bid_history_usecase.dart';
import '../../../domain/usecases/place_bid_usecase.dart';
import '../../../domain/usecases/watch_auction_usecase.dart';
import 'auction_detail_event.dart';
import 'auction_detail_state.dart';

class AuctionDetailBloc extends Bloc<AuctionDetailEvent, AuctionDetailState> {
  final WatchAuctionUseCase watchAuctionUseCase;
  final PlaceBidUseCase placeBidUseCase;
  final GetBidHistoryUseCase getBidHistoryUseCase;

  StreamSubscription? _auctionSubscription;

  AuctionDetailBloc({
    required this.watchAuctionUseCase,
    required this.placeBidUseCase,
    required this.getBidHistoryUseCase,
  }) : super(AuctionDetailInitial()) {
    on<AuctionDetailLoadRequested>(_onLoadRequested);
    on<AuctionDetailWatchStarted>(_onWatchStarted);
    on<AuctionDetailUpdated>(_onUpdated);
    on<AuctionDetailPlaceBidRequested>(_onPlaceBidRequested);
  }

  Future<void> _onLoadRequested(
    AuctionDetailLoadRequested event,
    Emitter<AuctionDetailState> emit,
  ) async {
    emit(AuctionDetailLoading());
    add(AuctionDetailWatchStarted(event.auctionId));
  }

  void _onWatchStarted(
    AuctionDetailWatchStarted event,
    Emitter<AuctionDetailState> emit,
  ) {
    _auctionSubscription?.cancel();

    _auctionSubscription = watchAuctionUseCase(event.auctionId).listen(
      (auction) {
        add(AuctionDetailUpdated(auction));
      },
      onError: (error) {
        emit(AuctionDetailError('Không thể tải thông tin đấu giá'));
      },
    );
  }

  Future<void> _onUpdated(
    AuctionDetailUpdated event,
    Emitter<AuctionDetailState> emit,
  ) async {
    final bidHistoryResult = await getBidHistoryUseCase(event.auction.id);

    bidHistoryResult.fold(
      (failure) => emit(AuctionDetailLoaded(auction: event.auction)),
      (bidHistory) => emit(
        AuctionDetailLoaded(auction: event.auction, bidHistory: bidHistory),
      ),
    );
  }

  Future<void> _onPlaceBidRequested(
    AuctionDetailPlaceBidRequested event,
    Emitter<AuctionDetailState> emit,
  ) async {
    if (state is! AuctionDetailLoaded) return;

    final currentState = state as AuctionDetailLoaded;
    emit(currentState.copyWith(isPlacingBid: true));

    final result = await placeBidUseCase(currentState.auction.id, event.amount);

    result.fold(
      (failure) {
        emit(AuctionDetailBidError(failure.message, currentState.auction));
        emit(currentState.copyWith(isPlacingBid: false));
      },
      (_) {
        emit(AuctionDetailBidSuccess('Đấu giá thành công!'));
        emit(currentState.copyWith(isPlacingBid: false));
      },
    );
  }

  @override
  Future<void> close() {
    _auctionSubscription?.cancel();
    return super.close();
  }
}
