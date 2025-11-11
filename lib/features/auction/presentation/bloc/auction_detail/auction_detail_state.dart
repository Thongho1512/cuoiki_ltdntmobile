import 'package:equatable/equatable.dart';
import '../../../domain/entities/auction_item_entity.dart';
import '../../../domain/entities/bid_entity.dart';

abstract class AuctionDetailState extends Equatable {
  const AuctionDetailState();

  @override
  List<Object?> get props => [];
}

class AuctionDetailInitial extends AuctionDetailState {}

class AuctionDetailLoading extends AuctionDetailState {}

class AuctionDetailLoaded extends AuctionDetailState {
  final AuctionItemEntity auction;
  final List<BidEntity> bidHistory;
  final bool isPlacingBid;

  const AuctionDetailLoaded({
    required this.auction,
    this.bidHistory = const [],
    this.isPlacingBid = false,
  });

  AuctionDetailLoaded copyWith({
    AuctionItemEntity? auction,
    List<BidEntity>? bidHistory,
    bool? isPlacingBid,
  }) {
    return AuctionDetailLoaded(
      auction: auction ?? this.auction,
      bidHistory: bidHistory ?? this.bidHistory,
      isPlacingBid: isPlacingBid ?? this.isPlacingBid,
    );
  }

  @override
  List<Object?> get props => [auction, bidHistory, isPlacingBid];
}

class AuctionDetailError extends AuctionDetailState {
  final String message;

  const AuctionDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuctionDetailBidSuccess extends AuctionDetailState {
  final String message;

  const AuctionDetailBidSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AuctionDetailBidError extends AuctionDetailState {
  final String message;
  final AuctionItemEntity auction;

  const AuctionDetailBidError(this.message, this.auction);

  @override
  List<Object?> get props => [message, auction];
}
