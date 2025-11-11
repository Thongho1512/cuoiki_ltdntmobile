import 'package:equatable/equatable.dart';

abstract class AuctionListEvent extends Equatable {
  const AuctionListEvent();

  @override
  List<Object?> get props => [];
}

class AuctionListLoadRequested extends AuctionListEvent {}

class AuctionListRefreshRequested extends AuctionListEvent {}
