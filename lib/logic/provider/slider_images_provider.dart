import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class SliderImagesProvider extends ChangeNotifier {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _sliderImages = [];

  List<String> get sliderImages => _sliderImages;

  Future<void> fetchSliderImages() async {
    try {
      // Fetch data from Firestore collection
      QuerySnapshot querySnapshot =
          await _firestore.collection('slider_images').get();

      // Extract image URLs from documents and populate _sliderImages list
      _sliderImages =
          querySnapshot.docs.map((doc) => doc['url'] as String).toList();

      notifyListeners();
    } catch (error) {
      print("Error fetching slider images: $error");
    }
  }

  Future<void> addImage(String imageUrl) async {
    try {
      // Add image URL to Firestore collection
      await _firestore.collection('slider_images').add({'url': imageUrl});

      // Update local list
      _sliderImages.add(imageUrl);
      notifyListeners();
    } catch (error) {
      print("Error adding image: $error");
    }
  }

  Future<void> deleteImage(int index) async {
    try {
      // Existing code to delete image
    } catch (error) {
      print("Error deleting image: $error");
    }
  }
}
