class Users {
  String uid = "";
  late String fullName;
  late String email;
  late String password;
  late String userName;
  String? imageUrl;
  late String deviceId;
  late String deviceType;
  late String deviceToken;
  bool followed = false;
  int followersCount = 0;
  int followingCount = 0;

  Users({required this.fullName, required this.email, required this.password, this.imageUrl, required this.userName});

  Users.fromJson(Map<String, dynamic> json) {
    uid = json["uid"];
    fullName = json["fullName"];
    email = json["email"];
    password = json["password"];
    imageUrl = json["imageUrl"];
    followersCount = json["followersCount"];
    followingCount = json["followingCount"];
    userName = json["userName"];
    followed = json["followed"];
    deviceId = json["deviceId"];
    deviceType = json["deviceType"];
    deviceToken = json["deviceToken"];
  }

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "fullName": fullName,
    "email": email,
    "password": password,
    "imageUrl": imageUrl,
    "followersCount": followersCount,
    "followingCount": followingCount,
    "userName": userName,
    "followed": followed,
    "deviceId": deviceId,
    "deviceType": deviceType,
    "deviceToken": deviceToken,
  };

  @override
  bool operator ==(Object other) {
    return other is Users && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}