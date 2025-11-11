import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/auction_item_entity.dart';
import '../../domain/entities/bid_entity.dart';
import '../../domain/repositories/auction_repository.dart';
import '../datasources/auction_remote_datasource.dart';

class AuctionRepositoryImpl implements AuctionRepository {
  final AuctionRemoteDataSource remoteDataSource;
  final FirebaseAuth firebaseAuth;

  AuctionRepositoryImpl({
    required this.remoteDataSource,
    required this.firebaseAuth,
  });

  @override
  Future<Either<Failure, List<AuctionItemEntity>>> getAuctions() async {
    try {
      final auctions = await remoteDataSource.getAuctions();
      return Right(auctions);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, AuctionItemEntity>> getAuctionById(String id) async {
    try {
      final auction = await remoteDataSource.getAuctionById(id);
      return Right(auction);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Stream<AuctionItemEntity> watchAuction(String id) {
    return remoteDataSource.watchAuction(id);
  }

  @override
  Future<Either<Failure, void>> placeBid(String auctionId, int amount) async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        return Left(AuthFailure('Vui lòng đăng nhập'));
      }

      final displayName = currentUser.displayName ?? 'Unknown';
      await remoteDataSource.placeBid(auctionId, amount, displayName);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, List<BidEntity>>> getBidHistory(
    String auctionId,
  ) async {
    try {
      final bids = await remoteDataSource.getBidHistory(auctionId);
      return Right(bids);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Stream<List<BidEntity>> watchBidHistory(String auctionId) {
    return remoteDataSource.watchBidHistory(auctionId);
  }
}
