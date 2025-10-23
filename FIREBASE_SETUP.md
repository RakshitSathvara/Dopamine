# Firebase Setup Instructions

This document provides step-by-step instructions for setting up Firebase for the Dopamine iOS app.

## Prerequisites

1. An active Firebase account (sign up at [firebase.google.com](https://firebase.google.com))
2. Xcode 15.0 or later
3. iOS 16.0+ device or simulator

## Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project"
3. Enter project name: **Dopamine** (or your preferred name)
4. Enable Google Analytics (optional but recommended)
5. Click "Create project"

## Step 2: Add iOS App to Firebase Project

1. In Firebase Console, click the iOS icon to add an iOS app
2. Enter your iOS bundle ID (e.g., `com.dopamine.app`)
   - **Important**: This must match the bundle ID in your Xcode project
3. Optional: Enter app nickname (e.g., "Dopamine iOS")
4. Click "Register app"

## Step 3: Download GoogleService-Info.plist

1. Download the `GoogleService-Info.plist` file
2. Move the downloaded file to your Xcode project:
   ```bash
   # From your download folder
   mv ~/Downloads/GoogleService-Info.plist /path/to/Dopamine/
   ```
3. In Xcode:
   - Drag `GoogleService-Info.plist` into the Dopamine project
   - Make sure "Copy items if needed" is checked
   - Ensure the file is added to the Dopamine target

## Step 4: Add Firebase SDK via Swift Package Manager

Firebase dependencies are already configured in the code. You need to add them via SPM:

1. In Xcode, go to **File → Add Packages**
2. Enter the Firebase iOS SDK URL:
   ```
   https://github.com/firebase/firebase-ios-sdk
   ```
3. Select version **10.18.0** or later
4. Add the following products to your target:
   - ✅ FirebaseAuth
   - ✅ FirebaseFirestore
   - ✅ FirebaseStorage
   - ✅ FirebaseAnalytics
   - ✅ FirebaseCrashlytics

## Step 5: Enable Authentication Methods

1. In Firebase Console, go to **Authentication**
2. Click **Get Started**
3. Go to **Sign-in method** tab
4. Enable the following providers:

### Email/Password Authentication
- Click **Email/Password**
- Toggle **Enable**
- Click **Save**

### Email Link (Passwordless) Authentication (Recommended)
- This is already enabled with Email/Password
- The app uses Firebase Auth Email Link for OTP-style authentication

### Optional: Phone Authentication (for SMS OTP)
1. Click **Phone**
2. Toggle **Enable**
3. Add your phone number for testing (optional)
4. Click **Save**

## Step 6: Set Up Cloud Firestore

1. In Firebase Console, go to **Firestore Database**
2. Click **Create database**
3. Choose **Start in test mode** (we'll add security rules later)
4. Select your preferred location
5. Click **Enable**

### Set Up Firestore Security Rules

After creating the database, go to **Rules** tab and replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    match /users/{userId} {
      allow read, write: if isOwner(userId);
    }

    match /activities/{activityId} {
      allow read: if isAuthenticated();
      allow write: if false; // Only admins can write (use Firebase Console)
    }

    match /userActivities/{activityId} {
      allow read: if isAuthenticated() && 
        resource.data.userId == request.auth.uid;
      allow create: if isAuthenticated() && 
        request.resource.data.userId == request.auth.uid;
      allow update, delete: if isAuthenticated() && 
        resource.data.userId == request.auth.uid;
    }

    match /carts/{userId} {
      allow read, write: if isOwner(userId);
    }

    match /orders/{orderId} {
      allow read, update: if isAuthenticated() &&
        resource.data.userId == request.auth.uid;
      allow create: if isAuthenticated() &&
        request.resource.data.userId == request.auth.uid;
    }

    match /menu/{document=**} {
      allow read: if isAuthenticated();
      allow write: if false; // Only admins can write (use Firebase Console)
    }
  }
}
```

Click **Publish** to save the rules.

### Set Up Firestore Indexes

For efficient queries, you need to create composite indexes:

1. Go to **Firestore Database** → **Indexes** tab
2. Click **Create Index**
3. Create the following index for user activities:

**Index 1: User Activities Query**
- Collection ID: `userActivities`
- Fields:
  - Field: `userId` | Order: **Ascending**
  - Field: `createdAt` | Order: **Descending**
- Query scope: **Collection**

**Index 2: User Activities by Category**
- Collection ID: `userActivities`
- Fields:
  - Field: `userId` | Order: **Ascending**
  - Field: `category` | Order: **Ascending**
  - Field: `createdAt` | Order: **Descending**
- Query scope: **Collection**

4. Click **Create** for each index
5. Wait for indexes to build (usually takes a few minutes)

> **Note**: If you encounter an index error while using the app, Firebase will provide a direct link in the console to create the required index automatically.

## Step 7: Set Up Firebase Storage (Optional)

1. In Firebase Console, go to **Storage**
2. Click **Get started**
3. Choose **Start in test mode**
4. Click **Next** and **Done**

## Step 8: Create Required Indexes

Before using the app, create the required Firestore indexes:

1. **Click the error link**: When you first run the app, Firebase will show index requirement errors in the console with direct links
2. **Or create manually** following the index configurations in Step 6 above
3. **Wait for completion**: Index building typically takes 2-5 minutes
4. **Verify**: Check the Indexes tab to see "Enabled" status

## Step 9: Seed Sample Data

After setting up Firestore, you can seed sample activities and menu configuration:

### Seed Sample Activities

1. Build and run the app in Xcode
2. In your code, call `ActivityService.shared.seedSampleActivities()` once
   - You can add this temporarily in `DopamineApp.swift` init:
   ```swift
   init() {
       FirebaseManager.shared.configure()

       // Seed activities once (comment out after first run)
       Task {
           try? await ActivityService.shared.seedSampleActivities()
       }
   }
   ```
3. Run the app once, then comment out the seeding code

Alternatively, you can manually add activities in the Firebase Console:

1. Go to **Firestore Database**
2. Click **Start collection**
3. Collection ID: `activities`
4. Add sample documents following the Activity model structure

### Seed Menu Configuration

To set up the dopamine menu categories with descriptions:

1. In your code, call `MenuService.shared.seedMenuConfiguration()` once:
   ```swift
   init() {
       FirebaseManager.shared.configure()

       // Seed menu configuration once (comment out after first run)
       Task {
           try? await MenuService.shared.seedMenuConfiguration()
       }
   }
   ```
2. Run the app once, then comment out the seeding code

This will create a `menu/categories` document with all category descriptions (Starters, Mains, Sides, Desserts, Specials).

## Step 10: Configure Email Link Settings

For email link authentication to work properly:

1. In Firebase Console, go to **Authentication → Settings**
2. Scroll to **Authorized domains**
3. Verify that `localhost` is in the list (it should be by default)
   - The app currently uses `http://localhost` for development
   - This avoids the "Domain not allowlisted" error
4. For production: Add your custom domain (e.g., `dopamine.app`)
   - Click **Add domain**
   - Enter your domain name
   - Click **Add**

## Step 11: Build and Run

1. Open `Dopamine.xcodeproj` in Xcode
2. Select your target device or simulator
3. Press **Cmd + R** to build and run
4. The app should now connect to Firebase successfully!

## Troubleshooting

### "GoogleService-Info.plist not found"
- Ensure the file is in the project root and added to the Dopamine target
- Check that the file is not in `.gitignore`

### "Firebase configure() must be called before using Firebase"
- Make sure `FirebaseManager.shared.configure()` is called in `DopamineApp.init()`

### Authentication not working
- Check that Email/Password is enabled in Firebase Console
- Verify bundle ID matches in both Xcode and Firebase
- Check console logs for specific error messages

### Firestore permission denied
- Verify security rules are published
- Ensure user is authenticated before accessing Firestore
- Check that userId in documents matches authenticated user's UID

## Testing

### Test Authentication Flow

1. Run the app
2. Click "Send OTP Code" on login screen
3. For testing, use code "123456" (hardcoded for development)
4. You should be redirected to the main app

### Test Firestore

1. After authentication, navigate to different screens
2. Activities should load from Firestore
3. Try adding items to cart
4. Create an order and verify it appears in Firebase Console

## Production Checklist

Before deploying to production:

- [ ] Update Firestore security rules to production mode
- [ ] Remove hardcoded OTP ("123456") from `AuthViewModel`
- [ ] Implement real email link verification
- [ ] Add error tracking with Firebase Crashlytics
- [ ] Set up Firebase Analytics events
- [ ] Configure Firebase Remote Config for feature flags
- [ ] Add proper error handling for all Firebase operations
- [ ] Test on real devices
- [ ] Add rate limiting for authentication attempts

## Additional Resources

- [Firebase iOS Documentation](https://firebase.google.com/docs/ios/setup)
- [Firebase Authentication Guide](https://firebase.google.com/docs/auth/ios/start)
- [Cloud Firestore Guide](https://firebase.google.com/docs/firestore/quickstart)
- [Firebase Security Rules](https://firebase.google.com/docs/rules)

## Support

For issues or questions:
- Check Firebase Console for error logs
- Review Xcode console for detailed error messages
- Consult Firebase documentation
- Refer to the app's README.md for additional information
