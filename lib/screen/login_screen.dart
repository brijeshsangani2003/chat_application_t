import 'package:chat_application_t/core/constants/app_string.dart';
import 'package:chat_application_t/core/constants/size.dart';
import 'package:chat_application_t/screen/home_screen.dart';
import 'package:chat_application_t/screen/sign_up_screen.dart';
import 'package:chat_application_t/utils/common_validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../common_widget/common_textfield.dart';
import '../halper/UI_Helper.dart';
import '../model/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String? pushToken;

  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  void logIn(String email, String password) async {
    UserCredential? credential;

    UiHelper.showLoadingDialog(context, AppString.showLogging);

    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      ///Close the loading dialog
      Navigator.pop(context);

      ///Show alert dialog
      UiHelper.showAlertDialog(
          context, AppString.showAlterDialog, e.message.toString());
      print("ERROR =======>${e.message.toString()}");
    }
    if (credential != null) {
      String uid = credential.user!.uid;
      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      //userData.data() aa object format ma ave che and apno data Map<String, dynamic> ma ave che.
      //etle apne as karine ene convert kari didhu.
      UserModel userModel =
          UserModel.fromMap(userData.data() as Map<String, dynamic>);

      await fMessaging.requestPermission();

      await fMessaging.getToken().then((value) {
        if (value != null) {
          pushToken = value;
          print('Login Token=====>$value');
        }
      });

      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'pushToken': pushToken});

      print('Log In Successfully');

      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) {
          return HomeScreen(
              userModel: userModel, firebaseUser: credential!.user!);
        },
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.s30),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      AppString.chatApp,
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: Sizes.s40,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: Sizes.s20),
                    commonTextField(
                      validator: Validator.emailValidator,
                      hinttext: AppString.email,
                      controller: emailController,
                    ),
                    const SizedBox(height: Sizes.s20),
                    commonTextField(
                      validator: Validator.passValidator,
                      obscureText: true,
                      hinttext: AppString.password,
                      controller: passwordController,
                    ),
                    const SizedBox(height: Sizes.s30),
                    CupertinoButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          logIn(emailController.text, passwordController.text);
                        }
                      },
                      color: Colors.blue,
                      child: const Text(AppString.logIn),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(AppString.notAcc),
          CupertinoButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignUpScreen(),
                  ));
            },
            child: const Text(
              AppString.signUp,
              style: TextStyle(color: Colors.blue),
            ),
          )
        ],
      ),
    );
  }
}
