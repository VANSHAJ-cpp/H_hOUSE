// ignore_for_file: must_be_immutable

import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:hostelapplication/core/constant/string.dart';
import 'package:hostelapplication/logic/modules/notice_model.dart';
import 'package:hostelapplication/logic/provider/notice_provider.dart';
import 'package:hostelapplication/logic/provider/slider_images_provider.dart';
import 'package:hostelapplication/presentation/screen/admin/AdminDrawer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../Booking/adminbooking.dart';

class SliderImagesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('slider_images').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        // Extract image URLs from snapshot
        final List<String> imageUrls =
            snapshot.data!.docs.map((doc) => doc['url'] as String).toList();

        // Check if image URLs are available
        if (imageUrls.isNotEmpty) {
          return CarouselSlider(
            items: imageUrls.map((url) => Image.network(url)).toList(),
            options: CarouselOptions(
              height: 200,
              aspectRatio: 16 / 9,
              viewportFraction: 0.8,
              initialPage: 0,
              enableInfiniteScroll: true,
              reverse: false,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: true,
              onPageChanged: (index, reason) {
                // Handle page change here if needed
              },
              scrollDirection: Axis.horizontal,
            ),
          );
        } else {
          // Return a placeholder widget if no images are available
          return Container(
            height: 200,
            color: Colors.grey.withOpacity(0.5),
            child: const Center(
              child: Text('No images available'),
            ),
          );
        }
      },
    );
  }
}

