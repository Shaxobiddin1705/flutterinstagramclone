import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutterinstagramclone/models/post_model.dart';
import 'package:flutterinstagramclone/models/user_model.dart';
import 'package:flutterinstagramclone/services/hive_service.dart';
import 'package:flutterinstagramclone/services/utils.dart';

class DataService {
  // init
  static final instance = FirebaseFirestore.instance;

  // folder
  static const String userFolder = "users";
  static const String postFolder = "posts";
  static const String feedFolder = "feeds";
  static const String followingFolder = "following";
  static const String followersFolder = "followers";

  // User
  static Future<void> storeUser(Users user) async {
    user.uid = (await HiveDB.load())!;
    String token = await HiveDB.loadFCM();
    Map<String, String> params = await Utils.deviceParams();
    user.deviceId = params['deviceId']!;
    user.deviceToken = token;
    user.deviceType = params['deviceType']!;

    return instance.collection(userFolder).doc(user.uid).set(user.toJson());
  }

  static Future<Users> loadUser() async {
    String uid = (await HiveDB.load())!;
    var value = await instance.collection(userFolder).doc(uid).get();
    Users user = Users.fromJson(value.data()!);

    var querySnapshot1 = await instance.collection(userFolder).doc(uid).collection(followersFolder).get();
    user.followersCount = querySnapshot1.docs.length;

    var querySnapshot2 = await instance.collection(userFolder).doc(uid).collection(followingFolder).get();
    user.followingCount = querySnapshot2.docs.length;

    return user;
  }

  static Future<void> updateUser(Users user) async {
    return instance.collection(userFolder).doc(user.uid).update(user.toJson());
  }

  static Future<List<Users>> searchUsers(String keyword) async {
    Users user = await loadUser();
    List<Users> users = [];
    String uid = (await HiveDB.load())!;

    // write request
    var querySnapshot = await instance.collection(userFolder).orderBy("fullName").startAt([keyword]).endAt([keyword + '\uf8ff']).get();
    if (kDebugMode) {
      print(querySnapshot.docs.toString());
    }

    for (var element in querySnapshot.docs) {
      users.add(Users.fromJson(element.data()));
    }

    users.remove(user);

    List<Users> following = [];

    var querySnapshot2 = await instance.collection(userFolder).doc(uid).collection(followingFolder).get();
    for (var result in querySnapshot2.docs) {
      following.add(Users.fromJson(result.data()));
    }

    for(Users user in users){
      if(following.contains(user)){
        user.followed = true;
      }else{
        user.followed = false;
      }
    }

    return users;
  }

  static Future<Posts> storePost(Posts post) async{
    Users me = await loadUser();
    post.uid = me.uid;
    post.fullName = me.fullName;
    post.imageUser = me.imageUrl;
    post.userName = me.userName;
    post.createdDate = DateTime.now().toString();
    post.isLiked = false;
    post.isMine = true;

    String postId = instance.collection(userFolder).doc(me.uid).collection(postFolder).doc().id;
    post.id = postId;
    await instance.collection(userFolder).doc(me.uid).collection(postFolder).doc(postId).set(post.toJson());
    return post;
  }

  static Future<Posts> storeFeed(Posts post) async{
    String uid = (await HiveDB.load())!;

    await instance.collection(userFolder).doc(uid).collection(feedFolder).doc(post.id).set(post.toJson());
    return post;
  }

  static Future<List<Posts>> loadFeed() async {
    List<Posts> posts = [];
    String uid = (await HiveDB.load())!;
    var querySnapshot = await instance.collection(userFolder).doc(uid).collection(feedFolder).get();

    for(var e in querySnapshot.docs) {
      Posts post = Posts.fromJson(e.data());
      if(post.uid == uid) {
        post.isMine = true;
      } else {
        post.isMine = false;
      }
      posts.add(post);
    }

    return posts;
  }

