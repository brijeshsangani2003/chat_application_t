import 'package:chat_application_t/core/constants/app_string.dart';
import 'package:chat_application_t/core/constants/size.dart';
import 'package:chat_application_t/model/user_model.dart';
import 'package:chat_application_t/screen/complete_profile_screen.dart';
import 'package:chat_application_t/utils/common_validator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../common_widget/common_textfield.dart';
import '../halper/UI_Helper.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cPasswordController = TextEditingController();

  String? pushToken;

  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  void signUp(String email, String password) async {
    UserCredential? credential;

    UiHelper.showLoadingDialog(context, AppString.showLoading);

    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context);

      UiHelper.showAlertDialog(
          context, AppString.showAlterDialog, ex.message.toString());
      print("ERROR =======>${ex.message.toString()}");
    }
    if (credential != null) {
      //je user bano hse eni unic id uid ma store thase.(String uid = credential.user!.uid;)
      String uid = credential.user!.uid;

      await fMessaging.requestPermission();

      await fMessaging.getToken().then((value) {
        if (value != null) {
          pushToken = value;
          print('Push Token=====>$value');
        }
      });

      ///jo apne foreground and background ma karavo hoy to ahiya code eno lakhvo.
      // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      //   print('Got a message whilst in the foreground!');
      //   print('Message data: ${message.data}');
      //
      //   if (message.notification != null) {
      //     print(
      //         'Message also contained a notification: ${message.notification}');
      //   }
      // });
      UserModel newUser = UserModel(
        uid: uid,
        email: email,
        fullName: "",
        profilePic: "",
        pushToken: pushToken,
      );

      ///firebase ma data add karva hoy etle (toMap) format ma karvanu.
      //collection banavu user name nu pachi ena doc ma uid store thai gai aa user ni
      // and pachi ene set karavu set aa Map formate ma thai etle apne ji userModel banavo hato
      // ema toMap formate ma karu hatu (etle newuser ne toMap ma store kari didhu.)
      // .set(newUser.toMap()) ama toMap che aa userModel ma banavelu che.
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(newUser
              .toMap()) //notes ni Application ma apne data add karavta ta ama direcct userModel j banvai lidhu etle direct set j karavanu rey.
          .then((value) {
        print('New user created!!');

        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              //userModel: newUser (new user no badho j data jase.)
              //firebaseUser: credential!.user! (ama firebase ma je user bano hse eno data jase.)
              return CompleteProfileScreen(
                  userModel: newUser, firebaseUser: credential!.user!);
            },
          ),
        );
      });
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
                      hinttext: AppString.password,
                      controller: passwordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: Sizes.s20),
                    commonTextField(
                      validator: Validator.confirmPassValidator,
                      hinttext: AppString.confirmPassword,
                      controller: cPasswordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: Sizes.s30),
                    CupertinoButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          if (passwordController.text ==
                              cPasswordController.text) {
                            signUp(
                                emailController.text, passwordController.text);
                          }
                        }
                      },
                      color: Colors.blue,
                      child: const Text(AppString.signUp),
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
          const Text(AppString.alreadyAcc),
          CupertinoButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              AppString.logIn,
              style: TextStyle(color: Colors.blue),
            ),
          )
        ],
      ),
    );
  }
}
