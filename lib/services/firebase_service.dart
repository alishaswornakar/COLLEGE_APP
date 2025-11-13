import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  /// Add a single document to Firestore
  /// Example: Add a student record
  Future<String?> addStudent({
    required String name,
    required String email,
    required String department,
    required int semester,
  }) async {
    try {
      DocumentReference docRef = await _firebaseFirestore.collection('students').add({
        'name': name,
        'email': email,
        'department': department,
        'semester': semester,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Student added with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error adding student: $e');
      return null;
    }
  }

  /// Add a document with a custom ID
  Future<bool> addCourse({
    required String courseId,
    required String courseName,
    required String instructor,
    required int credits,
  }) async {
    try {
      await _firebaseFirestore.collection('courses').doc(courseId).set({
        'courseId': courseId,
        'courseName': courseName,
        'instructor': instructor,
        'credits': credits,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Course added: $courseId');
      return true;
    } catch (e) {
      print('Error adding course: $e');
      return false;
    }
  }

  /// Add a document with nested data (subcollection)
  Future<bool> addEnrollment({
    required String studentId,
    required String courseId,
    required String enrollmentDate,
    required double grade,
  }) async {
    try {
      await _firebaseFirestore
          .collection('students')
          .doc(studentId)
          .collection('enrollments')
          .add({
        'courseId': courseId,
        'enrollmentDate': enrollmentDate,
        'grade': grade,
        'status': 'active',
        'enrolledAt': FieldValue.serverTimestamp(),
      });
      print('Enrollment added for student: $studentId');
      return true;
    } catch (e) {
      print('Error adding enrollment: $e');
      return false;
    }
  }

  /// Batch write multiple documents at once
  Future<bool> addMultipleRecords(List<Map<String, dynamic>> records) async {
    try {
      WriteBatch batch = _firebaseFirestore.batch();
      
      for (var record in records) {
        DocumentReference ref = _firebaseFirestore.collection('records').doc();
        batch.set(ref, {
          ...record,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
      print('${records.length} records added successfully');
      return true;
    } catch (e) {
      print('Error adding multiple records: $e');
      return false;
    }
  }

  /// Get a single document
  Future<Map<String, dynamic>?> getStudent(String studentId) async {
    try {
      DocumentSnapshot doc =
          await _firebaseFirestore.collection('students').doc(studentId).get();
      
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting student: $e');
      return null;
    }
  }

  /// Get all documents from a collection
  Future<List<Map<String, dynamic>>> getAllStudents() async {
    try {
      QuerySnapshot querySnapshot =
          await _firebaseFirestore.collection('students').get();
      
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error getting students: $e');
      return [];
    }
  }

  /// Update a document
  Future<bool> updateStudent({
    required String studentId,
    required String name,
    required int semester,
  }) async {
    try {
      await _firebaseFirestore.collection('students').doc(studentId).update({
        'name': name,
        'semester': semester,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('Student updated: $studentId');
      return true;
    } catch (e) {
      print('Error updating student: $e');
      return false;
    }
  }

  /// Delete a document
  Future<bool> deleteStudent(String studentId) async {
    try {
      await _firebaseFirestore.collection('students').doc(studentId).delete();
      print('Student deleted: $studentId');
      return true;
    } catch (e) {
      print('Error deleting student: $e');
      return false;
    }
  }

  /// Stream real-time updates from a collection
  Stream<List<Map<String, dynamic>>> getStudentsStream() {
    return _firebaseFirestore
        .collection('students')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    });
  }

  /// Query documents with filtering
  Future<List<Map<String, dynamic>>> getStudentsByDepartment(
      String department) async {
    try {
      QuerySnapshot querySnapshot = await _firebaseFirestore
          .collection('students')
          .where('department', isEqualTo: department)
          .get();
      
      return querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      print('Error querying students by department: $e');
      return [];
    }
  }
}
