import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hostelapplication/core/constant/textController.dart';
import 'package:hostelapplication/logic/provider/notice_provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddNoticeScreen extends StatefulWidget {
  const AddNoticeScreen({super.key});

  @override
  State<AddNoticeScreen> createState() => _AddNoticeScreenState();
}

class _AddNoticeScreenState extends State<AddNoticeScreen> {
  File? imageFile;
  PlatformFile? pickedFile;
  bool showLoading = false;

  @override
  Widget build(BuildContext context) {
    final noticeProvider = Provider.of<NoticeProvider>(context);

    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
          title: const Text(
            'Add Notice',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 18.0, left: 18, right: 18, bottom: 50),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(width: 1),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 15,
                          ),
                          const Text(
                            "NOTICE ",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 18.0, left: 18, right: 18, bottom: 10),
                            child: TextFormField(
                              onChanged: ((value) =>
                                  noticeProvider.changeNotice(value)),
                              controller: noticeController,
                              decoration: InputDecoration(
                                  focusedBorder: const OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                  hintText:
                                      "Type notice/instruction here...... 🖍",
                                  border: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Colors.grey,
                                      ),
                                      borderRadius: BorderRadius.circular(10))),
                              maxLines: 8,
                              keyboardType: TextInputType.multiline,
                              maxLength: 1000,
                              cursorColor: Colors.black,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 18.0, right: 20),
                            child: Center(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 0, 0, 0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                onPressed: () {
                                  selectImage();
                                },
                                child: const Text(
                                  "Add Attachment",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          pickedFile != null || imageFile != null
                              ? Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  padding: const EdgeInsets.all(5),
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  child: Text(
                                    "${pickedFile?.name ?? imageFile?.path}",
                                    softWrap: false,
                                    overflow: TextOverflow.fade,
                                    maxLines: 2,
                                  ),
                                )
                              : const SizedBox(),
                          const SizedBox(
                            height: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    left: 0,
                    bottom: 20,
                    child: FloatingActionButton(
                      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                      onPressed: () async {
                        // if (pickedFile == null && imageFile == null) {
                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //     SnackBar(
                        //       content: Text('Please select a file to upload'),
                        //     ),
                        //   );
                        //   return;
                        // }

                        setState(() {
                          showLoading = true;
                        });
                        progressIndicater(context, showLoading = true);
                        final ref = FirebaseStorage.instance
                            .ref()
                            .child('noticeImg')
                            .child(pickedFile?.name ?? imageFile?.path ?? '');
                        if (ref != '' && imageFile != null) {
                          await ref.putFile(imageFile!);
                          String? url = await ref.getDownloadURL();
                          noticeProvider.changeUrl(url);
                        } else {
                          noticeProvider.changeUrl('');
                        }

                        noticeProvider.changetime(DateTime.now());
                        noticeProvider.saveNotice();
                        noticeController.clear();
                        setState(() {
                          showLoading = false;
                        });
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.done,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> selectImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      imageFile = File(pickedFile.path);
      this.pickedFile = null; // Reset pickedFile when an image is selected
    });
  }

  Future<dynamic>? progressIndicater(BuildContext context, showLoading) {
    if (showLoading == true) {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          });
    } else
      return null;
  }
}
