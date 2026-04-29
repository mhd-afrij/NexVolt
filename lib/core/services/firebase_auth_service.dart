import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  FirebaseAuthService._();

  static const String _rootCollection = 'nexvolt-db';
  static const String _docTypeVehicle = 'vehicle';

  static FirebaseAuth get _auth {
    if (Firebase.apps.isEmpty) {
      throw StateError('Firebase is not initialized.');
    }
    return FirebaseAuth.instance;
  }

  static FirebaseFirestore get _firestore {
    if (Firebase.apps.isEmpty) {
      throw StateError('Firebase is not initialized.');
    }
    return FirebaseFirestore.instance;
  }

  static User? get currentUser =>
      Firebase.apps.isEmpty ? null : _auth.currentUser;

  static bool get isSignedIn =>
      Firebase.apps.isNotEmpty && _auth.currentUser != null;

  static String? get currentUserId =>
      Firebase.apps.isEmpty ? null : _auth.currentUser?.uid;

  static Future<void> register({
    required String email,
    required String password,
  }) async {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  static Future<String> requestOtp({required String phoneNumber}) async {
    if (!kIsWeb &&
        defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      throw UnsupportedError(
        'Phone OTP is only supported on Android, iOS, and configured web builds.',
      );
    }

    String? verificationId;

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw e;
      },
      codeSent: (String vId, int? resendToken) {
        verificationId = vId;
      },
      codeAutoRetrievalTimeout: (String vId) {
        verificationId = vId;
      },
      timeout: const Duration(seconds: 60),
    );

    await Future.delayed(const Duration(milliseconds: 500));

    if (verificationId == null) {
      throw const FormatException('verification-failed');
    }

    return verificationId!;
  }

  static Future<void> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    await _auth.signInWithCredential(credential);
  }

  static Future<bool> hasVehicle() async {
    if (Firebase.apps.isEmpty) return false;

    final userId = currentUserId;
    if (userId == null) return false;

    final snapshot = await _firestore
        .collection(_rootCollection)
        .where('type', isEqualTo: _docTypeVehicle)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }
}
