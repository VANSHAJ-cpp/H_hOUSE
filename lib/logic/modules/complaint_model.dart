class Complaint {
  String id;
  String complaint;
  String complaintTitle;
  DateTime time;
  String studentUid;
  String name;
  String roomNo;
  int status;
  String? imageUrl; // Add imageUrl field to store image URL

  Complaint({
    required this.id,
    required this.complaint,
    required this.complaintTitle,
    required this.time,
    required this.studentUid,
    required this.name,
    required this.roomNo,
    required this.status,
    this.imageUrl,
    required String image, // Initialize imageUrl field in constructor
  });

  Map<String, dynamic> createMap() {
    return {
      'id': id,
      'Complaint': complaint,
      'Time': time,
      'StudentUid': studentUid,
      'ComplaintTitle': complaintTitle,
      'Name': name,
      'RoomNo': roomNo,
      'Status': status,
      'ImageUrl': imageUrl, // Include imageUrl in the map
    };
  }

  Complaint.fromFirestore(Map<String, dynamic> firestoreMap)
      : id = firestoreMap['id'],
        complaintTitle = firestoreMap['ComplaintTitle'],
        complaint = firestoreMap['Complaint'],
        time = firestoreMap['Time'].toDate(),
        studentUid = firestoreMap['StudentUid'],
        roomNo = firestoreMap['RoomNo'],
        status = firestoreMap['Status'],
        name = firestoreMap['Name'],
        imageUrl =
            firestoreMap['ImageUrl']; // Initialize imageUrl from Firestore
}
