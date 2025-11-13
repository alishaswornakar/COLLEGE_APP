// FIREBASE FIRESTORE - COMPLETE CODE EXAMPLES
// This file demonstrates various ways to add and manage data in Firebase Firestore

// ============================================================================
// 1. SETUP - Initialize Firebase in main.dart
// ============================================================================

/*
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
*/

// ============================================================================
// 2. ADD A SIMPLE DOCUMENT (Auto-generated ID)
// ============================================================================

/*
final FirebaseFirestore firestore = FirebaseFirestore.instance;

// Add a student with auto-generated document ID
await firestore.collection('students').add({
  'name': 'John Doe',
  'email': 'john@example.com',
  'department': 'Computer Science',
  'semester': 3,
  'createdAt': FieldValue.serverTimestamp(),
});
*/

// ============================================================================
// 3. ADD A DOCUMENT WITH CUSTOM ID
// ============================================================================

/*
// Add a course with custom document ID
await firestore.collection('courses').doc('CS101').set({
  'courseId': 'CS101',
  'courseName': 'Introduction to Computer Science',
  'instructor': 'Dr. Smith',
  'credits': 3,
  'createdAt': FieldValue.serverTimestamp(),
});
*/

// ============================================================================
// 4. ADD NESTED DATA (Subcollections)
// ============================================================================

/*
// Add enrollment data as a subcollection under a student
await firestore
    .collection('students')
    .doc('student_123')
    .collection('enrollments')
    .add({
  'courseId': 'CS101',
  'enrollmentDate': '2024-01-15',
  'grade': 3.8,
  'status': 'active',
  'enrolledAt': FieldValue.serverTimestamp(),
});
*/

// ============================================================================
// 5. BATCH WRITE - ADD MULTIPLE DOCUMENTS AT ONCE
// ============================================================================

/*
WriteBatch batch = firestore.batch();

// Add multiple students at once
final students = [
  {'name': 'Alice', 'email': 'alice@example.com'},
  {'name': 'Bob', 'email': 'bob@example.com'},
  {'name': 'Charlie', 'email': 'charlie@example.com'},
];

for (var student in students) {
  DocumentReference ref = firestore.collection('students').doc();
  batch.set(ref, {
    ...student,
    'createdAt': FieldValue.serverTimestamp(),
  });
}

await batch.commit();
*/

// ============================================================================
// 6. UPDATE A DOCUMENT
// ============================================================================

/*
await firestore.collection('students').doc('student_123').update({
  'semester': 4,
  'updatedAt': FieldValue.serverTimestamp(),
});

// Update only specific fields without overwriting the entire document
await firestore.collection('students').doc('student_123').update({
  'gpa': 3.9,
});
*/

// ============================================================================
// 7. DELETE A DOCUMENT
// ============================================================================

/*
await firestore.collection('students').doc('student_123').delete();

// Delete a field from a document
await firestore.collection('students').doc('student_123').update({
  'middleName': FieldValue.delete(),
});
*/

// ============================================================================
// 8. QUERY DATA
// ============================================================================

/*
// Get all documents from a collection
QuerySnapshot snapshot = await firestore.collection('students').get();
for (var doc in snapshot.docs) {
  print(doc.data());
}

// Query with WHERE condition
QuerySnapshot snapshot = await firestore
    .collection('students')
    .where('department', isEqualTo: 'Computer Science')
    .get();

// Query with multiple conditions
QuerySnapshot snapshot = await firestore
    .collection('students')
    .where('department', isEqualTo: 'Computer Science')
    .where('semester', isGreaterThanOrEqualTo: 3)
    .get();

// Query with ordering
QuerySnapshot snapshot = await firestore
    .collection('students')
    .orderBy('name')
    .limit(10)
    .get();

// Query with pagination
QuerySnapshot firstBatch = await firestore
    .collection('students')
    .orderBy('name')
    .limit(10)
    .get();

if (firstBatch.docs.isNotEmpty) {
  QuerySnapshot nextBatch = await firestore
      .collection('students')
      .orderBy('name')
      .startAfterDocument(firstBatch.docs.last)
      .limit(10)
      .get();
}
*/

