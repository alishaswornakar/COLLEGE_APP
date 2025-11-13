import 'package:cloud_firestore/cloud_firestore.dart';

/// Student Model
class Student {
  final String? id;
  final String name;
  final String email;
  final String department;
  final int semester;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Student({
    this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.semester,
    this.createdAt,
    this.updatedAt,
  });

  /// Convert Student to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'department': department,
      'semester': semester,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
    };
  }

  /// Create Student from Firestore document
  factory Student.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Student(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      department: data['department'] ?? '',
      semester: data['semester'] ?? 0,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Create Student from Map
  factory Student.fromMap(Map<String, dynamic> map, {String? id}) {
    return Student(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      department: map['department'] ?? '',
      semester: map['semester'] ?? 0,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  @override
  String toString() =>
      'Student(id: $id, name: $name, email: $email, department: $department, semester: $semester)';
}

/// Course Model
class Course {
  final String courseId;
  final String courseName;
  final String instructor;
  final int credits;
  final DateTime? createdAt;

  Course({
    required this.courseId,
    required this.courseName,
    required this.instructor,
    required this.credits,
    this.createdAt,
  });

  /// Convert Course to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'courseName': courseName,
      'instructor': instructor,
      'credits': credits,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  /// Create Course from Firestore document
  factory Course.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Course(
      courseId: doc.id,
      courseName: data['courseName'] ?? '',
      instructor: data['instructor'] ?? '',
      credits: data['credits'] ?? 0,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Create Course from Map
  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      courseId: map['courseId'] ?? '',
      courseName: map['courseName'] ?? '',
      instructor: map['instructor'] ?? '',
      credits: map['credits'] ?? 0,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  @override
  String toString() =>
      'Course(courseId: $courseId, courseName: $courseName, instructor: $instructor, credits: $credits)';
}

/// Enrollment Model
class Enrollment {
  final String? id;
  final String courseId;
  final String enrollmentDate;
  final double grade;
  final String status;
  final DateTime? enrolledAt;

  Enrollment({
    this.id,
    required this.courseId,
    required this.enrollmentDate,
    required this.grade,
    this.status = 'active',
    this.enrolledAt,
  });

  /// Convert Enrollment to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'enrollmentDate': enrollmentDate,
      'grade': grade,
      'status': status,
      'enrolledAt': enrolledAt ?? FieldValue.serverTimestamp(),
    };
  }

  /// Create Enrollment from Firestore document
  factory Enrollment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Enrollment(
      id: doc.id,
      courseId: data['courseId'] ?? '',
      enrollmentDate: data['enrollmentDate'] ?? '',
      grade: (data['grade'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'active',
      enrolledAt: data['enrolledAt'] != null
          ? (data['enrolledAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Create Enrollment from Map
  factory Enrollment.fromMap(Map<String, dynamic> map, {String? id}) {
    return Enrollment(
      id: id,
      courseId: map['courseId'] ?? '',
      enrollmentDate: map['enrollmentDate'] ?? '',
      grade: (map['grade'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'active',
      enrolledAt: map['enrolledAt'] != null
          ? (map['enrolledAt'] as Timestamp).toDate()
          : null,
    );
  }

  @override
  String toString() =>
      'Enrollment(id: $id, courseId: $courseId, grade: $grade, status: $status)';
}