class AdminHome extends StatefulWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome>
    with SingleTickerProviderStateMixin {
  int _currentImageIndex = 0;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();

    deleteDuplicateImages();
  }

  @override
  Widget build(BuildContext context) {
    final noticeList = Provider.of<List<Notice>?>(context);
    final noticeProvider = Provider.of<NoticeProvider>(context);
    final sliderImagesProvider = Provider.of<SliderImagesProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.pushNamed(context, '/registrationScreenRoute');
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _showImageEditDialog(context, sliderImagesProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons
                .calendar_today), // Add the icon for redirecting to AdminBookingScreen
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminBookingScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SliderImagesWidget(), // Use the SliderImagesWidget here
          const SizedBox(height: 10),
          Expanded(
            child: noticeList != null
                ? GroupedListView<Notice, String>(
                    elements: [...noticeList],
                    groupBy: (element) {
                      final formattedDate = DateFormat('yyyy-MM-dd')
                          .format(element.time); // Format as yyyy-MM-dd
                      return formattedDate;
                    },
                    groupComparator: (group1, group2) {
                      // Sort groups in descending order based on date
                      return group2.compareTo(group1);
                    },
                    itemComparator: (item1, item2) {
                      // Sort items in descending order based on full date
                      return item2.time.compareTo(item1.time);
                    },
                    groupSeparatorBuilder: (String value) => Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            value.toString() == 'null'
                                ? 'No Date'
                                : value.toString() == 'All'
                                    ? 'All'
                                    : "$value",
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    itemBuilder: (c, element) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: NoticeContainer(
                          element.notice,
                          DateFormat('dd MMMM yyyy').format(element.time),
                          element.url!,
                          () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                content: const Text(
                                    "Are you sure you want to delete ?"),
                                actions: [
                                  TextButton(
                                    child: const Text(
                                      "Cancel",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text(
                                      "Delete",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onPressed: () {
                                      noticeProvider.deleteNotice(element.id);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _animation,
        child: FloatingActionButton.extended(
          backgroundColor: Colors.black,
          onPressed: () {
            Navigator.pushNamed(context, addNoticeScreenRoute);
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Notice'),
        ),
      ),
      drawer: const AdminDrawer(),
    );
  }

  void _showImageEditDialog(
      BuildContext context, SliderImagesProvider sliderImagesProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          "Edit Slider Images",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Add Image
              ListTile(
                title: const Text(
                  "Add Image",
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () {
                  _addImage(context, sliderImagesProvider);
                  Navigator.of(context).pop(); // Dismiss dialog after action
                },
              ),
              // if (sliderImagesProvider.sliderImages
              //     .isNotEmpty) // Only show delete option if there are images
              ListTile(
                title: const Text(
                  "Delete Image",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  _deleteImage(context);
                  Navigator.of(context).pop(); // Dismiss dialog after action
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addImage(
      BuildContext context, SliderImagesProvider sliderImagesProvider) async {
    final picker = ImagePicker();
    XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('slider_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      UploadTask uploadTask = ref.putFile(File(pickedFile.path));

      try {
        TaskSnapshot taskSnapshot = await uploadTask;
        String imageUrl = await taskSnapshot.ref.getDownloadURL();

        // Fetch all existing image URLs from Firestore
        QuerySnapshot querySnapshot =
            await FirebaseFirestore.instance.collection('slider_images').get();

        // List to hold existing image URLs
        List<String> existingUrls =
            querySnapshot.docs.map((doc) => doc['url'] as String).toList();

        // Flag to track if the new image URL is a duplicate
        bool isDuplicate = false;

        // Compare the new image URL with existing URLs
        for (String existingUrl in existingUrls) {
          if (existingUrl == imageUrl) {
            isDuplicate = true;
            break;
          }
        }

        // If the new image URL is not a duplicate, add it to Firestore
        if (!isDuplicate) {
          await FirebaseFirestore.instance.collection('slider_images').add({
            'url': imageUrl,
          });

          sliderImagesProvider.addImage(imageUrl);
        } else {
          print('Image URL already exists in Firestore');
        }
      } catch (error) {
        print('Error uploading image: $error');
        // Handle error uploading image
      }
    } else {
      // User canceled the image picker
    }
  }

  void _deleteImage(BuildContext context) async {
    // Fetch the list of image URLs from Firestore
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('slider_images').get();

    // Initialize a set to track selected image URLs
    Set<String> selectedImages = {};

    // Show a dialog to select images for deletion
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          "Select Image(s) to Delete",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  alignment: WrapAlignment.start,
                  children: [
                    ...querySnapshot.docs.map((doc) {
                      String imageUrl = doc['url'] as String;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selectedImages.contains(imageUrl)) {
                              selectedImages.remove(imageUrl);
                            } else {
                              selectedImages.add(imageUrl);
                            }
                          });
                        },
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: selectedImages.contains(imageUrl)
                                      ? Colors.green
                                      : Colors.transparent,
                                  width: 2.0,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                            ),
                            if (selectedImages.contains(imageUrl))
                              Positioned.fill(
                                child: Container(
                                  color: Colors.black.withOpacity(0.5),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog without deletion
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () async {
              // Delete selected images
              for (String imageUrl in selectedImages) {
                // Delete the image from Firebase Storage
                Reference storageRef =
                    FirebaseStorage.instance.refFromURL(imageUrl);
                try {
                  await storageRef.delete();
                } catch (e) {
                  print("Error deleting image from storage: $e");
                  // Handle error, maybe show a snackbar
                }

                // Delete the image document from Firestore
                QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                    .collection('slider_images')
                    .where('url', isEqualTo: imageUrl)
                    .get();
                querySnapshot.docs.forEach((doc) async {
                  try {
                    await doc.reference.delete();
                  } catch (e) {
                    print("Error deleting image document from Firestore: $e");
                    // Handle error, maybe show a snackbar
                  }
                });
              }

              // Close the dialog
              Navigator.pop(context);
            },
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> deleteDuplicateImages() async {
    try {
      // Fetch all image URLs from Firestore
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('slider_images').get();

      // List to hold URLs of duplicate images
      List<String> duplicateUrls = [];

      // Loop through each document in the query snapshot
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        String currentUrl = doc['url'] as String;

        // Query Firestore again to find documents with the same URL
        QuerySnapshot duplicateQuerySnapshot = await FirebaseFirestore.instance
            .collection('slider_images')
            .where('url', isEqualTo: currentUrl)
            .get();

        // If more than one document is found with the same URL, it's a duplicate
        if (duplicateQuerySnapshot.size > 1) {
          // Add the URL to the list of duplicates
          duplicateUrls.add(currentUrl);
        }
      }

      // Delete duplicate images from Firestore and Storage
      for (String url in duplicateUrls) {
        // Delete the image document from Firestore
        QuerySnapshot docsToDelete = await FirebaseFirestore.instance
            .collection('slider_images')
            .where('url', isEqualTo: url)
            .get();

        docsToDelete.docs.forEach((doc) async {
          await doc.reference.delete();
        });

        // Delete the image from Firebase Storage
        Reference storageRef = FirebaseStorage.instance.refFromURL(url);
        await storageRef.delete();
      }
    } catch (error) {
      print('Error deleting duplicate images: $error');
      // Handle error, maybe show a snackbar
    }
  }
}

class NoticeContainer extends StatelessWidget {
  NoticeContainer(this.notice, this.date, this.src, this.delete, {Key? key})
      : super(key: key);

  final String notice;
  final String date;
  final String adminName = "Admin";
  final String src;
  final Function delete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
            ),
            child: Center(
              child: Text(
                adminName[0],
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      adminName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 13, 71, 161),
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  notice,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (src.isNotEmpty) const SizedBox(height: 12),
                if (src.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _showImageDialog(context, notice, src);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        src,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container();
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => delete(),
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  void _showImageDialog(BuildContext context, String notice, String src) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                notice,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            FutureBuilder(
              future: _getImageSize(src),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                double? imageHeight = snapshot.data as double?;
                return imageHeight != null && imageHeight > 300
                    ? SizedBox(
                        height: 300,
                        child: SingleChildScrollView(
                          child: _buildImageContainer(src),
                        ),
                      )
                    : _buildImageContainer(src);
              },
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContainer(String src) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          src,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Future<double> _getImageSize(String imageUrl) async {
    Completer<double> completer = Completer<double>();
    Image image = Image.network(imageUrl);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo info, bool _) {
          completer.complete(info.image.height.toDouble());
        },
      ),
    );
    return completer.future;
  }
}
