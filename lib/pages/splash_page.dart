import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterinstagramclone/models/user_model.dart';
import 'package:flutterinstagramclone/pages/home_page.dart';
import 'package:flutterinstagramclone/pages/sign_in_page.dart';
import 'package:flutterinstagramclone/services/data_service.dart';
import 'package:flutterinstagramclone/services/hive_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);
  static const String id = 'splash_page';

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? timer;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    initNotification();
    timer = Timer(const Duration(milliseconds: 2000), () {
      goSignInPage();
    } );
    super.initState();
  }

  void goSignInPage() {
    Navigator.pushReplacementNamed(context, HomePage.id);
    timer!.cancel();
  }

  initNotification() async {
    await _firebaseMessaging.requestPermission(sound: true, badge: true, alert: true);
    _firebaseMessaging.getToken().then((String? token) {
      assert(token != null);
      if (kDebugMode) {
        print(token);
      }
      HiveDB.saveFCM(token!);
    });
    Users users = await DataService.loadUser();
    String token = await HiveDB.loadFCM();
    users.deviceToken = token;
    await DataService.updateUser(users);
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(193, 53, 132, 1),
              Color.fromRGBO(131, 58, 180, 1),

              // Color.fromRGBO(252, 175, 69, 1),
              // Color.fromRGBO(245, 96, 64, 1),
            ]
          )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [

            Expanded(
                child: Center(
                  child: Text("Instagram", style: TextStyle(color: Colors.white, fontSize: 45, fontFamily: "Billabong"),),
                )
            ),

            Text('All right reserved', style: TextStyle(color: Colors.white, fontSize: 16),),

            SizedBox(height: 20,),

          ],
        ),
      ),
    );
  }
}
