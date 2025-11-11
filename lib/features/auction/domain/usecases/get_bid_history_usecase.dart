import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/bid_entity.dart';
import '../repositories/auction_repository.dart';

class GetBidHistoryUseCase {
  final AuctionRepository repository;

  GetBidHistoryUseCase(this.repository);

  Future<Either<Failure, List<BidEntity>>> call(String auctionId) {
    return repository.getBidHistory(auctionId);
  }
}
