import 'package:firebase_database/firebase_database.dart';
import 'package:flutterinstagramclone/models/post_model.dart';

class RTDService {
  static final _database = FirebaseDatabase.instance.ref();

  static Future<Stream> addPost(Posts post) async {
    _database.child('posts').push().set(post.toJson());
    return _database.onChildAdded;
  }

  // static Future<Stream> updatePost({required name, required phoneNumber, required key, required imageUrl}) async{
  //   await _database.child('posts').child(key).update({
  //     'name' : name,
  //     'phoneNumber': phoneNumber,
  //     'imageUrl' : imageUrl
  //   });
  //   return _database.onChildAdded;
  // }

  static Future<void> deletePost({required key}) async{
    await _database.child('posts').child(key).remove();
  }

  static Future<List<Posts>> getPosts() async {
    List<Posts> items = [];
    Query _query = _database.child('posts').orderByChild('key');
    var result = await _query.once();

    items = result.snapshot.children.map((e) {
      Map<String, dynamic> post = Map<String, dynamic>.from(e.value as Map);
      post['key'] = e.key;
      return Posts.fromJson(post);
    }).toList();
    return items;
  }
}
