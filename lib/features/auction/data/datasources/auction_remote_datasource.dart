import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/auction_item_model.dart';
import '../models/bid_model.dart';

abstract class AuctionRemoteDataSource {
  Future<List<AuctionItemModel>> getAuctions();
  Future<AuctionItemModel> getAuctionById(String id);
  Stream<AuctionItemModel> watchAuction(String id);
  Future<void> placeBid(String auctionId, int amount, String bidderName);
  Future<List<BidModel>> getBidHistory(String auctionId);
  Stream<List<BidModel>> watchBidHistory(String auctionId);
}

class AuctionRemoteDataSourceImpl implements AuctionRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  AuctionRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  @override
  Future<List<AuctionItemModel>> getAuctions() async {
    try {
      final querySnapshot = await firestore
          .collection(FirebaseConstants.auctionsCollection)
          .orderBy(FirebaseConstants.createdAtField, descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AuctionItemModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException('Không thể tải danh sách đấu giá: ${e.toString()}');
    }
  }

  @override
  Future<AuctionItemModel> getAuctionById(String id) async {
    try {
      final docSnapshot = await firestore
          .collection(FirebaseConstants.auctionsCollection)
          .doc(id)
          .get();

      if (!docSnapshot.exists) {
        throw ServerException('Sản phẩm đấu giá không tồn tại');
      }

      return AuctionItemModel.fromJson(docSnapshot.data()!, docSnapshot.id);
    } catch (e) {
      throw ServerException('Không thể tải thông tin đấu giá: ${e.toString()}');
    }
  }

  @override
  Stream<AuctionItemModel> watchAuction(String id) {
    try {
      return firestore
          .collection(FirebaseConstants.auctionsCollection)
          .doc(id)
          .snapshots()
          .map((snapshot) {
            if (!snapshot.exists) {
              throw ServerException('Sản phẩm đấu giá không tồn tại');
            }
            return AuctionItemModel.fromJson(snapshot.data()!, snapshot.id);
          });
    } catch (e) {
      throw ServerException('Không thể theo dõi đấu giá: ${e.toString()}');
    }
  }

  @override
  Future<void> placeBid(String auctionId, int amount, String bidderName) async {
    try {
      final currentUser = firebaseAuth.currentUser;
      if (currentUser == null) {
        throw AuthException('Vui lòng đăng nhập để đấu giá');
      }

      final auctionRef = firestore
          .collection(FirebaseConstants.auctionsCollection)
          .doc(auctionId);

      await firestore.runTransaction((transaction) async {
        final auctionSnapshot = await transaction.get(auctionRef);

        if (!auctionSnapshot.exists) {
          throw ServerException('Sản phẩm đấu giá không tồn tại');
        }

        final auctionData = auctionSnapshot.data()!;
        final currentPrice =
            auctionData[FirebaseConstants.currentPriceField] as int;
        final endTime =
            (auctionData[FirebaseConstants.endTimeField] as Timestamp).toDate();

        if (DateTime.now().isAfter(endTime)) {
          throw ServerException('Cuộc đấu giá đã kết thúc');
        }

        if (amount <= currentPrice) {
          throw ServerException('Giá đấu phải cao hơn giá hiện tại');
        }

        final highestBidderId =
            auctionData[FirebaseConstants.highestBidderField] as String?;
        if (highestBidderId == currentUser.uid) {
          throw ServerException('Bạn đang là người đặt giá cao nhất');
        }

        // Update auction
        transaction.update(auctionRef, {
          FirebaseConstants.currentPriceField: amount,
          FirebaseConstants.highestBidderField: currentUser.uid,
          'highestBidderName': bidderName,
          'totalBids': FieldValue.increment(1),
        });

        // Create bid record
        final bidRef = firestore
            .collection(FirebaseConstants.bidsCollection)
            .doc();

        final bidModel = BidModel(
          id: bidRef.id,
          auctionId: auctionId,
          bidderId: currentUser.uid,
          bidderName: bidderName,
          amount: amount,
          timestamp: DateTime.now(),
          isWinning: true,
        );

        transaction.set(bidRef, bidModel.toJson());

        // Update previous winning bid
        if (highestBidderId != null) {
          final previousBidsQuery = await firestore
              .collection(FirebaseConstants.bidsCollection)
              .where('auctionId', isEqualTo: auctionId)
              .where('bidderId', isEqualTo: highestBidderId)
              .where('isWinning', isEqualTo: true)
              .get();

          for (var doc in previousBidsQuery.docs) {
            transaction.update(doc.reference, {'isWinning': false});
          }
        }

        // Update user statistics
        final userRef = firestore
            .collection(FirebaseConstants.usersCollection)
            .doc(currentUser.uid);

        transaction.update(userRef, {'totalBids': FieldValue.increment(1)});
      });
    } on AuthException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Không thể đặt giá: ${e.toString()}');
    }
  }

  @override
  Future<List<BidModel>> getBidHistory(String auctionId) async {
    try {
      final querySnapshot = await firestore
          .collection(FirebaseConstants.bidsCollection)
          .where('auctionId', isEqualTo: auctionId)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => BidModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException('Không thể tải lịch sử đấu giá: ${e.toString()}');
    }
  }

  @override
  Stream<List<BidModel>> watchBidHistory(String auctionId) {
    try {
      return firestore
          .collection(FirebaseConstants.bidsCollection)
          .where('auctionId', isEqualTo: auctionId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => BidModel.fromJson(doc.data(), doc.id))
                .toList();
          });
    } catch (e) {
      throw ServerException(
        'Không thể theo dõi lịch sử đấu giá: ${e.toString()}',
      );
    }
  }
}