  static Future<List<Posts>> loadPost() async {
    List<Posts> posts = [];
    String uid = (await HiveDB.load())!;
    var querySnapshot = await instance.collection(userFolder).doc(uid).collection(postFolder).get();
    for(var e in querySnapshot.docs) {
      Posts post = Posts.fromJson(e.data());
      if(post.uid == uid) post.isMine = true;
      posts.add(post);
    }

    return posts;
  }

  static Future<List<Posts>> loadOtherPost(Users users) async{
    List<Posts> posts = [];
    String uid = (await HiveDB.load())!;
    var querySnapshot = await instance.collection(userFolder).doc(users.uid).collection(postFolder).get();

    for(var e in querySnapshot.docs) {
      Posts post = Posts.fromJson(e.data());
      if(post.uid == uid) post.isMine = true;
      posts.add(post);
    }

    return posts;
  }

  static Future<Posts> likePost(Posts post, bool liked) async{
    String uid = (await HiveDB.load())!;
    post.isLiked = liked;

    await instance.collection(userFolder).doc(uid).collection(feedFolder).doc(post.id).set(post.toJson());

    if(uid == post.uid) {
      await instance.collection(userFolder).doc(uid).collection(postFolder).doc(post.id).set(post.toJson());
    }
    return post;
  }

  static Future<List<Posts>> loadLikes() async{
    String uid = (await HiveDB.load())!;
    List<Posts> posts = [];

    var querySnapshot = await instance.collection(userFolder).doc(uid).collection(feedFolder).where('isLiked', isEqualTo: true).get();

    for (var element in querySnapshot.docs) {
      Posts post = Posts.fromJson(element.data());
      posts.add(post);
    }
    return posts;
  }

  static Future<Users> followUser(Users someone) async{
    Users me = await loadUser();
    someone.followed = true;
    // me.followingCount++;
    //
    // await updateUser(me);

    // I followed to someone
    await instance.collection(userFolder).doc(me.uid).collection(followingFolder).doc(someone.uid).set(someone.toJson());

    // I am in someone`s followers
    await instance.collection(userFolder).doc(someone.uid).collection(followersFolder).doc(me.uid).set(me.toJson());

    return someone;
  }

  static Future<List<Users>> loadFollowedUsers() async{
    String uid = (await HiveDB.load())!;
    List<Users> users = [];

    var items =  await instance.collection(userFolder).doc(uid).collection(followingFolder).get();

    for(var user in items.docs) {
      users.add(Users.fromJson(user.data()));
    }
    return users;
  }

  static Future<Users> unFollowUser(Users someone) async{
    Users me = await loadUser();
    someone.followed = false;

    // I followed to someone
    await instance.collection(userFolder).doc(me.uid).collection(followingFolder).doc(someone.uid).delete();

    // I am in someone`s followers
    await instance.collection(userFolder).doc(someone.uid).collection(followersFolder).doc(me.uid).delete();

    return someone;
  }

  static Future storePostToMyFeeds(Users someone) async{
    List<Posts> posts = [];
    var querySnapshot = await instance.collection(userFolder).doc(someone.uid).collection(postFolder).get();

    for (var element in querySnapshot.docs) {
      Posts post = Posts.fromJson(element.data());
      post.isLiked = false;
      posts.add(post);
    }
    for(Posts post in posts) {
      await storeFeed(post);
    }
  }

  static Future removePostFromMyFeeds(Users someone) async{
    List<Posts> posts = [];
    var querySnapshot = await instance.collection(userFolder).doc(someone.uid).collection(postFolder).get();

    for (var element in querySnapshot.docs) {
      Posts post = Posts.fromJson(element.data());
      posts.add(post);
    }
    for(Posts post in posts) {
      removeFeed(post);
    }
  }

  static Future removeFeed(Posts post) async{
    String uid = (await HiveDB.load())!;

    return await instance.collection(userFolder).doc(uid).collection(feedFolder).doc(post.id).delete();
  }

  static Future removePost(Posts post) async{
    String uid = (await HiveDB.load())!;
    await removeFeed(post);
    return await instance.collection(userFolder).doc(uid).collection(postFolder).doc(post.id).delete();
  }

}