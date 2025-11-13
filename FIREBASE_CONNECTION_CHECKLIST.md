# Firebase Connection Checklist

## ✅ What's Already Done

- [x] **AuthProvider** wired to Firebase Auth
  - Real sign-up/sign-in/sign-out
  - Auto session persistence
  - User role fetching from Firestore

- [x] **StorageService** wired to Firebase Storage
  - File upload, download, delete, metadata, list

- [x] **Assignment Submission** wired to Firebase Storage
  - File upload on submission
  - Metadata saved to Firestore

- [x] **Error handling** added to auth screens
  - Better UX feedback on login/signup failures

---

## 🔧 Required Setup (Do This Once)

### 1. Create Firebase Project
```bash
# If you haven't already, create a Firebase project at:
https://console.firebase.google.com
```

### 2. Download Config Files

**For Android:**
- Go to Firebase Console → Project Settings → Download `google-services.json`
- Place in: `android/app/google-services.json`

**For iOS:**
- Download `GoogleService-Info.plist`
- Add to Xcode project (Runner → Build Phases)

### 3. Enable Services in Firebase Console

- [ ] Authentication → Email/Password (enable)
- [ ] Firestore Database (create in test mode for now)
- [ ] Cloud Storage (create bucket)

### 4. Set Security Rules (Important!)

Copy-paste to **Firestore Rules** tab:
```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;
    }
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

Copy-paste to **Storage Rules** tab:
```firebase
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## 🧪 Test the Integration

### Step 1: Run the App
```bash
cd C:\Users\alisha swornakar\Desktop\smartprep\university\university_app
flutter pub get
flutter run
```

### Step 2: Sign Up
- Tap "Sign Up"
- Fill form: name, email, password, roll number, department
- Tap "Create account"
- ✅ Should succeed and show student dashboard

### Step 3: Verify in Firebase Console
- Go to Firebase Console
- Firestore → `users` collection
- Should see your account document with all fields

### Step 4: Test Login
- Logout (Settings screen)
- Login with your credentials
- ✅ Should restore session and show dashboard

### Step 5: Test File Upload
- Go to Assignments
- Select an assignment
- Tap "Submit Assignment"
- Pick an image
- Tap "Submit"
- ✅ File should upload to Firebase Storage

### Step 6: Verify Upload
- Firebase Console → Storage
- Browse `assignments/` folder
- Should see your uploaded file

---

## 🚨 Common Issues & Fixes

| Issue | Solution |
|-------|----------|
| "Google services JSON missing" | Download `google-services.json` and place in `android/app/` |
| "Firestore/Storage not found" | Enable Firestore and Storage in Firebase Console |
| "Permission denied" | Check Firestore/Storage security rules are set |
| "Sign up fails silently" | Check Firebase Auth has Email/Password enabled |
| "File upload fails" | Ensure storage bucket created and rules allow write |

---

## 📱 Next: Test on Device

After setup, run on a real device or emulator:

```bash
flutter run -v
```

Monitor logs for Firebase initialization messages.

---

## 🎯 What You Can Do Now

1. **Register new users** → stored in Firebase Auth + Firestore
2. **Login with credentials** → persists session
3. **Upload assignment files** → stored in Firebase Storage
4. **Download files** → retrieve from Storage
5. **Manage user profiles** → read/write to Firestore

---

## 📞 Support

Check logs for errors:
```bash
flutter logs
```

Read detailed guides:
- [Firebase Flutter Setup](https://firebase.flutter.dev/)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Storage Documentation](https://firebase.google.com/docs/storage)

---

**You're all set! Firebase Auth & Storage are connected. 🔥**
