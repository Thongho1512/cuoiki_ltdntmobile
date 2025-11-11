import '../entities/auction_item_entity.dart';
import '../repositories/auction_repository.dart';

class WatchAuctionUseCase {
  final AuctionRepository repository;

  WatchAuctionUseCase(this.repository);

  Stream<AuctionItemEntity> call(String id) {
    return repository.watchAuction(id);
  }
}
