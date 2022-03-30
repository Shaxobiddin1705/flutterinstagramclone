import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterinstagramclone/models/user_model.dart';
import 'package:flutterinstagramclone/pages/sign_in_page.dart';
import 'package:flutterinstagramclone/services/hive_service.dart';
import 'package:flutterinstagramclone/services/utils.dart';

class AuthService {
  static final FirebaseAuth auth = FirebaseAuth.instance;

  static Future<Map<String, User?>> signUpUser(Users modelUser) async {
    Map<String, User?> map = {};
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(email: modelUser.email, password: modelUser.password);
      User? user = userCredential.user;
      map = {"SUCCESS": user};
      return map;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        map = {'weak-password': null};
      } else if (e.code == 'email-already-in-use') {
        map = {'email-already-in-use': null};
      }
    } catch (e) {
      map = {"ERROR": null};
    }

    return map;
  }

  static Future<Map<String, User?>> signInUser(String email, String password) async {
    Map<String, User?> map = {};
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      map = {"SUCCESS": user};
      return map;
    } on FirebaseAuthException catch (e) {

      if (e.code == 'weak-password') {
        map = {'user-not-found': null};
      } else if (e.code == 'wrong-password') {
        map = {'email-already-in-use': null};
      }
    } catch (e) {
      map = {"ERROR": null};
    }

    return map;
  }

  static void signOutUser(BuildContext context) async {
    await auth.signOut();
    HiveDB.remove();
    Navigator.pushReplacementNamed(context, SignInPage.id);
  }

  static void deleteAccount(BuildContext context) async {
    try {
      auth.currentUser!.delete();
      HiveDB.remove();
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const SignInPage()), (route) => false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        Utils.fireSnackBar('The user must re-authenticate before this operation can be executed.', context);
      }
    }
  }
}