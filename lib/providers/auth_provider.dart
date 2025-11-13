import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  String? _userRole; // 'student' or 'admin'
  bool _isLoading = false;

  User? get user => _user;
  String? get userRole => _userRole;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _firebaseAuth.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        await _fetchUserRole(user.uid);
      } else {
        _userRole = null;
      }
      notifyListeners();
    });
  }

  Future<void> _fetchUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _userRole = doc.data()?['role'] ?? 'student';
      }
    } catch (e) {
      print('Error fetching user role: $e');
    }
  }

  Future<bool> signUp(String email, String password, String fullName,
      String rollNumber, String department, String semester) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'fullName': fullName,
        'rollNumber': rollNumber,
        'department': department,
        'semester': semester,
        'role': 'student',
        'createdAt': FieldValue.serverTimestamp(),
      });

      _user = userCredential.user;
      _userRole = 'student';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error signing up: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = userCredential.user;
      await _fetchUserRole(userCredential.user!.uid);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error signing in: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firebaseAuth.signOut();
      _user = null;
      _userRole = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error signing out: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      if (_user == null) return null;
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      return doc.data();
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }
}
