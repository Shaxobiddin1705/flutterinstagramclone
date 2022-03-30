import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterinstagramclone/pages/other_profile_page.dart';
import 'package:flutterinstagramclone/services/utils.dart';

import 'my_feed_page.dart';
import 'my_likes_page.dart';
import 'my_profile_page.dart';
import 'my_search_page.dart';
import 'my_upload_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  static const String id = 'home_page';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentTap = 0;
  PageController _pageController = PageController();


  _initNotification() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Utils.showLocalNotification(message, context);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Utils.showLocalNotification(message, context);
    });
  }

  @override
  void initState() {
    _initNotification();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (int index) {
          setState(() {
            _currentTap = index;
          });
        },
        children: [
          MyFeedPage(),
          MySearchPage(controller: _pageController,),
          MyUploadPage(pageController: _pageController,),
          const MyLikesPage(),
          MyProfilePage(),
          OtherProfilePage(pageController: _pageController,),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color.fromRGBO(193, 53, 132, 1),
        unselectedItemColor: Colors.grey,
        currentIndex: _currentTap,
        showSelectedLabels: false,
        onTap: (int index) {
          setState(() {
            _currentTap = index;
            _pageController.animateToPage(index, duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home, size: 28,),
              label: "",
          ),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.search, size: 28,),
              label: "",
          ),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.plus_app, size: 28,),
              label: "",
          ),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.heart_fill, size: 28,),
              label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_alt_circle, size: 28,),
            label: "",
          ),
        ],

      ),
    );
  }
}
