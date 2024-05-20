class MessageModel {
  String? messageId; //message ni id(badha message ni alag alg id hoy)
  String? sender; //user ni uid hse aa(user aa send kare aa)
  String? text; //user ji message lakhe aa(message ma ji text hoy aa)
  bool seen = false; //message seen thyo k nai aa
  DateTime? createdOn; //message kyre send thyo aa
  String? time;
  MessageModel(
      {this.messageId,
      this.sender,
      this.text,
      this.seen = false,
      this.createdOn,
      this.time});

  //jyre firebase mathi data lesu tyre fromMap karsu.emathi amne map malse and ema thi obj banavsu.
  MessageModel.fromMap(Map<String, dynamic> map) {
    messageId = map["messageId"];
    sender = map["sender"];
    text = map["text"];
    // seen = map["seen"];
    seen = map["seen"] is bool ? map["seen"] : false;
    createdOn = map["createdOn"].toDate();
    time = map["time"];
  }

  //toMap no use obj no use karine ek map banavsu.
  Map<String, dynamic> toMap() {
    return {
      "messageId": messageId,
      "sender": sender,
      "text": text,
      "seen": seen,
      "createdOn": createdOn,
      "time": time,
    };
  }
}
