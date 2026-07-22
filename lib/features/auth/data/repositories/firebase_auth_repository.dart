import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:kivu_haqms/features/auth/data/models/user_model.dart';
import 'package:kivu_haqms/features/auth/domain/entities/user_entity.dart';
import 'package:kivu_haqms/features/auth/domain/repositories/auth_repository.dart';
import 'package:kivu_haqms/core/constants/firebase_constants.dart';

class FirebaseAuthRepository implements AuthRepository{
  FirebaseAuthRepository({
    fb.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
      _googleSignIn =  GoogleSignIn.instance;
  
  final fb.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  bool _googleInitialized = false;

  Future<void> _ensureGoogleInitialized() async{
    if(_googleInitialized) return;
    await _googleSignIn.initialize(
      serverClientId: FirebaseConstants.googleWebClientId,
    );
    _googleInitialized = true;
  }

  @override
  Stream<UserEntity?> get authStateChanges{
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return UserModel.fromFirebaseUser(user);
    });
  }

  @override
  Future<UserEntity?> getCurrentUser() async{
    final user = _firebaseAuth.currentUser;
    if(user == null) return null;
    return UserModel.fromFirebaseUser(user);
  }

  @override
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async{
    try{
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(displayName);
      await credential.user?.reload();
      final refreshedUser = _firebaseAuth.currentUser!;
      return UserModel.fromFirebaseUser(refreshedUser);
    } on fb.FirebaseAuthException catch (e){
      throw Exception(_mapFirebaseError(e));
    }
  }

  @override
  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) async{
    try{
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return UserModel.fromFirebaseUser(credential.user!);
    } on fb.FirebaseAuthException catch(e){
      throw Exception(_mapFirebaseError(e));
    }
  }

  @override
  Future<UserEntity> signInWithGoogle() async{
    try{
      await _ensureGoogleInitialized();
      final googleUser = await _googleSignIn.authenticate();

      final googleAuth = googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      return UserModel.fromFirebaseUser(userCredential.user!);
    } on GoogleSignInException catch (e){
      debugPrint('GoogleSignInException: code=${e.code}, description=${e.description}, details=${e.details}');
      if(e.code == GoogleSignInExceptionCode.canceled){
        throw Exception('Google sign-in was cancelled.');
      }
      throw Exception('Google sign-in failed. Please try again.');
    } on fb.FirebaseAuthException catch(e){
      debugPrint('FirebaseAuthException: code=${e.code}, message=${e.message}');
      throw Exception(_mapFirebaseError(e));
    } catch (e) {
      debugPrint('Unexpected error in signInWithGoogle: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async{
    try{
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on fb.FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e));
    }
  }

  @override
  Future<void> signOut() async{
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }


  String _mapFirebaseError(fb.FirebaseAuthException e){
    switch (e.code){
      case 'email-already-in-use':
        return 'An account already exists with that email.';
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'weak-password':
        return 'Password should be at least 8 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'something went wrong. Please try again.';
    }
  }
}
