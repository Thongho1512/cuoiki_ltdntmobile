import 'package:equatable/equatable.dart';

enum AuctionStatus { active, ended, cancelled }

class AuctionItemEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int startingPrice;
  final int currentPrice;
  final String? highestBidderId;
  final String? highestBidderName;
  final DateTime startTime;
  final DateTime endTime;
  final AuctionStatus status;
  final String sellerId;
  final String sellerName;
  final int totalBids;
  final DateTime createdAt;

  const AuctionItemEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.startingPrice,
    required this.currentPrice,
    this.highestBidderId,
    this.highestBidderName,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.sellerId,
    required this.sellerName,
    this.totalBids = 0,
    required this.createdAt,
  });

  bool get isActive =>
      status == AuctionStatus.active && DateTime.now().isBefore(endTime);
  bool get hasEnded =>
      DateTime.now().isAfter(endTime) || status == AuctionStatus.ended;

  Duration get timeRemaining {
    if (hasEnded) return Duration.zero;
    return endTime.difference(DateTime.now());
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    imageUrl,
    startingPrice,
    currentPrice,
    highestBidderId,
    highestBidderName,
    startTime,
    endTime,
    status,
    sellerId,
    sellerName,
    totalBids,
    createdAt,
  ];
}
