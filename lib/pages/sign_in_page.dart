import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterinstagramclone/pages/sign_up_page.dart';
import 'package:flutterinstagramclone/services/auth_service.dart';
import 'package:flutterinstagramclone/services/hive_service.dart';
import 'package:flutterinstagramclone/services/utils.dart';

import 'home_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);
  static const String id = 'sign_in_page';

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> _doSignIn() async{
    String email = emailController.text.trim().toString();
    String password = passwordController.text.trim().toString();

    if(email.isEmpty || password.isEmpty) {
      Utils.fireSnackBar("Please complete all the fields", context);
      return;
    }

    setState(() {
      isLoading = true;
    });

    await AuthService.signInUser(email, password).then((response) {
      _getFirebaseUser(response);
    });
  }

  void _getFirebaseUser(Map<String, User?> map) async {
    setState(() {
      isLoading = false;
    });

    if(!map.containsKey("SUCCESS")) {
      if(map.containsKey("user-not-found")) Utils.fireSnackBar("No user found for that email.", context);
      if(map.containsKey("wrong-password")) Utils.fireSnackBar("Wrong password provided for that user.", context);
      if(map.containsKey("ERROR")) Utils.fireSnackBar("Check Your Information.", context);
      return;
    }

    User? user = map["SUCCESS"];
    if(user == null) return;

    HiveDB.store(user.uid);
    Navigator.pushReplacementNamed(context, HomePage.id);
  }

  void authenticateUser() async{
    String email = emailController.text.trim().toString();
    String password = passwordController.text.trim().toString();

    AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
    await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(credential);
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
  }

  @override
  void initState() {
    initNotification();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
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
                children: [

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Instagram", style: TextStyle(color: Colors.white, fontSize: 45, fontFamily: "Billabong"),),

                        const SizedBox(height: 20,),

                        //#Email
                        Container(
                          height: 50,
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                            color: Colors.white54.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white),
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              hintText: "Email",
                              border:InputBorder.none,
                              hintStyle: TextStyle(fontSize: 17.0, color: Colors.white54),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10,),

                        //#Password
                        Container(
                          height: 50,
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                            color: Colors.white54.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: TextField(
                            controller: passwordController,
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(color: Colors.white),
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: "Password",
                              border:InputBorder.none,
                              hintStyle: TextStyle(fontSize: 17.0, color: Colors.white54),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10,),

                        //#SignInButton
                        Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          // padding: const EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.white54.withOpacity(0.2), width: 2),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: MaterialButton(
                            onPressed: (){
                              _doSignIn();
                              authenticateUser();
                              // Navigator.pushReplacementNamed(context, HomePage.id);
                            },
                            child: const Text('Sign In', style: TextStyle(fontSize: 17, color: Colors.white),),
                          ),
                        ),


                      ],
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      const Text('Don`t have an account?', style: TextStyle(color: Colors.white, fontSize: 16),),

                      const SizedBox(width: 10,),

                      GestureDetector(
                        onTap: (){
                          Navigator.pushReplacementNamed(context, SignUpPage.id);
                        },
                        child: const Text('Sign Up', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),),
                      ),
                    ],
                  ),

                ],
              ),
            ),
            isLoading ? SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: const Center(
                  child: CircularProgressIndicator(),
                ) ) : const SizedBox.shrink(),
          ],
        )
      ),
    );
  }
}