// ============================================================================
// 9. REAL-TIME UPDATES (Listeners/Streams)
// ============================================================================

/*
// Listen to a single document
firestore.collection('students').doc('student_123').snapshots().listen((doc) {
  print('Student updated: ${doc.data()}');
});

// Listen to a collection
firestore.collection('students').snapshots().listen((snapshot) {
  for (var doc in snapshot.docs) {
    print('Student: ${doc.data()}');
  }
});

// Listen with filters
firestore
    .collection('students')
    .where('department', isEqualTo: 'Computer Science')
    .snapshots()
    .listen((snapshot) {
  print('CS Students count: ${snapshot.docs.length}');
});

// Use as a Stream in Flutter UI
Stream<List<Student>> getStudentsStream() {
  return firestore
      .collection('students')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Student.fromFirestore(doc))
          .toList());
}

// Use in StreamBuilder
StreamBuilder<List<Student>>(
  stream: getStudentsStream(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }
    final students = snapshot.data ?? [];
    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(students[index].name),
          subtitle: Text(students[index].email),
        );
      },
    );
  },
)
*/

// ============================================================================
// 10. TRANSACTION - ATOMIC OPERATIONS
// ============================================================================

/*
// Transfer credits between accounts atomically
await firestore.runTransaction((transaction) async {
  final studentRef = firestore.collection('students').doc('student_123');
  final accountRef = firestore.collection('accounts').doc('account_456');
  
  final studentDoc = await transaction.get(studentRef);
  final accountDoc = await transaction.get(accountRef);
  
  final studentCredits = studentDoc['credits'] as int;
  final accountBalance = accountDoc['balance'] as double;
  
  transaction.update(studentRef, {'credits': studentCredits - 10});
  transaction.update(accountRef, {'balance': accountBalance + 100});
});
*/

// ============================================================================
// 11. FIELD VALUE OPERATIONS
// ============================================================================

/*
// Increment a field
await firestore.collection('students').doc('student_123').update({
  'completedCourses': FieldValue.increment(1),
  'gpa': FieldValue.increment(0.1),
});

// Add elements to an array
await firestore.collection('students').doc('student_123').update({
  'skills': FieldValue.arrayUnion(['Flutter', 'Dart']),
});

// Remove elements from an array
await firestore.collection('students').doc('student_123').update({
  'skills': FieldValue.arrayRemove(['Python']),
});

// Delete a field
await firestore.collection('students').doc('student_123').update({
  'tempNotes': FieldValue.delete(),
});
*/

// ============================================================================
// 12. ERROR HANDLING
// ============================================================================

/*
try {
  await firestore.collection('students').add({
    'name': 'John',
    'email': 'john@example.com',
  });
} on FirebaseException catch (e) {
  print('Firebase error: ${e.code} - ${e.message}');
} catch (e) {
  print('Error: $e');
}
*/

// ============================================================================
// 13. COMPLETE SERVICE CLASS EXAMPLE
// ============================================================================

/*
class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add student
  Future<String> addStudent(String name, String email) async {
    try {
      final docRef = await _db.collection('students').add({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // Get student
  Future<Map<String, dynamic>?> getStudent(String id) async {
    try {
      final doc = await _db.collection('students').doc(id).get();
      return doc.data();
    } catch (e) {
      rethrow;
    }
  }

  // Get all students
  Stream<List<Map<String, dynamic>>> getAllStudents() {
    return _db.collection('students').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  // Update student
  Future<void> updateStudent(String id, Map<String, dynamic> data) async {
    try {
      await _db.collection('students').doc(id).update(data);
    } catch (e) {
      rethrow;
    }
  }

  // Delete student
  Future<void> deleteStudent(String id) async {
    try {
      await _db.collection('students').doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }
}
*/

// ============================================================================
// 14. PUBSPEC.yaml DEPENDENCIES
// ============================================================================

/*
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^4.2.1
  cloud_firestore: ^5.5.1
*/
