import 'package:chat_application_t/core/constants/app_string.dart';
import 'package:chat_application_t/core/constants/size.dart';
import 'package:chat_application_t/main.dart';
import 'package:chat_application_t/model/user_model.dart';
import 'package:chat_application_t/screen/chatroom_screen.dart';
import 'package:chat_application_t/utils/common_validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../common_widget/common_textfield.dart';
import '../model/chatroom_model.dart';

class SearchScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const SearchScreen(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final formKey = GlobalKey<FormState>();
  TextEditingController searchController = TextEditingController();

  //chatModel jo ek var use thai gyo hse to aa avse niker navo j avse(email pr thi user aa ritna)
  //means k email pr thi
  //participants ma user ni uid same hoy and participants ma targetuser ni uid same hoy
  //to aa data get kari lehe(means aa 2 user vat kari sakse.)
  Future<ChatRoomModel?> getChatRoomModel(UserModel targetUser) async {
    ChatRoomModel chatRoom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('chatrooms')
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    //chatRooms nu 0 karta vadhre document hoy tyre.
    //(chatroom ni id message ni id banavi padse)
    //aa apne ek package avse eno use akrine banavsu(uuid)
    if (snapshot.docs.length > 0) {
      ///Fetch the existing one
      print('Chatroom already created');
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);
      chatRoom = existingChatroom;
    } else {
      ///create a new one(jai nava user nu chatroom bane tai aa field bharvani.)
      ChatRoomModel newChatroom = ChatRoomModel(
        chartRoomId: uuid.v1(),
        lastMessage: '',
        participants: {
          widget.userModel.uid.toString(): true,
          targetUser.uid.toString(): true
        },
        users: [
          widget.userModel.uid.toString(),
          targetUser.uid.toString(),
        ],
        createdon: DateTime.now(),
      );
      await FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(newChatroom.chartRoomId)
          .set(newChatroom.toMap());

      chatRoom = newChatroom;
      print('New Chatroom created');
    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
        title: const Text(
          AppString.search,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.s20),
            child: Column(
              children: [
                const SizedBox(height: Sizes.s30),
                commonTextField(
                  validator: Validator.search,
                  hinttext: AppString.emailAddress,
                  controller: searchController,
                ),
                const SizedBox(height: Sizes.s30),
                CupertinoButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      //pela build method call thati hse pachi ahiya apne setstate karu
                      //etle pachi akhi build method refresh thase.
                      setState(() {});
                    }
                  },
                  color: Colors.blue,
                  child: const Text(AppString.search),
                ),
                const SizedBox(height: Sizes.s30),
                StreamBuilder(
                  //firebase ma user name na collection ma je vastu apne search karavi hoy aa field nu name lakhvanu
                  //means k  .where(  'email', isEqualTo: searchController.text)
                  //aa tamne email field ma ji value hse and tme search ma ji value store karavi aa same hse to search thase.and aa snapshorts ma vai jase.
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where("email", isEqualTo: searchController.text)
                      .where("email",
                          isNotEqualTo: widget.userModel
                              .email) //je tamru potanu email id hse eni hare vat no kari sako.
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        QuerySnapshot dataSnapshot =
                            snapshot.data as QuerySnapshot;

                        if (dataSnapshot.docs.length > 0) {
                          Map<String, dynamic> userMap = dataSnapshot.docs[0]
                              .data() as Map<String, dynamic>;

                          UserModel searchedUser = UserModel.fromMap(userMap);
                          print(
                              '==========>${searchedUser.fullName.toString()}');
                          return ListTile(
                            onTap: () async {
                              //getChatRoomModel(targetUser)target user etle search karelo user
                              ChatRoomModel? chatroomModel =
                                  await getChatRoomModel(searchedUser);
                              if (chatroomModel != null) {
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return ChatRoomScreen(
                                      targetUser: searchedUser,
                                      firebaseUser: widget.firebaseUser,
                                      userModel: widget.userModel,
                                      chartRoom: chatroomModel,
                                    );
                                  },
                                ));
                              }
                            },
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey[500],
                              backgroundImage:
                                  NetworkImage(searchedUser.profilePic!),
                            ),
                            title: Text(searchedUser.fullName!),
                            subtitle: Text(searchedUser.email!),
                            trailing: const Icon(Icons.keyboard_arrow_right),
                          );
                        } else {
                          return const Text(
                            AppString.noResult,
                            style: TextStyle(color: Colors.red),
                          );
                        }
                      } else if (snapshot.hasError) {
                        return const Text(AppString.showAlterDialog);
                      } else {
                        return const Text(AppString.noResult);
                      }
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
