# Dopamine 🚀

A beautifully crafted iOS application with LiquidGlass UI that helps you break free from doomscrolling and embrace productive, meaningful activities.

## Overview

Dopamine is a native iOS application built with SwiftUI that transforms the way you interact with your daily choices. Featuring a stunning LiquidGlass interface with frosted glass effects and smooth animations, Dopamine gamifies productive activities through an intuitive, visually captivating experience.

## Key Features

### ✨ LiquidGlass UI Design
- **Glassmorphism Interface**: Beautiful frosted glass effects throughout the app
- **Fluid Animations**: Smooth, physics-based transitions
- **Depth & Layers**: Multi-layered UI with realistic depth perception
- **Dynamic Blur**: Context-aware blur effects that adapt to content
- **Haptic Feedback**: Rich tactile responses to user interactions

### 🔐 Firebase Authentication
- **Email-Based Login**: Secure Firebase Authentication
- **OTP Verification**: SMS/Email OTP for enhanced security
- **Persistent Sessions**: Automatic login with secure token management
- **Seamless Flow**: Elegant transitions between auth states

### 📱 Core Functionality

#### 1. Home Screen (Dashboard)
- Glassmorphic cards displaying activity categories
- Interactive checkboxes with smooth animations
- Quick "Add to Cart" button with badge counter
- Pull-to-refresh with custom animations
- Clean, distraction-free interface

#### 2. Menu Screen (Activity Browser)
- Organized into five intuitive categories:
  - **Starters**: Quick wins (5-15 min)
  - **Mains**: Deep focus sessions (30-120 min)
  - **Sides**: Skill-building activities (10-30 min)
  - **Desserts**: Rewarding experiences (15-45 min)
  - **Special**: Featured & seasonal activities
- Collapsible sections with spring animations
- Individual add buttons with haptic feedback
- Search and filter capabilities

#### 3. Profile Screen (Progress Tracker)
- **Cart Management**: Edit and review selected activities
- **Order Placement**: Commit to your activity plan
- **Order History**: Timeline view of completed sessions
- **Streak Tracking**: Visualize your consistency
- **Completion Marking**: One-tap completion with celebration animations

## Purpose

Dopamine addresses the modern challenge of doomscrolling by:
- Providing visually engaging alternatives to mindless scrolling
- Creating positive reinforcement through beautiful UI and completion tracking
- Building healthy digital habits through intentional, delightful interactions
- Leveraging stunning design to trigger positive engagement

## Technology Stack

### Frontend (iOS)
- **Framework**: SwiftUI (iOS 16+)
- **Language**: Swift 5.9+
- **Minimum iOS Version**: iOS 16.0
- **UI Library**: Custom LiquidGlass components
- **Architecture**: MVVM (Model-View-ViewModel)
- **Dependency Manager**: Swift Package Manager

### Backend & Services
- **Backend**: Firebase
  - **Authentication**: Firebase Auth (Email + OTP)
  - **Database**: Cloud Firestore
  - **Storage**: Firebase Storage
  - **Functions**: Cloud Functions for Firebase
  - **Analytics**: Firebase Analytics
  - **Crashlytics**: Firebase Crashlytics
  - **Remote Config**: Firebase Remote Config

### Development Tools
- **IDE**: Xcode 15+
- **Version Control**: Git
- **CI/CD**: Fastlane + GitHub Actions
- **Testing**: XCTest, SwiftUI Previews
- **Design**: Figma

## Getting Started

### Prerequisites
```bash
# System Requirements
macOS Ventura 13.0 or later
Xcode 15.0 or later
iOS 16.0+ device or simulator
Swift Package Manager
Firebase account
```

### Installation

1. **Clone the Repository**
```bash
git clone https://github.com/yourusername/dopamine.git
cd dopamine
```

2. **Open in Xcode**
```bash
open Dopamine.xcodeproj
```

3. **Install Firebase SDK**

Add Firebase to your project via Swift Package Manager:
- File → Add Packages
- Enter: `https://github.com/firebase/firebase-ios-sdk`
- Select version 10.18.0 or later
- Add these products:
  - FirebaseAuth
  - FirebaseFirestore
  - FirebaseStorage
  - FirebaseAnalytics
  - FirebaseCrashlytics

