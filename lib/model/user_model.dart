class UserModel {
  String? uid;
  String? fullName;
  String? email;
  String? profilePic;
  String? pushToken;

  UserModel(
      {this.uid, this.fullName, this.email, this.profilePic, this.pushToken});

  //fromJson(means k UserModel.fromMap(toMap no data ahiya access kari sakvi)
  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map["uid"];
    fullName = map["fullName"];
    email = map["email"];
    profilePic = map["profilePic"];
    pushToken = map["pushToken"];
  }
  //toJson(toMap means k ama badho data store thai gyo hoy)
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "fullName": fullName,
      "email": email,
      "profilePic": profilePic,
      "pushToken": pushToken,
    };
  }
}
