class ChatRoomModel {
  String? chartRoomId; //chatroom id hoy aa
  Map<String, dynamic>? participants; //je 2 user vat karta hse eni id
  String? lastMessage; //chatroom ma je last message hoy aa.
  DateTime? createdon; //message kyre send thyo aa
  List<dynamic>?
      users; //bev user ni id ahiya avse.(user no array lidho che ema ji bey user vat karta hse eni id lesvani.)

  ChatRoomModel({
    this.chartRoomId,
    this.participants,
    this.lastMessage,
    this.createdon,
    this.users,
  });

  //deserialization
  //Map to Object
  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chartRoomId = map["chartRoomId"];
    participants = map["participants"];
    lastMessage = map["lastMessage"];
    createdon = map["createdon"].toDate();
    users = map["users"];
  }

  //serialization
  //Object to Map
  //toMap ne return map male che.etle ene return {"chartRoomId": chartRoomId} map karavu.
  Map<String, dynamic> toMap() {
    return {
      "chartRoomId": chartRoomId,
      "participants": participants,
      "lastMessage": lastMessage,
      "createdon": createdon,
      "users": users,
    };
  }
}
