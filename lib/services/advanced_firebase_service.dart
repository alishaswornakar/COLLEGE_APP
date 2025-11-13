import 'package:cloud_firestore/cloud_firestore.dart';

// ============================================================================
// ADVANCED FIREBASE FIRESTORE EXAMPLES
// ============================================================================

/// Advanced service with more complex operations
class AdvancedFirebaseService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  // ========== COMPLEX QUERIES ==========

  /// Query with multiple conditions
  Future<List<Map<String, dynamic>>> getAdvancedStudents({
    required String department,
    required int minSemester,
    int? maxSemester,
  }) async {
    try {
      Query query = _firebaseFirestore
          .collection('students')
          .where('department', isEqualTo: department)
          .where('semester', isGreaterThanOrEqualTo: minSemester);

      if (maxSemester != null) {
        query = query.where('semester', isLessThanOrEqualTo: maxSemester);
      }

      QuerySnapshot snapshot = await query.get();
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print('Error in advanced query: $e');
      return [];
    }
  }

  /// Query with ordering and pagination
  Future<List<Map<String, dynamic>>> getStudentsPaginated({
    required int pageSize,
    DocumentSnapshot? startAfter,
    bool ascending = true,
  }) async {
    try {
      Query query = _firebaseFirestore
          .collection('students')
          .orderBy('name', descending: !ascending)
          .limit(pageSize);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      QuerySnapshot snapshot = await query.get();
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print('Error in paginated query: $e');
      return [];
    }
  }

  /// Full-text search (case-insensitive contains)
  Future<List<Map<String, dynamic>>> searchStudents(String query) async {
    try {
      String searchLower = query.toLowerCase();
      
      QuerySnapshot snapshot = 
          await _firebaseFirestore.collection('students').get();
      
      final filtered = snapshot.docs.where((doc) {
        final name = (doc['name'] as String).toLowerCase();
        final email = (doc['email'] as String).toLowerCase();
        return name.contains(searchLower) || email.contains(searchLower);
      }).toList();

      return filtered
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print('Error searching students: $e');
      return [];
    }
  }

  /// Query with array contains
  Future<List<Map<String, dynamic>>> getStudentsWithSkill(
      String skill) async {
    try {
      QuerySnapshot snapshot = await _firebaseFirestore
          .collection('students')
          .where('skills', arrayContains: skill)
          .get();

      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print('Error querying students with skill: $e');
      return [];
    }
  }

  // ========== TRANSACTIONS ==========

  /// Transfer enrollment between students (atomic operation)
  Future<bool> transferEnrollment({
    required String fromStudentId,
    required String toStudentId,
    required String enrollmentId,
  }) async {
    try {
      await _firebaseFirestore.runTransaction((transaction) async {
        final fromStudentRef =
            _firebaseFirestore.collection('students').doc(fromStudentId);
        final toStudentRef =
            _firebaseFirestore.collection('students').doc(toStudentId);

        final fromEnrollmentRef =
            fromStudentRef.collection('enrollments').doc(enrollmentId);
        final enrollmentDoc = await transaction.get(fromEnrollmentRef);

        if (enrollmentDoc.exists) {
          // Delete from source
          transaction.delete(fromEnrollmentRef);

          // Add to destination
          transaction.set(
            toStudentRef.collection('enrollments').doc(enrollmentId),
            enrollmentDoc.data(),
          );
        }
      });

      print('Enrollment transferred successfully');
      return true;
    } catch (e) {
      print('Error transferring enrollment: $e');
      return false;
    }
  }

  /// Atomic grade update with GPA recalculation
  Future<bool> updateGradeAndGPA({
    required String studentId,
    required String enrollmentId,
    required double newGrade,
  }) async {
    try {
      await _firebaseFirestore.runTransaction((transaction) async {
        final studentRef = _firebaseFirestore.collection('students').doc(studentId);
        final enrollmentRef =
            studentRef.collection('enrollments').doc(enrollmentId);

        // Get current enrollment
        final enrollmentDoc = await transaction.get(enrollmentRef);
        if (!enrollmentDoc.exists) throw Exception('Enrollment not found');

        // Update enrollment grade
        transaction.update(enrollmentRef, {'grade': newGrade});

        // Recalculate GPA
        final allEnrollments =
            await studentRef.collection('enrollments').get();
        
        double totalGPA = 0;
        for (var doc in allEnrollments.docs) {
          totalGPA += (doc['grade'] as num).toDouble();
        }
        double avgGPA = totalGPA / allEnrollments.docs.length;

        // Update student GPA
        transaction.update(studentRef, {'gpa': avgGPA});
      });

      print('Grade and GPA updated successfully');
      return true;
    } catch (e) {
      print('Error updating grade and GPA: $e');
      return false;
    }
  }

  // ========== BATCH OPERATIONS ==========

  /// Bulk update multiple students
  Future<bool> bulkUpdateSemester(
      List<String> studentIds, int newSemester) async {
    try {
      WriteBatch batch = _firebaseFirestore.batch();

      for (String studentId in studentIds) {
        final studentRef =
            _firebaseFirestore.collection('students').doc(studentId);
        batch.update(studentRef, {
          'semester': newSemester,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      print('${studentIds.length} students updated');
      return true;
    } catch (e) {
      print('Error in bulk update: $e');
      return false;
    }
  }

  /// Bulk delete documents
  Future<bool> bulkDeleteStudents(List<String> studentIds) async {
    try {
      WriteBatch batch = _firebaseFirestore.batch();

      for (String studentId in studentIds) {
        final studentRef =
            _firebaseFirestore.collection('students').doc(studentId);
        batch.delete(studentRef);
      }

      await batch.commit();
      print('${studentIds.length} students deleted');
      return true;
    } catch (e) {
      print('Error in bulk delete: $e');
      return false;
    }
  }

  // ========== AGGREGATIONS ==========

  /// Count documents in collection
  Future<int> countStudents() async {
    try {
      AggregateQuerySnapshot snapshot =
          await _firebaseFirestore.collection('students').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error counting students: $e');
      return 0;
    }
  }

  /// Count with filter
  Future<int> countStudentsByDepartment(String department) async {
    try {
      AggregateQuerySnapshot snapshot = await _firebaseFirestore
          .collection('students')
          .where('department', isEqualTo: department)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error counting students by department: $e');
      return 0;
    }
  }

  /// Sum aggregation - Total credits for a student
  Future<int> getTotalCredits(String studentId) async {
    try {
      final enrollments =
          await _firebaseFirestore
              .collection('students')
              .doc(studentId)
              .collection('enrollments')
              .get();

      int totalCredits = 0;
      for (var doc in enrollments.docs) {
        // Assuming each enrollment has an associated course with credits
        // This is a simplified example
        totalCredits++;
      }

      return totalCredits;
    } catch (e) {
      print('Error getting total credits: $e');
      return 0;
    }
  }

  // ========== REAL-TIME LISTENERS WITH FILTERING ==========

  /// Stream with filter - Listen to specific department students
  Stream<List<Map<String, dynamic>>> getStudentsByDepartmentStream(
      String department) {
    return _firebaseFirestore
        .collection('students')
        .where('department', isEqualTo: department)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                {'id': doc.id, ...doc.data()})
            .toList());
  }

  /// Stream with multiple filters
  Stream<List<Map<String, dynamic>>> getFilteredStudentsStream({
    required String department,
    required int minSemester,
  }) {
    return _firebaseFirestore
        .collection('students')
        .where('department', isEqualTo: department)
        .where('semester', isGreaterThanOrEqualTo: minSemester)
        .orderBy('semester')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                {'id': doc.id, ...doc.data()})
            .toList());
  }

  /// Stream with real-time error handling
  Stream<List<Map<String, dynamic>>> getStudentsStreamWithErrorHandling() {
    return _firebaseFirestore
        .collection('students')
        .snapshots()
        .handleError((error) {
          print('Stream error: $error');
          return <QuerySnapshot>[];
        })
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                {'id': doc.id, ...doc.data()})
            .toList());
  }

  // ========== BACKUP & EXPORT ==========

  /// Export all data from a collection
  Future<List<Map<String, dynamic>>> exportCollection(
      String collectionName) async {
    try {
      QuerySnapshot snapshot =
          await _firebaseFirestore.collection(collectionName).get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      print('Error exporting collection: $e');
      return [];
    }
  }

  /// Export nested subcollections
  Future<Map<String, dynamic>> exportStudentWithEnrollments(
      String studentId) async {
    try {
      final studentDoc =
          await _firebaseFirestore.collection('students').doc(studentId).get();

      if (!studentDoc.exists) return {};

      final enrollments =
          await studentDoc.reference.collection('enrollments').get();

      return {
        'id': studentDoc.id,
        ...studentDoc.data() as Map<String, dynamic>,
        'enrollments': enrollments.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList(),
      };
    } catch (e) {
      print('Error exporting student: $e');
      return {};
    }
  }

  // ========== FIELD UPDATE OPERATIONS ==========

  /// Increment a numeric field
  Future<bool> incrementStudentCompletedCourses(String studentId) async {
    try {
      await _firebaseFirestore
          .collection('students')
          .doc(studentId)
          .update({
        'completedCourses': FieldValue.increment(1),
      });
      return true;
    } catch (e) {
      print('Error incrementing courses: $e');
      return false;
    }
  }

  /// Add items to array field
  Future<bool> addSkillToStudent(String studentId, String skill) async {
    try {
      await _firebaseFirestore
          .collection('students')
          .doc(studentId)
          .update({
        'skills': FieldValue.arrayUnion([skill]),
      });
      return true;
    } catch (e) {
      print('Error adding skill: $e');
      return false;
    }
  }

  /// Remove items from array field
  Future<bool> removeSkillFromStudent(String studentId, String skill) async {
    try {
      await _firebaseFirestore
          .collection('students')
          .doc(studentId)
          .update({
        'skills': FieldValue.arrayRemove([skill]),
      });
      return true;
    } catch (e) {
      print('Error removing skill: $e');
      return false;
    }
  }

  /// Delete specific field from document
  Future<bool> deleteFieldFromStudent(
      String studentId, String fieldName) async {
    try {
      await _firebaseFirestore.collection('students').doc(studentId).update({
        fieldName: FieldValue.delete(),
      });
      return true;
    } catch (e) {
      print('Error deleting field: $e');
      return false;
    }
  }

  // ========== CONDITIONAL OPERATIONS ==========

  /// Set document only if it doesn't exist
  Future<bool> createStudentIfNotExists({
    required String studentId,
    required String name,
    required String email,
  }) async {
    try {
      final docRef = _firebaseFirestore.collection('students').doc(studentId);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        await docRef.set({
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('Student created: $studentId');
        return true;
      } else {
        print('Student already exists: $studentId');
        return false;
      }
    } catch (e) {
      print('Error creating student: $e');
      return false;
    }
  }

  /// Update document only if it exists
  Future<bool> updateStudentIfExists(
      String studentId, Map<String, dynamic> updates) async {
    try {
      final docRef = _firebaseFirestore.collection('students').doc(studentId);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        await docRef.update({
          ...updates,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('Student updated: $studentId');
        return true;
      } else {
        print('Student does not exist: $studentId');
        return false;
      }
    } catch (e) {
      print('Error updating student: $e');
      return false;
    }
  }
}
