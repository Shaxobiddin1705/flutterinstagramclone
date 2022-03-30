import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterinstagramclone/models/post_model.dart';
import 'package:flutterinstagramclone/models/user_model.dart';
import 'package:flutterinstagramclone/services/data_service.dart';
import 'package:flutterinstagramclone/services/store_service.dart';
import 'package:image_picker/image_picker.dart';

class MyUploadPage extends StatefulWidget {
  MyUploadPage({Key? key, this.pageController}) : super(key: key);
  static const String id = 'my_upload_page';
  PageController? pageController;

  @override
  State<MyUploadPage> createState() => _MyUploadPageState();
}

class _MyUploadPageState extends State<MyUploadPage> {
  TextEditingController captionController = TextEditingController();
  File? _image;
  bool isLoading = false;

  Future<void> getImage({required ImageSource source}) async{
    Navigator.pop(context);
    var image = await ImagePicker().pickImage(source: source);
    if(image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  void _addPost() async{
    String caption = captionController.text.trim().toString();
    // final FirebaseAuth  _auth = FirebaseAuth.instance;
    if(caption.isEmpty || _image == null) return;
    _postImage(caption: caption);
  }

  _postImage({caption}) {
    late Posts post;
    setState(() {
      isLoading = true;
    });
    StoreService.uploadImage(_image!, StoreService.folderPostImage).then((value) => {
      post = Posts(postImage: value!, caption: caption),
      DataService.storePost(post).then((value) {
        setState(() {
          isLoading = false;
        });
        _goFeedPage(post);
      }),
    });
  }

  void _goFeedPage(Posts post) async{
    DataService.storeFeed(post).then((value) {
      widget.pageController!.animateToPage(0, duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
      _image = null;
      captionController.clear();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Upload", style: TextStyle(fontFamily: "Billabong", fontSize: 25, color: Colors.black),),
        centerTitle: true,
        actions: [

          IconButton(
              onPressed: (){
                _addPost();
              },
              icon: const Icon(Icons.post_add, color: Color.fromRGBO(193, 53, 132, 1),)
          ),

        ],
      ),

      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                children: [

                  // #image
                  InkWell(
                    onTap: () {
                      _bottomSheet();
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.width,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.grey.shade300,
                      child: _image != null ?
                      Stack(
                        children: [
                          Image.file(_image!,
                            fit: BoxFit.cover,
                            height: double.infinity,
                            width: double.infinity,),

                          Container(
                            height: double.infinity,
                            width: double.infinity,
                            alignment: Alignment.topRight,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _image = null;
                                });
                              },
                              icon: const Icon(Icons.cancel_outlined, color: Colors.white,),
                            ),
                          )
                        ],
                      )
                          : const Center(
                        child: Icon(Icons.add_a_photo, size: 60, color: Colors.grey,),
                      ),
                    ),
                  ),

                  // #caption
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10.0),
                    child: TextField(
                      controller: captionController,
                      decoration: const InputDecoration(
                        hintText: "Caption",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      keyboardType: TextInputType.multiline,
                    ),
                  )
                ],
              ),
              isLoading ? SizedBox(
                height: MediaQuery.of(context).size.height - 250,
                width: MediaQuery.of(context).size.width,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ) : const SizedBox.shrink(),
            ],
          )
        ),
      ),

    );
  }

  void _bottomSheet() {

    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            width: MediaQuery.of(context).size.width,
            height: 120,
            child: Column(
              children: [

                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text("Pick Photo"),
                  onTap: () {
                    getImage(source: ImageSource.gallery);
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded),
                  title: const Text("Take Photo"),
                  onTap: () {
                    getImage(source: ImageSource.camera);
                  },
                ),

              ],
            ),
          );
        }
    );
  }

}
