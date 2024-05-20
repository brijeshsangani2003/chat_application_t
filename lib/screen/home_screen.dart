import 'package:chat_application_t/core/constants/app_string.dart';
import 'package:chat_application_t/model/chatroom_model.dart';
import 'package:chat_application_t/halper/Firebase_helper.dart';
import 'package:chat_application_t/model/user_model.dart';
import 'package:chat_application_t/screen/chatroom_screen.dart';
import 'package:chat_application_t/screen/login_screen.dart';
import 'package:chat_application_t/screen/search_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final UserModel userModel; //aa apne j user chvi aa
  final User firebaseUser; //aa firebase ma ave aa user
  const HomeScreen(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          AppString.chatApp,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              //popUntil etle  route.isFirst aa condition puri nai thai tya sudhi fara j karse.
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) {
                  return const LoginScreen();
                },
              ));
            },
            icon: const Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('chatrooms')
              .where('users',
                  arrayContains: widget.userModel
                      .uid) //user no array lidho che and ema thi user ni id lidhi etle hve apne ordeyBy kari saksu(ema apne time batavo che etle createdon ley lidhu toy haju erreo avse UI ma)(run karvi etle console ma ek link apse aa open karvani ema apne save karsu etle aa badha user index bani jase automatic)
              .orderBy('createdon')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                QuerySnapshot chatRoomSnapshots =
                    snapshot.data as QuerySnapshot;

                ///hve apne jetla target user che eni profile ne fullname and data joi aa che etle apne hve target usermodel banavsu.(reason apne eni profilepic ne full name ne aa jotu che etle)
                //pela apne ek chatroommodle banavu.pachi apne emathi participants ne fetch karu/
                //pachi participants ni key nu list banavi lidhu.
                //pachi apne participantsKey mathi apni key remove kari didhi.etle hve apno ji target User che eni j key vadhse.
                return ListView.builder(
                  itemCount: chatRoomSnapshots.docs.length,
                  itemBuilder: (context, index) {
                    ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                        chatRoomSnapshots.docs[index].data()
                            as Map<String, dynamic>);

                    Map<String, dynamic> participants =
                        chatRoomModel.participants!;

                    // participants.keys no type Iterable che etle toList(); karu.
                    List<String> participantsKey = participants.keys.toList();

                    participantsKey.remove(widget.userModel.uid);

                    // FutureBuilder etle lidhu(means k ek j var FutureBuilder run thai )
                    return FutureBuilder(
                      //apne ek FirebaseHelper name nu model banavu che.
                      //etle ema apne participantsKey[0] ley lidhi(apni user id to remove thai gai che etle hve taget User ni id vadhi to index[0] ley lidhi etle direct aaj ley lese am.)
                      //etle hve target user j batavse jetla hse aa.
                      future:
                          FirebaseHelper.getUserModelById(participantsKey[0]),
                      //snapshot no type AsyncSnapshot<UserModel?> che etle apne ene as UserModel ma fervu.
                      builder: (context, snapshot) {
                        //builder jai run thai tai ek error avine run thai(reason aa che k user nu snapshot done hoy toj aa thavu joi aa niker khali Container show thavu joi aa)
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.data != null) {
                            UserModel targetUser = snapshot.data as UserModel;
                            return ListTile(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return ChatRoomScreen(
                                      targetUser: targetUser,
                                      chartRoom: chatRoomModel,
                                      userModel: widget.userModel,
                                      firebaseUser: widget.firebaseUser,
                                    );
                                  },
                                ));
                              },
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  targetUser.profilePic.toString(),
                                ),
                              ),
                              title: Text(targetUser.email.toString()),
                              subtitle: (chatRoomModel.lastMessage.toString() !=
                                      '')
                                  ? Text(chatRoomModel.lastMessage.toString())
                                  : const Text(
                                      AppString.sFriend,
                                      style: TextStyle(color: Colors.blue),
                                    ),
                            );
                          } else {
                            return Container();
                          }
                        } else {
                          return Container();
                        }
                      },
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    snapshot.error.toString(),
                  ),
                );
              } else {
                return const Center(
                  child: Text(AppString.noChats),
                );
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return SearchScreen(
                userModel: widget.userModel,
                firebaseUser: widget.firebaseUser,
              );
            },
          ));
        },
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.search,
          color: Colors.white,
        ),
      ),
    );
  }
}
