
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutterinstagramclone/pages/edit_profile_page.dart';
import 'package:flutterinstagramclone/pages/home_page.dart';
import 'package:flutterinstagramclone/pages/my_feed_page.dart';
import 'package:flutterinstagramclone/pages/my_likes_page.dart';
import 'package:flutterinstagramclone/pages/my_posts_page.dart';
import 'package:flutterinstagramclone/pages/my_profile_page.dart';
import 'package:flutterinstagramclone/pages/my_search_page.dart';
import 'package:flutterinstagramclone/pages/my_upload_page.dart';
import 'package:flutterinstagramclone/pages/other_profile_page.dart';
import 'package:flutterinstagramclone/pages/settings_page.dart';
import 'package:flutterinstagramclone/pages/sign_in_page.dart';
import 'package:flutterinstagramclone/pages/sign_up_page.dart';
import 'package:flutterinstagramclone/pages/splash_page.dart';
import 'package:flutterinstagramclone/services/hive_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async{
  await Hive.initFlutter();
  await Hive.openBox(HiveDB.DB_NAME);

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // //notification
  // var initAndroidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
  // var initIosSetting = IOSInitializationSettings();
  // var initSetting = InitializationSettings(android: initAndroidSetting, iOS: initIosSetting);
  // await FlutterLocalNotificationsPlugin().initialize(initSetting);

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.max,
  );
  var initAndroidSetting =
  const AndroidInitializationSettings("@mipmap/ic_launcher");
  var initIosSetting = const IOSInitializationSettings();
  var initSetting =
  InitializationSettings(android: initAndroidSetting, iOS: initIosSetting);
  await FlutterLocalNotificationsPlugin().initialize(initSetting);
  await FlutterLocalNotificationsPlugin()
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((value) {
    runApp(const MyApp());
  });

}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Widget _startPage() {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            HiveDB.store(snapshot.data!.uid);
            return const SplashPage();
          } else {
            HiveDB.remove();
            return const SignInPage();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Instagram',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _startPage(),
      routes: {
        SplashPage.id: (context) => const SplashPage(),
        SignInPage.id: (context) => const SignInPage(),
        SignUpPage.id: (context) => const SignUpPage(),
        HomePage.id: (context) => const HomePage(),
        MyFeedPage.id: (context) => MyFeedPage(),
        MyLikesPage.id: (context) => const MyLikesPage(),
        MyProfilePage.id: (context) => const MyProfilePage(),
        MySearchPage.id: (context) => MySearchPage(),
        MyUploadPage.id: (context) => MyUploadPage(),
        SettingsPage.id: (context) => const SettingsPage(),
        EditProfilePage.id: (context) => EditProfilePage(),
        MyPostsPage.id: (context) => const MyPostsPage(),
        OtherProfilePage.id: (context) => OtherProfilePage(),
      },
    );
  }
}