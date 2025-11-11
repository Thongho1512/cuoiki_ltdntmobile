import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auction_repository.dart';

class PlaceBidUseCase {
  final AuctionRepository repository;

  PlaceBidUseCase(this.repository);

  Future<Either<Failure, void>> call(String auctionId, int amount) {
    return repository.placeBid(auctionId, amount);
  }
}
