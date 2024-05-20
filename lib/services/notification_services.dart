import 'dart:convert';

import 'package:http/http.dart' as http;
import '../model/user_model.dart';

///notification karvi etle aa 3 line add kari devi. (AndroidManifest.xml ma)
// <meta-data
// android:name="com.google.firebase.messaging.default_notification_channel_id"
// android:value="high_importance_channel" />
class APIs {
  static Future<void> sendPushNotification(UserModel user, String msg) async {
    try {
      final body = {
        'to': user.pushToken,
        'priority': 'high',
        'notification': {
          'title': user.fullName,
          'body': msg,
          'android_channel_id':
              'chats', //FlutterNotificationChannel ma api aa id apvani
        },
        'data': {
          'some_data': "User ID: ${user.uid}",
        }
      };
      var response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        body: jsonEncode(body),
        headers: {
          'Content-type': 'application/json; charset=UTF-8',
          'Authorization':
              'key=AAAArW6hb9o:APA91bFGitAzlsA6QB7JAxryR9I7LfWml86kLQmJCN1Scb1sdB5qPN44pXJvdyNCmb0r4xQEkgAuPwXlbwRbnCX_XxQ_Eh53Om1WR4TelrfqivWRDFp_0gIpg-h979Egy_2TmS2Xbrjz'
        },
      );
      print('Response Status : ${response.statusCode}');
      print('Response body : ${response.body}');
    } catch (e) {
      print('pushNotification ERROR :$e');
    }
  }
}
