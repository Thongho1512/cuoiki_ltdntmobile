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

      // Wait a bit for Firestore to sync
      await Future.delayed(const Duration(milliseconds: 500));

      final userDoc = await firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) {
        // If user doesn't exist in Firestore, create a default profile
        final newUser = UserModel.fromFirebaseUser(
          credential.user!.uid,
          credential.user!.email ?? email,
          credential.user!.displayName ?? email.split('@')[0],
        );

        await firestore
            .collection(FirebaseConstants.usersCollection)
            .doc(credential.user!.uid)
            .set(newUser.toJson());

        return newUser;
      }

      final userData = userDoc.data();
      if (userData == null) {
        throw AuthException('Dữ liệu người dùng không hợp lệ');
      }

      return UserModel.fromJson(userData);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } on AuthException {
      rethrow;
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

      // Update display name
      await credential.user!.updateDisplayName(displayName);
      await credential.user!.reload();

      final userModel = UserModel.fromFirebaseUser(
        credential.user!.uid,
        email,
        displayName,
      );

      await firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(credential.user!.uid)
          .set(userModel.toJson());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } on AuthException {
      rethrow;
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

      if (!userDoc.exists || userDoc.data() == null) {
        // Create user profile if it doesn't exist
        final newUser = UserModel.fromFirebaseUser(
          currentUser.uid,
          currentUser.email ?? '',
          currentUser.displayName ?? currentUser.email?.split('@')[0] ?? 'User',
        );

        await firestore
            .collection(FirebaseConstants.usersCollection)
            .doc(currentUser.uid)
            .set(newUser.toJson());

        return newUser;
      }

      return UserModel.fromJson(userDoc.data()!);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
        'Không thể lấy thông tin người dùng: ${e.toString()}',
      );
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

        if (!userDoc.exists || userDoc.data() == null) {
          // Create user profile if it doesn't exist
          final newUser = UserModel.fromFirebaseUser(
            firebaseUser.uid,
            firebaseUser.email ?? '',
            firebaseUser.displayName ??
                firebaseUser.email?.split('@')[0] ??
                'User',
          );

          await firestore
              .collection(FirebaseConstants.usersCollection)
              .doc(firebaseUser.uid)
              .set(newUser.toJson());

          return newUser;
        }

        return UserModel.fromJson(userDoc.data()!);
      } catch (e) {
        // print('Error in authStateChanges: $e');
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
      case 'invalid-credential':
        return 'Thông tin đăng nhập không hợp lệ';
      case 'too-many-requests':
        return 'Quá nhiều yêu cầu. Vui lòng thử lại sau';
      default:
        return 'Đã xảy ra lỗi xác thực: $code';
    }
  }
}
