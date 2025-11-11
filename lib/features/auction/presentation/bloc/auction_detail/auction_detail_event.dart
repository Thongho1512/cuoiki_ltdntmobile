import 'package:equatable/equatable.dart';
import '../../../domain/entities/auction_item_entity.dart';

abstract class AuctionDetailEvent extends Equatable {
  const AuctionDetailEvent();

  @override
  List<Object?> get props => [];
}

class AuctionDetailLoadRequested extends AuctionDetailEvent {
  final String auctionId;

  const AuctionDetailLoadRequested(this.auctionId);

  @override
  List<Object?> get props => [auctionId];
}

class AuctionDetailWatchStarted extends AuctionDetailEvent {
  final String auctionId;

  const AuctionDetailWatchStarted(this.auctionId);

  @override
  List<Object?> get props => [auctionId];
}

class AuctionDetailUpdated extends AuctionDetailEvent {
  final AuctionItemEntity auction;

  const AuctionDetailUpdated(this.auction);

  @override
  List<Object?> get props => [auction];
}

class AuctionDetailPlaceBidRequested extends AuctionDetailEvent {
  final int amount;

  const AuctionDetailPlaceBidRequested(this.amount);

  @override
  List<Object?> get props => [amount];
}
