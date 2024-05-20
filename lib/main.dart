import 'package:chat_application_t/halper/Firebase_helper.dart';
import 'package:chat_application_t/model/user_model.dart';
import 'package:chat_application_t/screen/home_screen.dart';
import 'package:chat_application_t/screen/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await _initializeFirebase();
  //firebaseUser: currentUser (firebaseUser means k je current user hoy aaj).

  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    ///Logged In
    UserModel? thisUserModel =
        await FirebaseHelper.getUserModelById(currentUser.uid);

    if (thisUserModel != null) {
      runApp(
          MyAppLoggedIn(userModel: thisUserModel, firebaseUser: currentUser));
    }
    //by chance thisUserModel null hse to aa LoginScreen run thase.
    else {
      runApp(const MyApp());
    }
  } else {
    ///Not Logged In
    runApp(const MyApp());
  }
}

///Not Logged In
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

///Already Logged In
class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;
  const MyAppLoggedIn(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(
        userModel: userModel,
        firebaseUser: firebaseUser,
      ),
    );
  }
}

//notification mate
_initializeFirebase() async {
  var result = await FlutterNotificationChannel().registerNotificationChannel(
    description: 'For Showing Message Notifications',
    id: 'chats', //aa channel id thi j apnepush notification karsu.
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats', //aa apna phone ma notification hoy ena setting ma batave.
  );
  print('Notification Channel Result==========>${result}');
}

//shared preference no use no karvo hoy to sign up mate.
// means k ek var user login thai jay to sidho login page pr j avo joi aa
//tme ek var firebase ma login/sign up thav etle aa user no token tamne male.
//aa token uper uper ni 2 app run thai che.
//1. MyApp
//2. MyAppLoggedIn

///notification mate AndroidManifest.xml ma add kari
// android:enableOnBackInvokedCallback="true"