4. **Firebase Setup**
- Create a Firebase project at [firebase.google.com](https://firebase.google.com)
- Download `GoogleService-Info.plist`
- Drag it into your Xcode project (make sure "Copy items if needed" is checked)
- Enable Email/Password & Phone authentication in Firebase Console
- Create Firestore database in test mode

5. **Configure Info.plist**
```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```

6. **Build and Run**
- Select iPhone simulator or device
- Press `Cmd + R`
- App will launch with LiquidGlass interface

## Project Structure

```
Dopamine/
├── App/
│   └── DopamineApp.swift          # App entry point
├── Models/
│   ├── User.swift
│   ├── Activity.swift
│   ├── Cart.swift
│   └── Order.swift
├── Views/
│   ├── Auth/
│   │   ├── LoginView.swift
│   │   └── OTPVerificationView.swift
│   ├── Home/
│   │   ├── HomeView.swift
│   │   └── CategoryCardView.swift
│   ├── Menu/
│   │   ├── MenuView.swift
│   │   ├── ActivityCardView.swift
│   │   └── CategorySectionView.swift
│   └── Profile/
│       ├── ProfileView.swift
│       ├── CartView.swift
│       └── OrderHistoryView.swift
├── ViewModels/
│   ├── AuthViewModel.swift
│   ├── HomeViewModel.swift
│   ├── MenuViewModel.swift
│   └── ProfileViewModel.swift
├── Components/
│   ├── LiquidGlass/
│   │   ├── GlassCard.swift
│   │   ├── GlassButton.swift
│   │   ├── GlassBackground.swift
│   │   ├── GlassTextField.swift
│   │   └── BlurView.swift
│   ├── CustomCheckbox.swift
│   ├── LoadingView.swift
│   └── ToastView.swift
├── Services/
│   ├── FirebaseService.swift
│   ├── AuthService.swift
│   ├── ActivityService.swift
│   └── OrderService.swift
├── Utils/
│   ├── Extensions/
│   │   ├── Color+Extensions.swift
│   │   ├── View+Extensions.swift
│   │   └── String+Extensions.swift
│   ├── Constants.swift
│   ├── HapticManager.swift
│   └── Theme.swift
├── Resources/
│   ├── Assets.xcassets
│   ├── GoogleService-Info.plist
│   └── Localizable.strings
└── Tests/
    ├── DopamineTests/
    └── DopamineUITests/
```

## Firebase Configuration

### Firestore Database Structure

```
users/
  └── {userId}/
      ├── email: String
      ├── name: String
      ├── createdAt: Timestamp
      ├── lastLoginAt: Timestamp
      ├── statistics/
      │   ├── currentStreak: Int
      │   ├── longestStreak: Int
      │   ├── totalActivitiesCompleted: Int
      │   └── totalMinutes: Int
      └── preferences/
          ├── notificationsEnabled: Bool
          ├── darkMode: Bool
          └── dailyGoal: Int

activities/
  └── {activityId}/
      ├── name: String
      ├── description: String
      ├── category: String (starters|mains|sides|desserts|special)
      ├── duration: Int
      ├── difficulty: String
      ├── benefits: [String]
      ├── icon: String
      └── isActive: Bool

carts/
  └── {userId}/
      ├── items: [ActivityReference]
      └── updatedAt: Timestamp

orders/
  └── {orderId}/
      ├── userId: String
      ├── items: [OrderItem]
      ├── status: String
      ├── createdAt: Timestamp
      ├── completedAt: Timestamp?
      └── totalDuration: Int
```

### Firestore Security Rules

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
      allow write: if false;
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
  }
}
```

## Usage

### First Launch
1. Open the app - see beautiful splash screen with LiquidGlass effect
2. Enter your email on the login screen
3. Receive OTP code via email
4. Enter 6-digit OTP
5. Welcome to your dashboard!

### Daily Workflow
```
Open App → Browse Categories → Select Activities → 
Add to Cart → Review in Profile → Place Order → 
Complete Activities → Mark as Done → Build Streak!
```

## LiquidGlass UI Components

### Example Usage

```swift
// Glass Card with blur effect
GlassCard(cornerRadius: 20, blur: .systemThinMaterial) {
    VStack(alignment: .leading, spacing: 12) {
        Text(activity.name)
            .font(.headline)
        Text("\(activity.duration) min")
            .font(.subheadline)
            .foregroundColor(.secondary)
    }
    .padding()
}

// Glass Button with haptic feedback
GlassButton(
    title: "Add to Cart",
    icon: "cart.badge.plus",
    action: {
        HapticManager.impact(.medium)
        addToCart()
    }
)

// Glass Background for full screen
ZStack {
    GlassBackground(
        topColor: .blue.opacity(0.3),
        bottomColor: .purple.opacity(0.3)
    )
    
    // Your content here
}
```

## Key SwiftUI Modifiers

```swift
// Glass effect modifier
.glassEffect(cornerRadius: 16, intensity: 0.5)

// Animated appearance
.animatedAppearance(delay: 0.2)

// Haptic feedback on tap
.hapticFeedback(.medium)
```

## Testing

### Unit Tests
```swift
import XCTest
@testable import Dopamine

class ActivityServiceTests: XCTestCase {
    func testFetchActivities() async throws {
        let service = ActivityService()
        let activities = try await service.fetchActivities()
        
        XCTAssertFalse(activities.isEmpty)
        XCTAssertEqual(activities.first?.category, .starters)
    }
}
```

### UI Tests
```swift
func testLoginFlow() {
    let app = XCUIApplication()
    app.launch()
    
    // Test email input
    let emailField = app.textFields["emailTextField"]
    emailField.tap()
    emailField.typeText("test@example.com")
    
    // Test OTP button
    app.buttons["Send OTP"].tap()
    
    // Verify OTP screen appears
    XCTAssertTrue(app.staticTexts["Enter verification code"].waitForExistence(timeout: 2))
}
```

Run tests:
```bash
# In Xcode: Cmd + U
# Or via command line:
xcodebuild test -scheme Dopamine -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

