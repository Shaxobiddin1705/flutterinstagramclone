import 'package:flutter/material.dart';
import 'package:flutterinstagramclone/models/user_model.dart';

class OtherProfilePage extends StatefulWidget {
  OtherProfilePage({Key? key, this.pageController, this.users}) : super(key: key);
  static const String id = 'other_profile_page';
  PageController? pageController;
  Users? users;

  @override
  State<OtherProfilePage> createState() => _OtherProfilePageState();
}

class _OtherProfilePageState extends State<OtherProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
