import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> sendNotification(Map<String, dynamic> payload) async {
    try {
      await _firestore.collection('notifications').add({
        ...payload,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error sending notification: $e');
      return false;
    }
  }

  Stream<List<Map<String, dynamic>>> notificationsStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('targetUserId', whereIn: [null, userId])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }
}