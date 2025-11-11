import 'package:equatable/equatable.dart';

class BidEntity extends Equatable {
  final String id;
  final String auctionId;
  final String bidderId;
  final String bidderName;
  final int amount;
  final DateTime timestamp;
  final bool isWinning;

  const BidEntity({
    required this.id,
    required this.auctionId,
    required this.bidderId,
    required this.bidderName,
    required this.amount,
    required this.timestamp,
    this.isWinning = false,
  });

  @override
  List<Object?> get props => [
    id,
    auctionId,
    bidderId,
    bidderName,
    amount,
    timestamp,
    isWinning,
  ];
}