## Performance Tips

### SwiftUI Optimization
```swift
// Use @StateObject for ViewModels
@StateObject private var viewModel = HomeViewModel()

// Implement Equatable on models
struct Activity: Identifiable, Equatable { }

// Use LazyVStack for lists
LazyVStack {
    ForEach(activities) { activity in
        ActivityCardView(activity: activity)
    }
}
```

### Firebase Best Practices
```swift
// Enable offline persistence
let settings = FirestoreSettings()
settings.isPersistenceEnabled = true
Firestore.firestore().settings = settings

// Use batch writes for multiple operations
let batch = Firestore.firestore().batch()
// Add operations...
try await batch.commit()

// Implement pagination
query.limit(to: 20)
     .start(afterDocument: lastDocument)
```

## Deployment

### 1. Prepare for Release
```bash
# Update version and build number
# In Xcode: General tab → Identity section

# Archive the app
# Product → Archive
```

### 2. Using Fastlane (Recommended)

Create `Fastfile`:
```ruby
default_platform(:ios)

platform :ios do
  desc "Push a new beta build to TestFlight"
  lane :beta do
    increment_build_number
    build_app(scheme: "Dopamine")
    upload_to_testflight
  end

  desc "Push a new release build to the App Store"
  lane :release do
    increment_build_number
    build_app(scheme: "Dopamine")
    upload_to_app_store
  end
end
```

Run:
```bash
fastlane beta
```

### 3. App Store Submission
- Complete App Store Connect metadata
- Add screenshots (6.7", 6.5", 5.5" displays)
- Write compelling app description
- Submit for review

## Roadmap

### Version 1.0 ✅
- Email & OTP authentication
- LiquidGlass UI components
- Activity browsing by category
- Cart management
- Order placement and history

### Version 1.1 (Q1 2026)
- [ ] Push notifications for reminders
- [ ] Home Screen widgets
- [ ] Apple Watch companion app
- [ ] Siri Shortcuts integration
- [ ] Enhanced dark mode

### Version 2.0 (Q2 2026)
- [ ] Social sharing features
- [ ] Custom activity creation
- [ ] Advanced analytics dashboard
- [ ] Gamification (badges, levels, rewards)
- [ ] In-app purchases & premium tier

### Version 3.0 (Q3 2026)
- [ ] AI-powered activity recommendations
- [ ] Team/Family sharing
- [ ] HealthKit integration
- [ ] iPad optimization
- [ ] macOS version

## Accessibility

### VoiceOver Support
```swift
.accessibilityLabel("Morning Meditation activity")
.accessibilityHint("Double tap to add to your cart")
.accessibilityValue("Duration: 15 minutes, Category: Starters")
```

### Dynamic Type
```swift
// Always use semantic font styles
Text("Title").font(.headline)
Text("Body").font(.body)

// Test with accessibility sizes
.environment(\.sizeCategory, .accessibilityExtraLarge)
```

### Reduce Motion
```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

var animation: Animation {
    reduceMotion ? .none : .spring(response: 0.6)
}
```

## Troubleshooting

### Common Issues

**Firebase Connection Failed**
```swift
// Verify GoogleService-Info.plist is included
// Check Bundle Identifier matches Firebase project
// Ensure FirebaseApp.configure() is called in App init
```

**OTP Not Receiving**
```bash
# Check Firebase Console → Authentication → Sign-in method
# Verify phone number or email is correctly formatted
# Check Firebase project quota limits
```

**Build Errors**
```bash
# Clean build folder
Cmd + Shift + K

# Delete derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# Reset package cache
File → Packages → Reset Package Caches
```

**UI Not Displaying Correctly**
```swift
// Check iOS deployment target is set to 16.0+
// Verify SwiftUI previews are working
// Test on actual device, not just simulator
```

## Contributing

1. Fork the repository
2. Create your feature branch
```bash
git checkout -b feature/AmazingFeature
```

3. Follow Swift style guide
```swift
// Use meaningful names
// Add documentation comments
// Follow MVVM architecture
```

4. Write tests
```swift
// Unit tests for services
// UI tests for critical flows
```

5. Commit changes
```bash
git commit -m 'Add some AmazingFeature'
```

6. Push and create PR
```bash
git push origin feature/AmazingFeature
```

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

## Support

- **Email**: support@dopamine.app
- **Documentation**: [docs.dopamine.app](https://docs.dopamine.app)
- **Issues**: [GitHub Issues](https://github.com/yourusername/dopamine/issues)
- **Discord**: [Join our community](https://discord.gg/dopamine)

## Acknowledgments

- Firebase team for exceptional backend services
- SwiftUI community for continuous inspiration
- Glassmorphism design community
- All contributors and beta testers
- Apple for amazing development tools

---

**Break the scroll. Build your life. 🌟**

*Crafted with ❤️ using SwiftUI and Firebase*
