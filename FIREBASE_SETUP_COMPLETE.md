# Firebase Authentication & Storage Integration Guide

## ✅ What's Been Connected

### 1. **Firebase Authentication (Real)**
- **AuthProvider** (`lib/providers/auth_provider.dart`):
  - ✅ Real Firebase Auth sign-up (creates user account)
  - ✅ Real Firebase Auth sign-in (validates credentials)
  - ✅ Real Firebase Auth sign-out
  - ✅ Auto-state listener (persists login session)
  - ✅ User role fetching (reads from Firestore `users` collection)
  - ✅ User data retrieval (fetches profile from Firestore)

- **SignUp Screen** (`lib/screens/auth/signup_screen.dart`):
  - Form to capture: Full Name, Email, Password, Roll Number, Department, Semester
  - Calls `AuthProvider.signUp()` → creates Firebase Auth user + Firestore profile

- **Login Screen** (`lib/screens/auth/login_screen.dart`):
  - Email + password fields
  - Calls `AuthProvider.signIn()` → validates with Firebase Auth

### 2. **Firebase Storage (Real)**
- **StorageService** (`lib/services/storage_service.dart`):
  - ✅ `uploadFile()` — upload to Firebase Storage, return download URL
  - ✅ `downloadFile()` — download files to local device
  - ✅ `deleteFile()` — delete files from storage
  - ✅ `getFileMetadata()` — fetch file size, updated time, etc.
  - ✅ `listFiles()` — list all files in a directory

- **Assignment Submission** (`lib/screens/assignments/submit_assignment.dart`):
  - Student selects image/file
  - Uploads to Firebase Storage under path: `assignments/{assignmentId}/{studentId}/{timestamp}_{filename}`
  - Records submission in Firestore with file URL and metadata

---

## 🚀 How to Use

### Firebase Project Setup (One-time)

1. **Create a Firebase Project**
   - Go to https://console.firebase.google.com
   - Click "Create Project" → name it "university_app"
   - Enable Email/Password authentication
   - Enable Cloud Firestore
   - Enable Cloud Storage

2. **Download Firebase Configuration Files**
   - Android: Download `google-services.json` and place it in `android/app/`
   - iOS: Download `GoogleService-Info.plist` and add to Xcode project
   - Already done if you used FlutterFire CLI

3. **Add Firebase Rules (Security)**

   **Firestore Rules** (allow authenticated users):
   ```firestore
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{uid} {
         allow read, write: if request.auth.uid == uid;
       }
       match /students/{document=**} {
         allow read: if request.auth != null;
         allow create, update: if request.auth.uid == resource.data.uid;
       }
       match /courses/{document=**} {
         allow read: if request.auth != null;
         allow write: if request.auth.token.role == 'admin';
       }
       match /assignments/{document=**} {
         allow read, create: if request.auth != null;
         allow update: if request.auth.token.role == 'admin';
       }
     }
   }
   ```

   **Storage Rules** (allow authenticated users to upload):
   ```firebase
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /{allPaths=**} {
         allow read: if request.auth != null;
         allow write: if request.auth != null;
       }
     }
   }
   ```

---

## 📝 Usage Examples

### Sign Up a New User
```dart
final authProvider = context.read<AuthProvider>();

final success = await authProvider.signUp(
  email: 'student@example.com',
  password: 'SecurePass123',
  fullName: 'Jane Smith',
  rollNumber: 'CS2024001',
  department: 'Computer Science',
  semester: '3',
);

if (success) {
  // User account created in Firebase Auth
  // User profile saved in Firestore users collection
  // AppWidget automatically navigates to StudentDashboard
}
```

### Sign In
```dart
final authProvider = context.read<AuthProvider>();

final success = await authProvider.signIn(
  email: 'student@example.com',
  password: 'SecurePass123',
);

if (success) {
  // User logged in
  // authProvider.user contains current User object
  // authProvider.userRole contains 'student' or 'admin'
}
```

### Upload Assignment File
```dart
import 'package:image_picker/image_picker.dart';
import 'services/storage_service.dart';

final picker = ImagePicker();
final file = await picker.pickImage(source: ImageSource.gallery);

if (file != null) {
  final storage = StorageService();
  final downloadUrl = await storage.uploadFile(
    File(file.path),
    'assignments/assignment_123/student_456/file.jpg',
  );
  
  if (downloadUrl != null) {
    print('File URL: $downloadUrl');
    // Save downloadUrl to Firestore assignment submission
  }
}
```

