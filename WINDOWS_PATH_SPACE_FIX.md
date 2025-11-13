# Windows Path Issue - How to Fix

## Problem
Your Windows username has a space: `alisha swornakar`

When Flutter tries to compile, it creates a path like:
```
C:\Users\alisha swornakar\Desktop\smartprep\university\university_app\build...
```

Gradle gets confused with the space and can't create the directory.

---

## Solutions

### Option 1: Move Project to Root Drive (RECOMMENDED)
Move your project to a path without spaces:

1. **Create new folder at C: root** (no spaces):
   ```
   C:\university_app
   ```

2. **Copy your entire project folder** there:
   ```
   From: C:\Users\alisha swornakar\Desktop\smartprep\university\university_app\
   To:   C:\university_app\
   ```

3. **Open PowerShell and navigate to new location**:
   ```powershell
   cd C:\university_app
   flutter run
   ```

This should work! ✅

---

### Option 2: Update Environment Variable (ADVANCED)
Set Gradle temp directory to avoid spaces:

```powershell
$env:GRADLE_USER_HOME = "C:\gradle_cache"
cd "C:\Users\alisha swornakar\Desktop\smartprep\university\university_app"
flutter run
```

---

### Option 3: Use WSL (Windows Subsystem for Linux)
If you have WSL installed:
```bash
# Inside WSL terminal
cd /mnt/c/Users/alisha\ swornakar/Desktop/smartprep/university/university_app
flutter run
```

---

## Recommended: Option 1

**Quickest fix:**
1. Create: `C:\university_app\`
2. Copy project there
3. Run: `cd C:\university_app` && `flutter run`

Try this and let me know if it works! 🚀

