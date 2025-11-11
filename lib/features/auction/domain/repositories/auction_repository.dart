import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auction_item_entity.dart';
import '../entities/bid_entity.dart';

abstract class AuctionRepository {
  Future<Either<Failure, List<AuctionItemEntity>>> getAuctions();
  Future<Either<Failure, AuctionItemEntity>> getAuctionById(String id);
  Stream<AuctionItemEntity> watchAuction(String id);
  Future<Either<Failure, void>> placeBid(String auctionId, int amount);
  Future<Either<Failure, List<BidEntity>>> getBidHistory(String auctionId);
  Stream<List<BidEntity>> watchBidHistory(String auctionId);
}