### Download File
```dart
final storage = StorageService();
final file = await storage.downloadFile(
  'assignments/assignment_123/student_456/file.jpg',
  '/data/user/0/com.example.university_app/cache/file.jpg',
);
```

### Delete File
```dart
final storage = StorageService();
final success = await storage.deleteFile(
  'assignments/assignment_123/student_456/file.jpg',
);
```

### List Files in Directory
```dart
final storage = StorageService();
final files = await storage.listFiles('assignments/assignment_123/');
// Returns list of file paths in that directory
```

---

## 🔧 Current Integration Status

| Feature | Status | Location |
|---------|--------|----------|
| Email/Password Auth | ✅ Connected | `lib/providers/auth_provider.dart` |
| User Profile Storage | ✅ Connected | Firestore `users` collection |
| Session Persistence | ✅ Connected | `AuthProvider._initializeAuth()` |
| File Upload | ✅ Connected | `lib/services/storage_service.dart` |
| File Download | ✅ Connected | `StorageService.downloadFile()` |
| File Delete | ✅ Connected | `StorageService.deleteFile()` |
| Assignment Submission | ✅ Connected | `lib/screens/assignments/submit_assignment.dart` |

---

## 🛡️ Security Tips

1. **Never hardcode credentials** — Firebase handles auth securely
2. **Use Firestore Security Rules** — restrict access at database level
3. **Use Firebase Storage Rules** — allow only authenticated users to upload
4. **Validate input** — check email format, password strength on client
5. **Handle errors gracefully** — show user-friendly messages

---

## 📊 Data Structure

### Firestore Collections

**users**
```json
{
  "uid": "firebase_uid_123",
  "email": "student@example.com",
  "fullName": "Jane Smith",
  "rollNumber": "CS2024001",
  "department": "Computer Science",
  "semester": "3",
  "role": "student",
  "createdAt": "2024-11-13T10:30:00Z"
}
```

**assignments** (submission)
```json
{
  "assignmentId": "assign_001",
  "studentId": "firebase_uid_123",
  "fileUrl": "https://firebasestorage.googleapis.com/...",
  "fileName": "solution.pdf",
  "submittedAt": "2024-11-13T15:45:00Z"
}
```

### Firebase Storage Paths
```
assignments/
  ├── assign_001/
  │   ├── student_123/
  │   │   └── 1731496800000_solution.pdf
  │   └── student_456/
  │       └── 1731496900000_answer.pdf
  └── assign_002/
      └── student_123/
          └── 1731497000000_submission.jpg
```

---

## 🐛 Troubleshooting

### "User not authenticated"
- Check if Firebase Auth is initialized
- Verify user is signed in: `authProvider.user != null`
- Check Firestore/Storage security rules

### "File upload fails"
- Ensure device has internet connection
- Check Storage bucket exists in Firebase Console
- Verify file path is valid (no special characters)
- Check Storage security rules allow write access

### "User not logged in on app restart"
- Firebase Auth persists sessions automatically
- `AuthProvider._initializeAuth()` listens for auth changes
- If issue persists, clear app cache and re-login

---

## 📚 Next Steps

1. **Test Authentication**:
   - Run `flutter run` on device
   - Go to Sign Up → create account
   - Verify user created in Firebase Console > Authentication
   - Verify user profile in Firebase Console > Firestore > `users` collection

2. **Test File Upload**:
   - Login → navigate to Assignments
   - Submit an assignment with an image
   - Verify file in Firebase Console > Storage

3. **Deploy Security Rules**:
   - Apply the provided Firestore and Storage rules in Firebase Console
   - Test that unauthorized users cannot access data

---

## 📖 Firebase References

- [Firebase Authentication Guide](https://firebase.flutter.dev/docs/auth/overview)
- [Firebase Storage Guide](https://firebase.flutter.dev/docs/storage/overview)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/start)
- [Firebase Console](https://console.firebase.google.com)

---

**Firebase is now live! 🔥 Your app is ready for real authentication and file storage.**
