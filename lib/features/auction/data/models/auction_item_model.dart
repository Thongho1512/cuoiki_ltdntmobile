import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/auction_item_entity.dart';

class AuctionItemModel extends AuctionItemEntity {
  const AuctionItemModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imageUrl,
    required super.startingPrice,
    required super.currentPrice,
    super.highestBidderId,
    super.highestBidderName,
    required super.startTime,
    required super.endTime,
    required super.status,
    required super.sellerId,
    required super.sellerName,
    super.totalBids,
    required super.createdAt,
  });

  factory AuctionItemModel.fromEntity(AuctionItemEntity entity) {
    return AuctionItemModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      imageUrl: entity.imageUrl,
      startingPrice: entity.startingPrice,
      currentPrice: entity.currentPrice,
      highestBidderId: entity.highestBidderId,
      highestBidderName: entity.highestBidderName,
      startTime: entity.startTime,
      endTime: entity.endTime,
      status: entity.status,
      sellerId: entity.sellerId,
      sellerName: entity.sellerName,
      totalBids: entity.totalBids,
      createdAt: entity.createdAt,
    );
  }

  factory AuctionItemModel.fromJson(Map<String, dynamic> json, String id) {
    return AuctionItemModel(
      id: id,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      startingPrice: json['startingPrice'] as int,
      currentPrice: json['currentPrice'] as int,
      highestBidderId: json['highestBidderId'] as String?,
      highestBidderName: json['highestBidderName'] as String?,
      startTime: (json['startTime'] as Timestamp).toDate(),
      endTime: (json['endTime'] as Timestamp).toDate(),
      status: _statusFromString(json['status'] as String),
      sellerId: json['sellerId'] as String,
      sellerName: json['sellerName'] as String,
      totalBids: json['totalBids'] as int? ?? 0,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'startingPrice': startingPrice,
      'currentPrice': currentPrice,
      'highestBidderId': highestBidderId,
      'highestBidderName': highestBidderName,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'status': _statusToString(status),
      'sellerId': sellerId,
      'sellerName': sellerName,
      'totalBids': totalBids,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static AuctionStatus _statusFromString(String status) {
    switch (status) {
      case 'active':
        return AuctionStatus.active;
      case 'ended':
        return AuctionStatus.ended;
      case 'cancelled':
        return AuctionStatus.cancelled;
      default:
        return AuctionStatus.active;
    }
  }

  static String _statusToString(AuctionStatus status) {
    switch (status) {
      case AuctionStatus.active:
        return 'active';
      case AuctionStatus.ended:
        return 'ended';
      case AuctionStatus.cancelled:
        return 'cancelled';
    }
  }
}
