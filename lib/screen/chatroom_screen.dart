import 'package:chat_application_t/core/constants/app_string.dart';
import 'package:chat_application_t/core/constants/size.dart';
import 'package:chat_application_t/halper/Date_halper.dart';
import 'package:chat_application_t/main.dart';
import 'package:chat_application_t/model/chatroom_model.dart';
import 'package:chat_application_t/model/message_model.dart';
import 'package:chat_application_t/model/user_model.dart';
import 'package:chat_application_t/services/notification_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatRoomScreen extends StatefulWidget {
  final UserModel targetUser; //apne ji user hare vat karvani che aa
  final ChatRoomModel chartRoom;

  final UserModel userModel; //apne ji user thi login chvi aa
  final User firebaseUser; //firebase ma ji user che aa

  const ChatRoomScreen(
      {super.key,
      required this.targetUser,
      required this.chartRoom,
      required this.userModel,
      required this.firebaseUser});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  TextEditingController messageController = TextEditingController();

  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    ///send message
    if (msg != '') {
      MessageModel newMessage = MessageModel(
        //means k ji message moklo eni id(uuid.v1() badha message ni alag alag hoy id etle ena mate aa package use karvama ave che.)
        messageId: uuid.v1(),
        sender: widget.userModel.uid, //ji user msg send kare che aa.
        createdOn: DateTime.now(), //kyre(means k atyre am)
        text: msg,
        seen: false,
        time: time,
      );
      FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(widget.chartRoom.chartRoomId)
          .collection('messages')
          .doc(newMessage.messageId)
          .set(newMessage.toMap())
          .then((value) {
        APIs.sendPushNotification(widget.targetUser, msg);
      });
      print('Message Sent!!');

      //ji chello msg hse aa widget.chartRoom.lastMessage ma avi jase;
      widget.chartRoom.lastMessage = msg;
      FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(widget.chartRoom.chartRoomId)
          .set(widget.chartRoom.toMap());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage:
                  NetworkImage(widget.targetUser.profilePic.toString()),
            ),
            const SizedBox(width: Sizes.s10),
            Text(
              widget.targetUser.fullName.toString(),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('chatrooms')
                      .doc(widget.chartRoom.chartRoomId)
                      .collection('messages')
                      .orderBy('createdOn', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      //snashort no type AsyncSnapshot che pn apne qureySnapshot joto che etle ene convertkari nakhu.
                      if (snapshot.hasData) {
                        QuerySnapshot dataSnapshot =
                            snapshot.data as QuerySnapshot;
                        return ListView.builder(
                          //pela message uper avta ta reverse karu etle niche avi gya data
                          //pn ji data ave che aa gmay tya ave che uper niche aa ritna to aa mate apne
                          //stream builder ma jo collection che ene .orderBy('createdOn', descending: true)
                          // aa ritna kari devanu etle mseeage time to time batavse.
                          reverse: true,
                          itemCount: dataSnapshot.docs.length,
                          itemBuilder: (context, index) {
                            //multiple message avta hoy etle apne dataSnapshot.docs mathi ek messageMedel banavi lesu.
                            MessageModel currentMessage = MessageModel.fromMap(
                                dataSnapshot.docs[index].data()
                                    as Map<String, dynamic>);

                            //container ne wrep karine row karsu etle jetlo message hse etlu j container banavse.
                            //currentMessage.sender(means k je user message send kare che aa)==
                            //widget.userModel.uid(means k ji user etle k apne user as a msg send karvi aa)
                            if (currentMessage.sender != widget.userModel.uid) {
                              markMessageAsSeen(currentMessage);
                            }
                            return currentMessage.sender == widget.userModel.uid
                                ? grayMessage(currentMessage)
                                : blueMessage(currentMessage);
                          },
                        );
                      } else if (snapshot.hasError) {
                        return const Text(AppString.nConnection);
                      } else {
                        return const Text(AppString.sFriend);
                      }
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                )),
            Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.symmetric(
                horizontal: Sizes.s15,
                vertical: Sizes.s5,
              ),
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      controller: messageController,
                      maxLines: null,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: AppString.eMessage),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        sendMessage();
                      },
                      icon: const Icon(
                        Icons.send,
                        color: Colors.blue,
                      ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  //msg seen or not
  void markMessageAsSeen(MessageModel currentMessage) {
    if (!currentMessage.seen) {
      FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(widget.chartRoom.chartRoomId)
          .collection('messages')
          .doc(currentMessage.messageId)
          .update({'seen': true});
    }
  }

  Widget grayMessage(MessageModel currentMessage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sizes.s5),
          child: Row(
            children: [
              Icon(
                Icons.done_all_rounded,
                size: Sizes.s15,
                color: currentMessage.seen ? Colors.blue : Colors.black,
              ),
              SizedBox(width: Sizes.s2),
              Text(MyDate.getFormattedTime(
                  context, currentMessage.time.toString())),
            ],
          ),
        ),
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(
                vertical: Sizes.s2, horizontal: Sizes.s5),
            padding: const EdgeInsets.symmetric(
                horizontal: Sizes.s10, vertical: Sizes.s10),
            decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(Sizes.s5)),
            child: Text(
              currentMessage.text.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget blueMessage(MessageModel currentMessage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(
                vertical: Sizes.s2, horizontal: Sizes.s5),
            padding: const EdgeInsets.symmetric(
                horizontal: Sizes.s10, vertical: Sizes.s10),
            decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(Sizes.s5)),
            child: Text(
              currentMessage.text.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sizes.s5),
          child: Row(
            children: [
              Text(MyDate.getFormattedTime(
                  context, currentMessage.time.toString())),
              const SizedBox(width: Sizes.s2),
              Icon(
                Icons.done_all_rounded,
                size: Sizes.s15,
                color: currentMessage.seen ? Colors.blue : Colors.black,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
