import 'package:equatable/equatable.dart';
import '../../../domain/entities/auction_item_entity.dart';

abstract class AuctionListState extends Equatable {
  const AuctionListState();

  @override
  List<Object?> get props => [];
}

class AuctionListInitial extends AuctionListState {}

class AuctionListLoading extends AuctionListState {}

class AuctionListLoaded extends AuctionListState {
  final List<AuctionItemEntity> auctions;

  const AuctionListLoaded(this.auctions);

  @override
  List<Object?> get props => [auctions];
}

class AuctionListError extends AuctionListState {
  final String message;

  const AuctionListError(this.message);

  @override
  List<Object?> get props => [message];
}
