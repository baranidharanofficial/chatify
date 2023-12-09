import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String senderId;
  String senderEmail;
  String receiverId;
  String message;
  Timestamp timeStamp;

  Message({
    required this.senderId,
    required this.senderEmail,
    required this.receiverId,
    required this.message,
    required this.timeStamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'message': message,
      'timeStamp': timeStamp,
    };
  }
}
