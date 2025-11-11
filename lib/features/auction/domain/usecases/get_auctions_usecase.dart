import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auction_item_entity.dart';
import '../repositories/auction_repository.dart';

class GetAuctionsUseCase {
  final AuctionRepository repository;

  GetAuctionsUseCase(this.repository);

  Future<Either<Failure, List<AuctionItemEntity>>> call() {
    return repository.getAuctions();
  }
}
