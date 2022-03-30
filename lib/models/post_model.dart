import 'dart:convert';

List<Posts> imagesFromJson(String str) => List<Posts>.from(json.decode(str).map((x) => Posts.fromJson(x)));

String imagesToJson(List<Posts> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

List<Posts> posts = [];

class Posts{
  late String uid;
  late String fullName;
  late String id;
  late String postImage;
  late String caption;
  late String createdDate;
  late bool isLiked;
  late bool isMine;
  String? imageUser;
  late String userName;

  Posts({
    required this.postImage,
    required this.caption,
  });

  Posts.fromJson(Map<String, dynamic> json) {
    uid = json["uid"];
    fullName = json["fullName"];
    id = json["id"];
    postImage = json["postImage"];
    caption = json["caption"];
    createdDate = json["createdDate"];
    isLiked = json["isLiked"];
    isMine = json["isMine"];
    imageUser = json["imageUser"];
    userName = json["userName"];
  }

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "fullName": fullName,
    "id": id,
    "postImage": postImage,
    "caption": caption,
    "createdDate": createdDate,
    "isLiked": isLiked,
    "isMine": isMine,
    "imageUser": imageUser,
    "userName": userName,
  };

}