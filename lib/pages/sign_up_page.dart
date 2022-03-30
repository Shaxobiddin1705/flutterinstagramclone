import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutterinstagramclone/models/user_model.dart';
import 'package:flutterinstagramclone/pages/sign_in_page.dart';
import 'package:flutterinstagramclone/services/auth_service.dart';
import 'package:flutterinstagramclone/services/data_service.dart';
import 'package:flutterinstagramclone/services/hive_service.dart';
import 'package:flutterinstagramclone/services/utils.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);
  static const String id = 'sign_up_page';

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  bool isLoading = false;

  Future<void> _doSignUp() async{
    String fullName = fullNameController.text.trim().toString();
    String email = emailController.text.trim().toString();
    String password = passwordController.text.trim().toString();
    String confirmPassword = confirmPasswordController.text.trim().toString();
    String userName = userNameController.text.trim().toString();
    final emailRegExp = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    final passwordRegExp = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');

    if(email.isEmpty || password.isEmpty || userName.isEmpty || fullName.isEmpty || confirmPassword.isEmpty) {
      Utils.fireSnackBar("Please complete all the fields", context);
      return ;
    }

    setState(() {
      isLoading = true;
    });

    if(!emailRegExp.hasMatch(email)) {
      Utils.fireSnackBar("Please complete the email", context);
      return;
    }

    if(!passwordRegExp.hasMatch(password)) {
      Utils.fireSnackBar("Please complete the password", context);
      return;
    }

    if(password != confirmPassword) {
      Utils.fireSnackBar("Your confirm password is different with password", context);
      return;
    }

    var modelUser = Users(password: password, email: email, fullName:  fullName, userName: userName);
    await AuthService.signUpUser(modelUser).then((response) {
      _getFireBaseUser(modelUser, response);
    });
  }

  void _getFireBaseUser(Users? users, Map<String, User?> map) {
    setState(() {
      isLoading = false;
    });

    if(!map.containsKey("SUCCESS")) {
      if(map.containsKey("weak-password")) Utils.fireSnackBar("The password provided is too weak.", context);
      if(map.containsKey("email-already-in-use")) Utils.fireSnackBar("The account already exists for that email.", context);
      if(map.containsKey("ERROR")) Utils.fireSnackBar("Check Your Information.", context);
      return;
    }

    User? user = map["SUCCESS"];
    if(user == null) return;

    HiveDB.store(user.uid);
    users?.uid = user.uid;

    DataService.storeUser(users!).then((value) => {Navigator.pushReplacementNamed(context, SignInPage.id)});
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

                        //#FullName
                        Container(
                          height: 50,
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                            color: Colors.white54.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: TextField(
                            controller: fullNameController,
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: "FullName",
                              border:InputBorder.none,
                              hintStyle: TextStyle(fontSize: 17.0, color: Colors.white54),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10,),

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

                        //#UserName
                        Container(
                          height: 50,
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                            color: Colors.white54.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: TextField(
                            controller: userNameController,
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: "UserName",
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

                        //#ConfirmPassword
                        Container(
                          height: 50,
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                            color: Colors.white54.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: TextField(
                            controller: confirmPasswordController,
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(color: Colors.white),
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: "Confirm Password",
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
                              _doSignUp();
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      const Text('Already have an account?', style: TextStyle(color: Colors.white, fontSize: 16),),

                      const SizedBox(width: 10,),

                      GestureDetector(
                        onTap: (){
                          Navigator.pushReplacementNamed(context, SignInPage.id);
                        },
                        child: const Text('Sign In', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),),
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
