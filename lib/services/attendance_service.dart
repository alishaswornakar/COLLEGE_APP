import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> markAttendance(String courseId, String studentId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('attendance').add({
        'courseId': courseId,
        'studentId': studentId,
        ...data,
        'markedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error marking attendance: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAttendanceForCourse(String courseId) async {
    try {
      final snap = await _firestore.collection('attendance').where('courseId', isEqualTo: courseId).get();
      return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (e) {
      print('Error fetching attendance: $e');
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> attendanceStreamForStudent(String studentId) {
    return _firestore
        .collection('attendance')
        .where('studentId', isEqualTo: studentId)
        .orderBy('markedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }
}