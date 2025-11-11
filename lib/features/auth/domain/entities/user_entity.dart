import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final int totalBids;
  final int wonAuctions;

  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.createdAt,
    this.totalBids = 0,
    this.wonAuctions = 0,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    photoUrl,
    createdAt,
    totalBids,
    wonAuctions,
  ];
}
