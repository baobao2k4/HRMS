import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../../features/auth/repositories/user_repository.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepository = UserRepository();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Authentication failed');
      }

      final userModel = await _userRepository.getUserByEmail(email);
      if (userModel == null) {
        throw Exception('User data not found');
      }

      return userModel;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No user found for that email');
        case 'wrong-password':
          throw Exception('Wrong password provided');
        case 'user-disabled':
          throw Exception('This user has been disabled');
        case 'invalid-email':
          throw Exception('Invalid email address');
        default:
          throw Exception('Authentication failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Authentication failed: $e');
    }
  }

  Future<UserModel> signUp(
    String email,
    String password,
    UserModel userData,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('User creation failed');
      }

      await _userRepository.add(userData);
      return userData;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          throw Exception('The password provided is too weak');
        case 'email-already-in-use':
          throw Exception('An account already exists for that email');
        case 'invalid-email':
          throw Exception('Invalid email address');
        default:
          throw Exception('Registration failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          throw Exception('Invalid email address');
        case 'user-not-found':
          throw Exception('No user found for that email');
        default:
          throw Exception('Password reset failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  Future<void> updatePassword(String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final email = user.email;
      if (email == null) throw Exception('User email not found');

      // Reauthenticate user before changing password
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Change password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          throw Exception('The new password is too weak');
        case 'requires-recent-login':
          throw Exception('Please log in again before retrying this request');
        default:
          throw Exception('Password update failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Password update failed: $e');
    }
  }

  Future<void> deleteAccount(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final email = user.email;
      if (email == null) throw Exception('User email not found');

      // Reauthenticate user before deleting account
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Delete user data from Firestore
      await _userRepository.delete(user.uid);

      // Delete Firebase Auth account
      await user.delete();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'requires-recent-login':
          throw Exception('Please log in again before retrying this request');
        default:
          throw Exception('Account deletion failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Account deletion failed: $e');
    }
  }
} 