import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterinstagramclone/models/user_model.dart';
import 'package:flutterinstagramclone/services/data_service.dart';
import 'package:flutterinstagramclone/services/store_service.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  EditProfilePage({Key? key,}) : super(key: key);
  static const String id = 'edit_profile_page';
  // PageController? pageController;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  Users? users;
  File? _image;
  bool isLoading = false;
  TextEditingController fullNameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();

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
  }

  void _apiChangePhoto() {
    setState(() {
      isLoading = true;
    });
    if(_image != null) {
      StoreService.uploadImage(_image!, StoreService.folderUserImage).then((value) => _apiUpdateUser(value!));
    }else{
      _apiUpdateUser('null');
    }
  }

  void _apiUpdateUser(String imgUrl) async {
    String fullName = fullNameController.text.trim().toString();
    String userName = userNameController.text.trim().toString();
    setState(() {
      isLoading = false;
      if(imgUrl != 'null') users!.imageUrl = imgUrl;
      users!.userName = userName;
      users!.fullName = fullName;
    });
    DataService.updateUser(users!).then((value) {
      Navigator.pop(context);
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
      _initialController();
      isLoading = false;
    });
  }
  
  _initialController() {
    String fullName = users!.fullName;
    String userName = users!.userName;
    
    fullNameController = TextEditingController(text: fullName);
    userNameController = TextEditingController(text: userName);
  }


  @override
  void initState() {
    _apiLoadUser();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: CupertinoColors.black,
        backgroundColor: Colors.white,
        title: const Text('Edit profile', style: TextStyle(fontFamily: 'Billabong', fontSize: 27),),
        elevation: 1,
        leading: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(left: 10),
          child: InkWell(
            onTap: (){
              Navigator.pop(context);
              // widget.pageController!.animateToPage(4, duration: const Duration(milliseconds: 100), curve: Curves.easeIn);
            },
            child: const Text('Cancel', style: TextStyle(fontSize: 17),),
          ),
        ),
        leadingWidth: 70,
        actions: [
          Center(
            child: InkWell(
              onTap: (){
                _apiChangePhoto();
              },
              child: const Text('Done', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 17),),
            ),
          ),
          const SizedBox(width: 10,),
        ],

      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: users != null ? Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 15,),

                  //#userImage
                  Center(
                    child: InkWell(
                      radius: 65,
                      borderRadius: BorderRadius.circular(100),
                      onTap: (){
                        _showPicker(context);
                      },
                      child: _image == null ? Container(
                          height: 130,
                          width: 130,
                          padding: const EdgeInsets.all(13),
                          child: isLoading ? const CircularProgressIndicator(strokeWidth: 1.5, color: Color.fromRGBO(193, 53, 132, 1),) : users!.imageUrl != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: CachedNetworkImage(
                              imageUrl: users!.imageUrl!,
                              placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 3, color: Color.fromRGBO(193, 53, 132, 1),),
                              height: 130,
                              width: 130,
                              fit: BoxFit.cover,
                            ),
                          ) : const CircleAvatar(
                            radius: 38,
                            backgroundImage: AssetImage('assets/images/person_icon.png'),
                          )
                      ) : Container(
                        margin: const EdgeInsets.only(bottom: 10, top: 10),
                        height: 110,
                        width: 110,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.file(
                            _image!,
                            fit: BoxFit.cover,
                            height: double.infinity,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Center(
                    child: InkWell(
                      onTap: (){
                        _showPicker(context);
                      },
                      child: const Text('Change profile photo', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 16),),
                    ),
                  ),

                  const SizedBox(height: 10,),

                  Divider(color: Colors.grey.withOpacity(0.3),),

                  const SizedBox(height: 15,),

                  //#TextFields
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        //#FullName
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            const Text('Fullname', style: TextStyle(fontSize: 15.5),),

                            //#FullNameTextField
                            Container(
                              width: MediaQuery.of(context).size.width * 0.65,
                              height: 40,
                              child: TextField(
                                controller: fullNameController,
                                decoration: InputDecoration(
                                    hintText: 'Fullname',
                                    hintStyle: TextStyle(color: Colors.grey.shade300),
                                    border: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey.shade200, width: 1)
                                    )
                                ),
                              ),
                            ),

                          ],
                        ),

                        const SizedBox(height: 10,),

                        //#UserName
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            const Text('Username', style: TextStyle(fontSize: 15.5),),

                            //#UserNameTextField
                            Container(
                              width: MediaQuery.of(context).size.width * 0.65,
                              height: 40,
                              child: TextField(
                                controller: userNameController,
                                decoration: InputDecoration(
                                    hintText: 'Username',
                                    hintStyle: TextStyle(color: Colors.grey.shade300),
                                    border: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey.shade200, width: 1)
                                    )
                                ),
                              ),
                            ),

                          ],
                        ),

                        const SizedBox(height: 10,),

                        //#Pronouns
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            const Text('Pronouns', style: TextStyle(fontSize: 15.5),),

                            //#UserNameTextField
                            Container(
                              width: MediaQuery.of(context).size.width * 0.65,
                              height: 40,
                              child: TextField(
                                decoration: InputDecoration(
                                    hintText: 'Pronouns',
                                    hintStyle: TextStyle(color: Colors.grey.shade300),
                                    border: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey.shade200)
                                    )
                                ),
                              ),
                            ),

                          ],
                        ),

                        const SizedBox(height: 10,),

                        //#Website
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            const Text('Website', style: TextStyle(fontSize: 15.5),),

                            //#UserNameTextField
                            Container(
                              width: MediaQuery.of(context).size.width * 0.65,
                              height: 40,
                              child: TextField(
                                decoration: InputDecoration(
                                    hintText: 'Website',
                                    hintStyle: TextStyle(color: Colors.grey.shade300),
                                    border: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey.shade200)
                                    )
                                ),
                              ),
                            ),

                          ],
                        ),

                        const SizedBox(height: 10,),

                        //#Bio
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            const Text('Bio', style: TextStyle(fontSize: 15.5),),

                            //#UserNameTextField
                            Container(
                              width: MediaQuery.of(context).size.width * 0.65,
                              height: 40,
                              child: TextField(
                                decoration: InputDecoration(
                                    hintText: 'Bio',
                                    hintStyle: TextStyle(color: Colors.grey.shade300),
                                    border: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey.shade200)
                                    )
                                ),
                              ),
                            ),

                          ],
                        ),

                      ],
                    ),
                  ),

                  const SizedBox(height: 15,),

                  Divider(color: Colors.grey.withOpacity(0.3),),

                  //#switchProfessional
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: InkWell(
                      onTap: (){},
                      child: const Text('Switch to Professional Account', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500, fontSize: 16),),
                    ),
                  ),

                  Divider(color: Colors.grey.withOpacity(0.3),),

                  //#PersonalInfromation
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: InkWell(
                      onTap: (){},
                      child: const Text('Personal information settings', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500, fontSize: 16),),
                    ),
                  ),

                ],
              ),
              isLoading ? SizedBox(
                height: MediaQuery.of(context).size.height - 200,
                width: MediaQuery.of(context).size.width,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ) : const SizedBox.shrink(),
            ],
          ) : const Center(
                    child: CircularProgressIndicator(),
                  )
                ),
      ),
    );
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Photo Library'),
                    onTap: () {
                      _imgFromGallery();
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
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
