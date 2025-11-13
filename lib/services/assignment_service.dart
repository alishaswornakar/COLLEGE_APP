import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> createAssignment(Map<String, dynamic> data) async {
    try {
      await _firestore.collection('assignments').add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error creating assignment: $e');
      return false;
    }
  }

  Stream<List<Map<String, dynamic>>> assignmentsStream(String courseId) {
    return _firestore
        .collection('assignments')
        .where('courseId', isEqualTo: courseId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => {'id': d.id, ...d.data()})
            .toList());
  }

  Future<bool> submitAssignment(String assignmentId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('assignments')
          .doc(assignmentId)
          .collection('submissions')
          .add({
        ...data,
        'submittedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error submitting assignment: $e');
      return false;
    }
  }
}