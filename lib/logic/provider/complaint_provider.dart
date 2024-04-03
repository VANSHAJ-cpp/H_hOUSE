import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:hostelapplication/logic/modules/complaint_model.dart';
import 'package:hostelapplication/logic/service/fireStoreServices/complaint_firestore_service.dart';
import 'package:uuid/uuid.dart';

class ComplaintProvider with ChangeNotifier {
  final service = ComplaintFirestoreService();
  late String _complaint;
  late String _complaintTitle;
  late String _studentUid;
  late String _roomNo;
  late String _name;
  DateTime _time = DateTime.now();
  var uuid = Uuid();

  // Add image file variable
  File? _imageFile;
  String? _imageUrl; // Add image URL variable

  // getter
  String get getCommplaint => _complaint;
  String get getComplaintTitle => _complaintTitle;
  String get gerStudentUid => _studentUid;
  String get gerRoomNo => _roomNo;
  String get gerName => _name;
  File? get imageFile => _imageFile; // Getter for image file
  String? get imageUrl => _imageUrl; // Getter for image URL

  // setter
  void changeComplaint(String value) {
    _complaint = value;
  }

  void changeComplaintTitle(String value) {
    _complaintTitle = value;
  }

  void changeStudentUid(String value) {
    _studentUid = value;
  }

  void changeRoomNo(String value) {
    _roomNo = value;
  }

  void changeName(String value) {
    _name = value;
  }

  void setImageFile(File? file) {
    _imageFile = file; // Setter for image file
  }

  Future<void> saveComplaint() async {
    // ... other code

    if (_imageFile != null) {
      try {
        // Upload image to Firebase Storage
        final firebase_storage.Reference ref = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('complaint_images')
            .child('${uuid.v4()}.jpg');
        final firebase_storage.UploadTask uploadTask = ref.putFile(_imageFile!);
        await uploadTask.whenComplete(() async {
          // Get image URL after upload
          _imageUrl = await ref.getDownloadURL();
        });
      } catch (e) {
        print("Error uploading image: $e");
      }
    }

    // Create Complaint object
    // Create Complaint object
    var newComplaint = Complaint(
      id: uuid.v4(),
      complaint: getCommplaint,
      complaintTitle: getComplaintTitle,
      time: _time,
      name: gerName,
      roomNo: gerRoomNo,
      status: 0,
      studentUid: gerStudentUid,
      image: imageUrl != null
          ? imageUrl!
          : '', // Pass image URL to Complaint constructor
    );

// Save complaint to Firestore
    service.saveComplaint(newComplaint);
  }

  void deleteComplaint(complaintId) {
    service.removeComplaint(complaintId);
  }

  void changeStatus(status, compaintId) {
    service.changeComplaintStatus(status, compaintId);
  }
}
