import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseAuthHelper {

  static Future<User?> registerUsingEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      user = userCredential.user;
      // ignore: deprecated_member_use
      await user!.updateProfile(displayName: name);
      await user.reload();
      user = auth.currentUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        if (kDebugMode) {
          print('The password provided is too weak.');
        }
      } else if (e.code == 'email-already-in-use') {
        if (kDebugMode) {
          print('The account already exists for that email.');
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }

    return user;
  }

  //register using email, phone, password
  static Future<User?> registerUsingEmailPhonePassword({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      user = userCredential.user;
      // ignore: deprecated_member_use
      await user!.updateProfile(displayName: name);
      await user.reload();
      user = auth.currentUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        if (kDebugMode) {
          print('The password provided is too weak.');
        }
      } else if (e.code == 'email-already-in-use') {
        if (kDebugMode) {
          print('The account already exists for that email.');
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }

    return user;
  }


  static Future<User?> signInUsingEmailPassword({
    required String email,
    required String password,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        if (kDebugMode) {
          print('No user found for that email.');
        }
      } else if (e.code == 'wrong-password') {
        if (kDebugMode) {
          print('Wrong password provided.');
        }
      }
    }

    return user;
  }
//verify phone number 
// await FirebaseAuth.instance.verifyPhoneNumber(
//   phoneNumber: '+44 7123 123 456',
//   verificationCompleted: (PhoneAuthCredential credential) {},
//   verificationFailed: (FirebaseAuthException e) {},
//   codeSent: (String verificationId, int? resendToken) {},
//   codeAutoRetrievalTimeout: (String verificationId) {},
// );



// Future<void> verifyPhoneNumber(
// {String? phoneNumber,
// PhoneMultiFactorInfo? multiFactorInfo,
// required PhoneVerificationCompleted verificationCompleted,
// required PhoneVerificationFailed verificationFailed,
// required PhoneCodeSent codeSent,
// required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
// @visibleForTesting String? autoRetrievedSmsCodeForTesting,
// Duration timeout = const Duration(seconds: 30),
// int? forceResendingToken,
// MultiFactorSession? multiFactorSession}
// )









//phone auth sign in
  // async static Future<User?> signInUsingPhoneNumber({
  //   required String phoneNumber,
  //   required Function(PhoneAuthCredential) phoneAuthCredentialSent,
  //   required Function(String verificationId, int? resendToken) phoneCodeSent,
  //   required Function(UserCredential) verificationCompleted,
  //   required Function(FirebaseAuthException) verificationFailed,
  //   required Function(String) codeAutoRetrievalTimeout,
  // }) async {
  //   FirebaseAuth auth = FirebaseAuth.instance;
  //   User? user;

  //   try {
  //     await auth.verifyPhoneNumber(
  //       phoneNumber: phoneNumber,
  //     verificationCompleted: (PhoneAuthCredential credential) async {
  //       user = (await auth.signInWithCredential(credential)).user;
  //       verificationCompleted(await auth.signInWithCredential(credential));
  //     },        
  //     verificationFailed: verificationFailed,
  //       codeSent: phoneCodeSent,
  //       codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
  //     );
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == 'invalid-phone-number') {
  //       if (kDebugMode) {
  //         print('The provided phone number is not valid.');
  //       }
  //     }
  //   }

  //   return user;
  // }


}