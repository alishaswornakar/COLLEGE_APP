import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _enrolledCourses = [];
  List<Map<String, dynamic>> _attendanceRecords = [];
  Map<String, dynamic>? _studentProfile;
  bool _isLoading = false;

  List<Map<String, dynamic>> get enrolledCourses => _enrolledCourses;
  List<Map<String, dynamic>> get attendanceRecords => _attendanceRecords;
  Map<String, dynamic>? get studentProfile => _studentProfile;
  bool get isLoading => _isLoading;

  Future<void> fetchStudentData(String uid) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Fetch student profile
      final profileDoc = await _firestore.collection('users').doc(uid).get();
      _studentProfile = profileDoc.data();

      // Fetch enrolled courses
      final coursesSnapshot = await _firestore
          .collection('enrollments')
          .where('studentId', isEqualTo: uid)
          .get();

      _enrolledCourses = coursesSnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();

      // Fetch attendance
      final attendanceSnapshot = await _firestore
          .collection('attendance')
          .where('studentId', isEqualTo: uid)
          .get();

      _attendanceRecords = attendanceSnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error fetching student data: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> enrollInCourse(String studentId, String courseId) async {
    try {
      await _firestore.collection('enrollments').add({
        'studentId': studentId,
        'courseId': courseId,
        'enrollmentDate': FieldValue.serverTimestamp(),
        'status': 'active',
      });

      await fetchStudentData(studentId);
      return true;
    } catch (e) {
      print('Error enrolling in course: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAvailableCourses() async {
    try {
      final snapshot = await _firestore.collection('courses').get();
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      print('Error fetching available courses: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getCourseDetails(String courseId) async {
    try {
      final doc = await _firestore.collection('courses').doc(courseId).get();
      return doc.data();
    } catch (e) {
      print('Error fetching course details: $e');
      return null;
    }
  }

  Stream<List<Map<String, dynamic>>> getAssignmentsStream(String courseId) {
    return _firestore
        .collection('assignments')
        .where('courseId', isEqualTo: courseId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                {'id': doc.id, ...doc.data()})
            .toList());
  }

  Future<bool> submitAssignment(
    String assignmentId,
    String studentId,
    String filePath,
  ) async {
    try {
      await _firestore
          .collection('assignments')
          .doc(assignmentId)
          .collection('submissions')
          .add({
        'studentId': studentId,
        'filePath': filePath,
        'submissionDate': FieldValue.serverTimestamp(),
        'status': 'submitted',
      });
      return true;
    } catch (e) {
      print('Error submitting assignment: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getGrades(String studentId) async {
    try {
      final doc = await _firestore.collection('grades').doc(studentId).get();
      return doc.data();
    } catch (e) {
      print('Error fetching grades: $e');
      return null;
    }
  }
}
