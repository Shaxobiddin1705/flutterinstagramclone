import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterinstagramclone/services/auth_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);
  static const String id = 'settings_page';

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.black,
        title: const Text("Settings"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(left: 5, right: 5),
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              const SizedBox(height: 10,),

              //#TextField
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade200
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: Icon(CupertinoIcons.search, size: 20,),
                    border: InputBorder.none
                  ),
                ),
              ),

              _listTile(icon: CupertinoIcons.person_add, text: "Follow and Invite Friends"),
              _listTile(icon: CupertinoIcons.bell, text: "Notifications"),
              _listTile(icon: CupertinoIcons.lock, text: "Privacy"),
              _listTile(icon: CupertinoIcons.checkmark_shield, text: "Security"),
              _listTile(icon: CupertinoIcons.speaker_zzz, text: "Ads"),
              _listTile(icon: CupertinoIcons.profile_circled, text: "Account"),
              _listTile(icon: CupertinoIcons.book_circle, text: "Help"),
              _listTile(icon: CupertinoIcons.info_circle, text: "About"),

              const Divider(color: Colors.grey,),

              Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(left: 20, right: 25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset('assets/images/meta_logo.png', width: 60, fit: BoxFit.cover,),
                    InkWell(
                      onTap: (){},
                      child: const Text('Accounts Center', style: TextStyle(color: Colors.blue, fontSize: 16),),
                    ),
                    const SizedBox(height: 15,),
                    Text('Control settings for connected experiences across Instagram, the Facebook app and Messenger, including story and post sharing and logging in',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 5,),

              Divider(color: Colors.grey.withOpacity(0.3),),

              Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(left: 20, right: 25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Logins', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),

                    const SizedBox(height: 15,),

                    InkWell(
                      onTap: (){},
                      child: const Text('Add Accounts', style: TextStyle(color: Colors.blue, fontSize: 16),),
                    ),

                    const SizedBox(height: 15,),

                    InkWell(
                      onTap: (){
                        AuthService.deleteAccount(context);
                      },
                      child: const Text('Log Out', style: TextStyle(color: Colors.blue, fontSize: 16),),
                    ),

                    const SizedBox(height: 30,),
                  ],
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }

  Widget _listTile({required icon, required text, goingPage}) {
    return ListTile(
      minVerticalPadding: 0.0,
      leading: Icon(icon, color: Colors.black, size: 25,),
      title: Text(text, style: const TextStyle(color: Colors.black, fontSize: 16),),
      trailing: const Icon(CupertinoIcons.right_chevron, size: 20,),
      onTap: () {
        _go(page: goingPage);
      },
    );
  }

  _go({page}) {
    Navigator.popAndPushNamed(context, page);
  }

}
