import 'dart:io';

import 'package:chat_application_t/core/constants/app_string.dart';
import 'package:chat_application_t/core/constants/size.dart';
import 'package:chat_application_t/halper/UI_Helper.dart';
import 'package:chat_application_t/model/user_model.dart';
import 'package:chat_application_t/screen/home_screen.dart';
import 'package:chat_application_t/utils/common_validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../common_widget/common_textfield.dart';

class CompleteProfileScreen extends StatefulWidget {
  //hve apne userModel and firebaseUser eno access badhi jagyaye kari saksu.
  final UserModel userModel; //apne ji usermodel create karo cge aa
  final User firebaseUser; //firebaseAuth valo user
  const CompleteProfileScreen(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

///image_cropper package no use karvi etle AndroidMainifest.xml ma aa 3 line add karvi farjiyat.
// <activity
// android:name="com.yalantis.ucrop.UCropActivity"
// android:screenOrientation="portrait"
// android:theme="@style/Theme.AppCompat.Light.NoActionBar"/>

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final formKey = GlobalKey<FormState>();
  TextEditingController fullNameController = TextEditingController();
  File? imageFile;

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 20, //image loading mate (jem aochu hoy am saru)
    );

    //croppedImage no path mare File ma joto che etle  File(croppedImage.path) ma
    //croppedImage nakhi didhi and ene imageFile ma mokli didhi.
    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  void showPhotoOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(AppString.uploadPic),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  selectImage(ImageSource.gallery);
                },
                leading: const Icon(Icons.photo_album),
                title: const Text(AppString.sGallery),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);

                  selectImage(ImageSource.camera);
                },
                leading: const Icon(Icons.camera_alt),
                title: const Text(AppString.tPhoto),
              ),
            ],
          ),
        );
      },
    );
  }

  void uploadData() async {
    UiHelper.showLoadingDialog(context, AppString.uImage);

    //firebase storage apane UploadTask ape che.
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilepictures")
        .child(widget.userModel.uid.toString())
        .putFile(imageFile!);

    TaskSnapshot snapshot = await uploadTask;

    String? imageUrl = await snapshot.ref.getDownloadURL();
    String? fullName = fullNameController.text.trim();

    widget.userModel.fullName = fullName;
    widget.userModel.profilePic = imageUrl;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userModel.uid)
        .set(widget.userModel.toMap())
        .then((value) {
      print('Data Uploaded');

      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) {
          return HomeScreen(
            userModel: widget.userModel,
            firebaseUser: widget.firebaseUser,
          );
        },
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, //arrowback nai ave sign up thase thai
        backgroundColor: Colors.blue,
        title: const Text(
          AppString.cProfile,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: Sizes.s30),
            child: ListView(
              children: [
                const SizedBox(height: Sizes.s20),
                CupertinoButton(
                  padding: const EdgeInsets.all(Sizes.s0),
                  onPressed: () {
                    showPhotoOptions();
                  },
                  child: CircleAvatar(
                    radius: Sizes.s60,
                    backgroundColor: Colors.blue,
                    backgroundImage:
                        (imageFile != null) ? FileImage(imageFile!) : null,
                    child: (imageFile == null)
                        ? const Icon(Icons.person,
                            size: Sizes.s60, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(height: Sizes.s20),
                commonTextField(
                  validator: Validator.fullName,
                  controller: fullNameController,
                  hinttext: AppString.fName,
                ),
                const SizedBox(height: Sizes.s30),
                CupertinoButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      uploadData();
                    }
                  },
                  color: Colors.blue,
                  child: const Text(AppString.submit),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
