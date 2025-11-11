import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/bid_entity.dart';

class BidModel extends BidEntity {
  const BidModel({
    required super.id,
    required super.auctionId,
    required super.bidderId,
    required super.bidderName,
    required super.amount,
    required super.timestamp,
    super.isWinning,
  });

  factory BidModel.fromEntity(BidEntity entity) {
    return BidModel(
      id: entity.id,
      auctionId: entity.auctionId,
      bidderId: entity.bidderId,
      bidderName: entity.bidderName,
      amount: entity.amount,
      timestamp: entity.timestamp,
      isWinning: entity.isWinning,
    );
  }

  factory BidModel.fromJson(Map<String, dynamic> json, String id) {
    return BidModel(
      id: id,
      auctionId: json['auctionId'] as String,
      bidderId: json['bidderId'] as String,
      bidderName: json['bidderName'] as String,
      amount: json['amount'] as int,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      isWinning: json['isWinning'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'auctionId': auctionId,
      'bidderId': bidderId,
      'bidderName': bidderName,
      'amount': amount,
      'timestamp': Timestamp.fromDate(timestamp),
      'isWinning': isWinning,
    };
  }
}
