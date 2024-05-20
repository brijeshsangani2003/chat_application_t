import 'package:chat_application_t/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseHelper {
  static Future<UserModel?> getUserModelById(String uid) async {
    UserModel? userModel;

    //firebase ma jetla data get() thya aa badha documentSnapshot ma avi gya.
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    //documentSnapshot ma data lidha and aa object format ma avta ta
    //etle ene UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>) ma kara.
    if (documentSnapshot.data() != null) {
      userModel =
          UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
    }
    return userModel;
  }
}
