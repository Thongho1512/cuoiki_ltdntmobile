import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.displayName,
    super.photoUrl,
    required super.createdAt,
    super.totalBids,
    super.wonAuctions,
  });

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      createdAt: entity.createdAt,
      totalBids: entity.totalBids,
      wonAuctions: entity.wonAuctions,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      totalBids: json['totalBids'] as int? ?? 0,
      wonAuctions: json['wonAuctions'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'totalBids': totalBids,
      'wonAuctions': wonAuctions,
    };
  }

  factory UserModel.fromFirebaseUser(
    String uid,
    String email,
    String displayName,
  ) {
    return UserModel(
      id: uid,
      email: email,
      displayName: displayName,
      createdAt: DateTime.now(),
      totalBids: 0,
      wonAuctions: 0,
    );
  }
}
