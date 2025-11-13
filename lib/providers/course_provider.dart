import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _courses = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get courses => _courses;
  bool get isLoading => _isLoading;

  Future<void> fetchAllCourses() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore.collection('courses').get();
      _courses = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error fetching courses: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCourse(
    String courseCode,
    String courseName,
    String instructor,
    int credits,
    String department,
    int semester,
    String description,
  ) async {
    try {
      await _firestore.collection('courses').add({
        'courseCode': courseCode,
        'courseName': courseName,
        'instructor': instructor,
        'credits': credits,
        'department': department,
        'semester': semester,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await fetchAllCourses();
      return true;
    } catch (e) {
      print('Error adding course: $e');
      return false;
    }
  }

  Future<bool> updateCourse(String courseId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('courses').doc(courseId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await fetchAllCourses();
      return true;
    } catch (e) {
      print('Error updating course: $e');
      return false;
    }
  }

  Future<bool> deleteCourse(String courseId) async {
    try {
      await _firestore.collection('courses').doc(courseId).delete();
      await fetchAllCourses();
      return true;
    } catch (e) {
      print('Error deleting course: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getCoursesByDepartment(
      String department) async {
    try {
      final snapshot = await _firestore
          .collection('courses')
          .where('department', isEqualTo: department)
          .get();

      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      print('Error fetching courses by department: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCoursesBySemester(int semester) async {
    try {
      final snapshot = await _firestore
          .collection('courses')
          .where('semester', isEqualTo: semester)
          .get();

      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      print('Error fetching courses by semester: $e');
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> watchCourses() {
    return _firestore.collection('courses').snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) =>
                {'id': doc.id, ...doc.data()})
            .toList());
  }
}
