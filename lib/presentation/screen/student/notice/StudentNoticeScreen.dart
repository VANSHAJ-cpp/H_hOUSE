// ignore_for_file: must_be_immutable

import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:hostelapplication/logic/modules/notice_model.dart';
import 'package:hostelapplication/presentation/screen/student/studentDrawer.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({Key? key}) : super(key: key);

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  int _currentImageIndex = 0;
  late CarouselController _carouselController;
  late PageController _pageController;
  int _currentPage = 0;

  @override
  late Future<List<String>> _sliderImagesFuture;

  @override
  void initState() {
    super.initState();
    _sliderImagesFuture = fetchSliderImages();
    _carouselController = CarouselController();
    _pageController = PageController();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _showNotificationPopup(context);
    });

    // Start autoplay when the widget is initialized
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      // Call startAutoplay after the PageView is built
      startAutoplay();
    });
  }

  Future<List<String>> fetchSliderImages() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('slider_images').get();
    final sliderImages =
        snapshot.docs.map((doc) => doc['url'] as String).toList();
    return sliderImages;
  }

  Future<void> _showNotificationPopup(BuildContext context) async {
    TextEditingController reviewController = TextEditingController();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasAddedReview = prefs.getBool('hasAddedReview') ?? false;
    if (!hasAddedReview) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 5,
                    width: 50,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 10, 10, 10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'H House Reviews & Feedback',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 24,
                      ),
                      SizedBox(width: 5),
                      Text(
                        '4.9/5',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Reviews:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  _buildReviewTile(
                    Icons.star,
                    'Great hostel! Highly recommended.',
                  ),
                  _buildReviewTile(
                    Icons.star,
                    'Clean rooms and friendly staff.',
                  ),
                  _buildReviewTile(
                    Icons.star,
                    'Good amenities and convenient location.',
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Add Your Review:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  TextField(
                    controller: reviewController,
                    decoration: const InputDecoration(
                      hintText: 'Write your review...',
                      border: OutlineInputBorder(),
                    ),
                    minLines: 1,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      String newReview = reviewController.text.trim();
                      if (newReview.isNotEmpty) {
                        print('New Review: $newReview');
                        // Save information that the user has added a review
                        prefs.setBool('hasAddedReview', true);
                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Review added successfully!'),
                          ),
                        );
                        // Clear review text field
                        reviewController.clear();
                        // Close the modal bottom sheet
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a review.'),
                          ),
                        );
                      }
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    child: const Text(
                      'Add Review',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Mazzard'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildReviewTile(IconData icon, String review) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.amber,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              review,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void startAutoplay() {
    // Autoplay feature
    Future.delayed(const Duration(seconds: 3), () {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 800),
        curve: Curves.ease,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final noticeList = Provider.of<List<Notice>?>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'DashBoard',
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Mazzard",
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.rate_review),
            onPressed: () {
              _showNotificationPopup(context);
            },
          ),
        ],
      ),
      drawer: const StudentDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FutureBuilder<List<String>>(
            future: _sliderImagesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              final sliderImages = snapshot.data!;

              return CarouselSlider(
                items: sliderImages.map((imageUrl) {
                  return Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  );
                }).toList(),
                options: CarouselOptions(
                  height: 200,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.8,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: true,
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Expanded(
            child: noticeList != null
                ? GroupedListView<Notice, String>(
                    elements: [...noticeList],
                    groupBy: (element) {
                      final formattedDate =
                          DateFormat('dd MMMM yyyy').format(element.time);

                      return formattedDate;
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
                    order: GroupedListOrder.DESC,
                    itemBuilder: (c, element) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: NoticeContainer(
                            element.notice,
                            element.time.day.toString() +
                                '/' +
                                element.time.month.toString() +
                                '/' +
                                element.time.year.toString(),
                            element.url!),
                      );
                    },
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
        ],
      ),
    );
  }
}

class NoticeContainer extends StatelessWidget {
  const NoticeContainer(this.notice, this.date, this.src, {super.key});

  final String notice;
  final String date;
  final String adminName = "Admin";
  final String src;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                adminName,
                style: const TextStyle(
                  fontSize: 16,
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
          if (src.isNotEmpty) _buildImagePreview(context),
        ],
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showImageDialog(context, notice, src);
      },
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade200,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            src,
            fit: BoxFit.cover,
          ),
        ),
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

class BulletLists extends StatelessWidget {
  const BulletLists(this.str, {super.key});
  final String str;
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '\u2022',
              style: TextStyle(
                fontSize: 20,
                height: 1.55,
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            Expanded(
              child: Text(
                "${str}",
                textAlign: TextAlign.left,
                softWrap: true,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  height: 1.55,
                ),
              ),
            ),
          ],
        ),
      ]),
    );
  }
}
