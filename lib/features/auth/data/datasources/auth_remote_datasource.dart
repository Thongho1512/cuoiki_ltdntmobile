import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String email, String password, String displayName);
  Future<void> logout();
  Future<UserModel> getCurrentUser();
  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw AuthException('Đăng nhập thất bại');
      }

      final userDoc = await firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw AuthException('Người dùng không tồn tại');
      }

      return UserModel.fromJson(userDoc.data()!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthException('Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> register(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw AuthException('Đăng ký thất bại');
      }

      final userModel = UserModel.fromFirebaseUser(
        credential.user!.uid,
        email,
        displayName,
      );

      await firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(credential.user!.uid)
          .set(userModel.toJson());

      await credential.user!.updateDisplayName(displayName);

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthException('Đã xảy ra lỗi: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw AuthException('Đăng xuất thất bại');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final currentUser = firebaseAuth.currentUser;

      if (currentUser == null) {
        throw AuthException('Người dùng chưa đăng nhập');
      }

      final userDoc = await firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        throw AuthException('Người dùng không tồn tại');
      }

      return UserModel.fromJson(userDoc.data()!);
    } catch (e) {
      throw AuthException('Không thể lấy thông tin người dùng');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      try {
        final userDoc = await firestore
            .collection(FirebaseConstants.usersCollection)
            .doc(firebaseUser.uid)
            .get();

        if (!userDoc.exists) return null;

        return UserModel.fromJson(userDoc.data()!);
      } catch (e) {
        return null;
      }
    });
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Email không tồn tại';
      case 'wrong-password':
        return 'Mật khẩu không đúng';
      case 'email-already-in-use':
        return 'Email đã được sử dụng';
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'weak-password':
        return 'Mật khẩu quá yếu (tối thiểu 6 ký tự)';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng';
      default:
        return 'Đã xảy ra lỗi xác thực';
    }
  }
}
