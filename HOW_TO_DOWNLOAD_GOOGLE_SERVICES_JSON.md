# How to Download google-services.json from Firebase Console

## Step-by-Step Guide

### Step 1: Go to Firebase Console
- Open browser and go to: **https://console.firebase.google.com**
- Login with your Google account

### Step 2: Select Your Project
- Click on your project name (e.g., "university_app")
- If you haven't created a project yet, click **"Create a project"** first

### Step 3: Open Project Settings
- Look for the **⚙️ Settings icon** (gear icon) at the **top left**, next to "Project Overview"
- Click it → select **"Project Settings"**

![Project Settings Location](https://imgur.com/abc123.png)

### Step 4: Navigate to Android Settings
- In Project Settings, look for tabs at the top: **General | Users and permissions | Service accounts**
- Click on **"Your apps"** section (or scroll down)
- You should see a list of apps (Android, iOS, Web, etc.)

### Step 5: Download google-services.json
- Find the **Android app** in the list (it will show an Android icon 🤖)
- Click on the Android app or look for a **"Download google-services.json"** button
- A file named `google-services.json` will download to your computer

### Alternative Method (If Not Visible)

If you don't see the download button in Project Settings:

1. In Firebase Console, go to **Settings ⚙️ → Project Settings**
2. Scroll down to find **"Your apps"** section
3. Click the **Android icon** under your app name
4. Look for the button labeled **"Download google-services.json"**
5. Click it to download

---

## Where to Place the File

After downloading `google-services.json`:

1. Locate your Flutter project:
   ```
   C:\Users\alisha swornakar\Desktop\smartprep\university\university_app
   ```

2. Navigate to Android folder:
   ```
   C:\Users\alisha swornakar\Desktop\smartprep\university\university_app\android\app\
   ```

3. **Paste `google-services.json` here**
   - Full path should be:
   ```
   C:\Users\alisha swornakar\Desktop\smartprep\university\university_app\android\app\google-services.json
   ```

---

## Verify It's Correct

After placing the file:

1. Open file manager and navigate to `android/app/`
2. You should see:
   - `build.gradle.kts` ✓
   - `google-services.json` ✓ (your downloaded file)
   - `src/` folder ✓

---

## What If I Don't Have an Android App Registered?

If you don't see an Android app in Firebase Console:

1. In Firebase Console → **Project Settings**
2. Scroll to **"Your apps"** section
3. Click the **green "+" button** or **"Add app"**
4. Select **"Android"** icon
5. Fill in the form:
   - **Android package name**: `com.example.university_app`
   - **App nickname** (optional): `University App`
   - **SHA-1 certificate hash** (optional, skip for now)
6. Click **"Register app"**
7. Then download `google-services.json`

---

## Quick Visual Reference

```
Firebase Console
    ↓
Project Settings (⚙️)
    ↓
Your apps section
    ↓
Android app icon 🤖
    ↓
Download google-services.json button
    ↓
Save to: android/app/google-services.json
```

---

## Next Steps After Downloading

Once you have `google-services.json` in the right place:

```bash
cd "C:\Users\alisha swornakar\Desktop\smartprep\university\university_app"
flutter clean
flutter pub get
flutter run
```

---

## Still Stuck?

If you can't find it, check:
1. ✓ You're logged in to Firebase Console with correct Google account
2. ✓ You created a project (not just viewing empty console)
3. ✓ The project has Android app registered (not just iOS/Web)
4. ✓ You're in the correct project (check project name at top left)

**Screenshot Help:**
- Go to https://firebase.google.com/docs/android/setup
- Scroll to "Add Firebase to your Android project"
- Follow step 1: "Create a Firebase project and register your app"

---

**Got the file? Let me know and we'll continue! 🔥**
