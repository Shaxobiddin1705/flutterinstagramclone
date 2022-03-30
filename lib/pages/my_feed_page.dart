import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterinstagramclone/models/post_model.dart';
import 'package:flutterinstagramclone/models/user_model.dart';
import 'package:flutterinstagramclone/services/data_service.dart';
import 'package:flutterinstagramclone/services/real_time_database.dart';
import 'package:flutterinstagramclone/services/store_service.dart';
import 'package:shimmer/shimmer.dart';
class MyFeedPage extends StatefulWidget {
  MyFeedPage({Key? key, this.message}) : super(key: key);
  static const String id = 'my_feed_page';
  String? message;

  @override
  State<MyFeedPage> createState() => _MyFeedPageState();
}

class _MyFeedPageState extends State<MyFeedPage> {
  bool isLoading = false;
  bool onPressed = false;
  bool isLiking = false;
  Users? users;

  void _loadPosts() async{
    setState(() {
      isLoading = true;
    });
    DataService.loadFeed().then((items) {
      _showResponse(items);
    });
  }

  _showResponse(List<Posts> items) {
    setState((){
      posts = items;
      isLoading = false;
    });
  }

  void _apiLoadUser() async {
    setState(() {
      isLoading = true;
    });
    DataService.loadUser().then((items) {
      _showUserInfo(items);
    });
  }

  void _showUserInfo(Users user) {
    setState(() {
      users = user;
      isLoading = false;
    });
  }

  _deletePost({required key, required index}) {
    RTDService.deletePost(key: key);
    StoreService.deleteImage(posts[index].postImage);
    _loadPosts();
  }

  _apiPostLike(Posts post) async{
    setState(() {
      isLiking = true;
    });
    await DataService.likePost(post, true);
    setState(() {
      isLiking = false;
      post.isLiked = true;
    });
  }

  _apiPostUnlike(Posts post) async{
    setState(() {
      isLiking = true;
    });
    await DataService.likePost(post, false);
    setState(() {
      isLiking = false;
      post.isLiked = false;
    });
  }

  @override
  void initState() {
    _loadPosts();
    _apiLoadUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Instagram', style: TextStyle(fontSize: 30, fontFamily: 'Billabong', color: Colors.black),),

        actions: [
          IconButton(
              onPressed: (){},
              icon: const Icon(CupertinoIcons.bolt_horizontal_circle, color: Colors.black,)
          ),
        ],
      ),

      body: Stack(
        children: [
          posts.isNotEmpty ? ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return _post(index: index);
              }
          ) : SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 150,
                child: const Center(
                  child: Text('No posts yet', style: TextStyle(fontSize: 19),),
                ),
          ),
          isLiking ? SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 250,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ) : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _post({index}) {
    return (isLoading || users == null) ? SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height - 200,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    ) : SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const SizedBox(height: 10,),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [

                //#UserImageUserName
                Container(
                  width: MediaQuery.of(context).size.width * 0.82,
                  child: Row(
                    children: [

                      users == null || posts[index].imageUser == null ?
                      const CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage('assets/images/person_icon.png'),
                      ) : ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: CachedNetworkImage(
                          imageUrl: posts[index].imageUser!,
                          placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 3, color: Color.fromRGBO(193, 53, 132, 1),),
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(width: 10,),

                      Text(posts[index].userName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),)
                    ],
                  ),
                ),

                IconButton(
                  onPressed: (){},
                  icon: const Icon(Icons.more_horiz_rounded),
                  splashRadius: 20,
                )

              ],
            ),
          ),

          const SizedBox(height: 10,),

          //#Image
          GestureDetector(
            onDoubleTap: () {
              if(!posts[index].isLiked) {
                _apiPostLike(posts[index]);
              }else{
                _apiPostUnlike(posts[index]);
              }
            },
            child: CachedNetworkImage(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width,
              imageUrl: posts[index].postImage, fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.grey[300],
                ),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: MediaQuery.of(context).size.width,
            child: Row(
              children: [

                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      //#heart
                      IconButton(
                        onPressed: (){
                          if(!posts[index].isLiked) {
                            _apiPostLike(posts[index]);
                          }else{
                            _apiPostUnlike(posts[index]);
                          }
                        },
                        icon: Icon(
                          posts[index].isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                          color: posts[index].isLiked ?Colors.red : Colors.black,
                        ),
                        splashRadius: 20,
                      ),

                      //#commint
                      IconButton(
                        onPressed: (){},
                        icon: Image.asset('assets/images/chat.png', height: 28,),
                        splashRadius: 20,
                      ),

                      //#send
                      IconButton(
                        onPressed: (){},
                        icon: const Icon(CupertinoIcons.paperplane),
                        splashRadius: 20,
                      ),

                    ],
                  ),
                ),

                Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [

                        //#Save
                        IconButton(
                          onPressed: (){},
                          icon: const Icon(CupertinoIcons.bookmark),
                          splashRadius: 20,
                        ),
                      ],
                    )
                ),

              ],
            ),
          ),

          Container(
              margin: const EdgeInsets.only(left: 20,),
              child: Text(posts[index].createdDate, style: const TextStyle(color: Colors.grey),)
          ),

          const SizedBox(height: 3,),

          Container(
            margin: const EdgeInsets.only(left: 20,),
            child: Text(posts[index].caption, maxLines: 2, style: const TextStyle(fontSize: 16),),
          ),

        ],
      ),
    );
  }
}
