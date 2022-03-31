import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterinstagramclone/models/post_model.dart';
import 'package:flutterinstagramclone/models/user_model.dart';
import 'package:flutterinstagramclone/pages/edit_profile_page.dart';
import 'package:flutterinstagramclone/pages/my_posts_page.dart';
import 'package:flutterinstagramclone/pages/settings_page.dart';
import 'package:flutterinstagramclone/services/data_service.dart';
import 'package:flutterinstagramclone/services/store_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({Key? key}) : super(key: key);
  static const String id = 'my_profile_page';

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  PageController pageController = PageController();
  int _currentTap = 0;
  File? _image;
  bool isLoading = false;
  Users? users;
  List<Posts> listPosts = [];

  _loadPosts() {
    DataService.loadPost().then((value) {
      listPosts = value;
    });
  }

  _imgFromCamera() async {
    XFile? image = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image = File(image!.path);
    });
    _apiChangePhoto();
  }

  _imgFromGallery() async {
    XFile? image = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image = File(image!.path);
    });
    _apiChangePhoto();
  }

  // for load user
  void _apiLoadUser() async {
    setState(() {
      isLoading = true;
    });
    DataService.loadUser().then((items) {
      _showUserInfo(items);
    });
  }

  void _showUserInfo(Users user) {
    if(mounted){
      setState(() {
        users = user;
        isLoading = false;
      });
    }
  }

  // for edit user
  void _apiChangePhoto() {
    if (_image == null) return;

    setState(() {
      isLoading = true;
    });
    StoreService.uploadImage(_image!, StoreService.folderUserImage).then((value) => _apiUpdateUser(value!));
  }

  void _apiUpdateUser(String imgUrl) async {
    setState(() {
      isLoading = false;
      users!.imageUrl = imgUrl;
    });
    await DataService.updateUser(users!);
  }

  @override
  void initState() {
    _loadPosts();
    _apiLoadUser();
  super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return  users == null ? Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      child: const Center(child: CircularProgressIndicator()),
    ) : Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: GestureDetector(
            onTap: () {
              if (kDebugMode) {
                print('pressed');
              }
            },
            child: Row(
              children: [
                Text(
                  users!.userName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 24),
                ),
                const Icon(
                  CupertinoIcons.chevron_down,
                  size: 15,
                  color: Colors.black,
                ),
              ],
            ),
          ),
          actions: [
            //#add
            IconButton(
              onPressed: () {},
              icon: const Icon(
                CupertinoIcons.plus_app,
                color: Colors.black,
                size: 28,
              ),
              splashRadius: 25,
            ),

            //#menu
            IconButton(
              onPressed: () {
                _bottomSheet();
              },
              icon: const Icon(
                Icons.menu,
                color: Colors.black,
                size: 28,
              ),
              splashRadius: 25,
            ),
          ],
        ),
        body:  SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //#Header
              Container(
                margin: const EdgeInsets.only(right: 20, left: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _showPicker(context);
                      },
                      child: Stack(
                        children: [

                          Container(
                              height: 110,
                              width: 110,
                              padding: const EdgeInsets.all(13),
                              child: isLoading ? const CircularProgressIndicator(strokeWidth: 1.5, color: Color.fromRGBO(193, 53, 132, 1),) : users!.imageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: CachedNetworkImage(
                                          imageUrl: users!.imageUrl!,
                                          placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 3, color: Color.fromRGBO(193, 53, 132, 1),),
                                          height: 110,
                                          width: 110,
                                          fit: BoxFit.cover,
                                      ),
                                  )
                                  : const CircleAvatar(
                                radius: 38,
                                backgroundImage: AssetImage(
                                    'assets/images/person_icon.png'),
                              )),

                          Container(
                            alignment: Alignment.bottomRight,
                            width: 98,
                            height: 98,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(80),
                                color: Colors.grey[200],
                              ),
                              child: const Icon(
                                CupertinoIcons.add_circled_solid,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          listPosts.length.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text('Posts'),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          users!.followersCount.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text('Followers'),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          users!.followingCount.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text('Following'),
                      ],
                    ),
                  ],
                ),
              ),

              //#Description
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      users!.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    const Text('The student of Tashkent Financial Institute'),
                    const SizedBox(
                      height: 2,
                    ),
                    const Text('The flutter developer'),
                  ],
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              //#EditAddAccount
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      height: 38,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: Colors.black38),
                      ),
                      child: MaterialButton(
                        onPressed: () {
                          Navigator.pushNamed(context, EditProfilePage.id).then((value) {
                            _apiLoadUser();
                          });
                        },
                        child: Text('Edit Profile'),
                        height: 35,
                        minWidth: MediaQuery.of(context).size.width * 0.76,
                        elevation: 0,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      height: 38,
                      width: MediaQuery.of(context).size.width * 0.1,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: Colors.black38),
                      ),
                      child: MaterialButton(
                        minWidth: MediaQuery.of(context).size.width * 0.04,
                        onPressed: () {},
                        child: const Icon(
                          CupertinoIcons.person_add,
                          size: 20,
                        ),
                        padding: const EdgeInsets.all(0),
                      ),
                    ),
                  ],
                ),
              ),

              //#highlites
              Container(
                  height: 100,
                  margin: const EdgeInsets.only(top: 15, bottom: 10),
                  child: ListView.builder(
                      itemCount: 10,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                //#Image
                                Container(
                                  height: 70,
                                  width: 70,
                                  padding: EdgeInsets.all(3),
                                  margin: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                        color: Colors.grey.withOpacity(0.8)),
                                  ),
                                  child: Container(
                                    // padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(
                                          color: Colors.grey.withOpacity(0.8)),
                                    ),
                                    child: const CircleAvatar(
                                      radius: 30,
                                      backgroundImage: AssetImage(
                                          'assets/images/person_icon.png'),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            //#title
                            Text('title'),
                          ],
                        );
                      })),

              //#Buttons
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 60),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _currentTap = 0;
                          pageController.animateToPage(0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn);
                        });
                      },
                      icon: Icon(CupertinoIcons.rectangle_split_3x3,
                          size: 27,
                          color: _currentTap == 0 ? Colors.black : Colors.grey),
                      splashRadius: 25,
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _currentTap = 1;
                          pageController.animateToPage(1,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn);
                        });
                      },
                      icon: Icon(CupertinoIcons.play,
                          size: 27,
                          color: _currentTap == 1 ? Colors.black : Colors.grey),
                      splashRadius: 25,
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _currentTap = 2;
                          pageController.animateToPage(2,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn);
                        });
                      },
                      icon: Icon(Icons.person_pin_outlined,
                          size: 27,
                          color: _currentTap == 2 ? Colors.black : Colors.grey),
                      splashRadius: 25,
                    ),
                  ],
                ),
              ),

              //PostImages
              Container(
                height: ((posts.length /3) < 1) ? MediaQuery.of(context).size.height * 0.2
                    : MediaQuery.of(context).size.height * (posts.length /3 - posts.length % 3) * 0.2,
                child: PageView(
                  controller: pageController,
                  onPageChanged: (int index) {
                    setState(() {
                      _currentTap = index;
                    });
                  },
                  children: [
                    _gridView(),
                    _gridView(),
                    _gridView(),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _gridView() {
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 3 / 3,
            crossAxisCount: 3,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2),
        itemCount: listPosts.length,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, MyPostsPage.id).then((value) => _apiLoadUser());
            },
            child: CachedNetworkImage(
              imageUrl: listPosts[index].postImage,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  // height: MediaQuery.of(context).size.height * 0.5,
                  // width: MediaQuery.of(context).size.width,
                  color: Colors.grey[300],
                ),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          );
        });
  }

  void _bottomSheet() {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        context: context,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.6,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15))),
            child: Column(
              children: [
                const SizedBox(
                  height: 30,
                ),

                //#settings
                _listTile(
                    icon: CupertinoIcons.gear,
                    text: "Settings",
                    goingPage: SettingsPage.id),

                //#yourActivity
                _listTile(icon: CupertinoIcons.timer, text: "Your activity"),

                //#archives
                _listTile(icon: CupertinoIcons.time, text: "Archives"),

                //#QRcode
                _listTile(
                    icon: CupertinoIcons.qrcode_viewfinder, text: "QR code"),

                //#saved
                _listTile(icon: CupertinoIcons.bookmark, text: "Saved"),

                //#closeFriends
                _listTile(
                    icon: CupertinoIcons.square_favorites,
                    text: "Close Friends"),

                //#closeFriends
                _listTile(
                    icon: CupertinoIcons.heart_circle,
                    text: "COVID-19 Information Center"),
              ],
            ),
          );
        });
  }

  Widget _listTile({required icon, required text, goingPage}) {
    return ListTile(
      minVerticalPadding: 0.0,
      leading: Icon(
        icon,
        color: Colors.black,
        size: 28,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 15,
          ),
          Text(
            text,
            style: const TextStyle(color: Colors.black, fontSize: 17),
          ),
          const SizedBox(
            height: 5,
          ),
          const Divider(
            color: Colors.black12,
          ),
        ],
      ),
      onTap: () {
        _go(page: goingPage);
      },
    );
  }

  _go({page}) {
    Navigator.popAndPushNamed(context, page);
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: Icon(Icons.photo_library),
                    title: Text('Photo Library'),
                    onTap: () {
                      _imgFromGallery();
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text('Camera'),
                  onTap: () {
                    _imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }
}
