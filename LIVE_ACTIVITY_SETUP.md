# Live Activity Timer Setup Instructions

## Overview
This document provides step-by-step instructions to complete the Live Activity timer implementation for the Dopamine app.

## What's Been Implemented

### 1. Core Files Created
- ✅ `Dopamine/Models/TimerActivityAttributes.swift` - Defines the data structure for Live Activities
- ✅ `Dopamine/Services/LiveActivityManager.swift` - Manages Live Activity lifecycle (start, pause, resume, stop)
- ✅ `DopamineTimerWidget/DopamineTimerWidgetBundle.swift` - Widget bundle entry point
- ✅ `DopamineTimerWidget/DopamineTimerLiveActivity.swift` - Live Activity UI (Lock Screen and Dynamic Island)
- ✅ `DopamineTimerWidget/Info.plist` - Widget extension configuration
- ✅ `Dopamine/Views/Screens/ProfileView.swift` - Updated with Live Activity integration

### 2. Features Implemented
- ✅ Countdown timer with real-time updates
- ✅ Lock Screen display with progress bar
- ✅ Dynamic Island support (compact, minimal, and expanded views)
- ✅ Pause/Resume functionality
- ✅ Automatic completion when timer reaches 0
- ✅ Visual timer display with emoji icons
- ✅ Progress bar showing time elapsed
- ✅ Monospaced digit display for better readability

## Setup Steps in Xcode

### Step 1: Create Widget Extension Target

1. Open `Dopamine.xcodeproj` in Xcode
2. Click on the project in the navigator (top-level "Dopamine" item)
3. Click the "+" button at the bottom of the targets list
4. Search for "Widget Extension"
5. Click "Next"
6. Configure the widget:
   - **Product Name**: `DopamineTimerWidget`
   - **Team**: Select your development team
   - **Bundle Identifier**: `com.yourcompany.Dopamine.DopamineTimerWidget` (use your actual bundle ID)
   - **Include Configuration Intent**: ❌ Uncheck this
7. Click "Finish"
8. When prompted about activating the scheme, click "Activate"

### Step 2: Add Widget Extension Files

1. Delete the default widget files Xcode created:
   - Right-click on `DopamineTimerWidget.swift` → Delete → Move to Trash
   - Right-click on `Assets.xcassets` in the widget folder → Delete → Move to Trash

2. Add the created files to the Widget Extension target:
   - Select `DopamineTimerWidget` folder in Xcode
   - Right-click → "Add Files to DopamineTimerWidget..."
   - Navigate to and select:
     - `DopamineTimerWidgetBundle.swift`
     - `DopamineTimerLiveActivity.swift`
   - Ensure "Copy items if needed" is checked
   - Target Membership: Check **DopamineTimerWidget** only

3. Add `TimerActivityAttributes.swift` to BOTH targets:
   - Select the file in the Project Navigator
   - In the File Inspector (right panel), check BOTH:
     - ✅ Dopamine
     - ✅ DopamineTimerWidget

### Step 3: Configure Info.plist for Main App

1. Select the main **Dopamine** target
2. Go to the "Info" tab
3. Click the "+" button to add a new key
4. Add: `NSSupportsLiveActivities` (or type "Supports Live Activities")
5. Set Type to: **Boolean**
6. Set Value to: **YES** (or check the box)

### Step 4: Add ActivityKit Framework

1. Select the main **Dopamine** target
2. Go to "General" tab
3. Scroll to "Frameworks, Libraries, and Embedded Content"
4. Click the "+" button
5. Search for "ActivityKit"
6. Select "ActivityKit.framework"
7. Click "Add"

8. Repeat for the **DopamineTimerWidget** target

### Step 5: Configure Widget Extension Settings

1. Select the **DopamineTimerWidget** target
2. Go to "General" tab
3. Set the following:
   - **iOS Deployment Target**: 16.1 or later
   - **Supported Destinations**: iPhone
4. Go to "Build Settings" tab
5. Search for "Info.plist"
6. Set **Info.plist File** to: `DopamineTimerWidget/Info.plist`

### Step 6: Update Main App's Deployment Target

1. Select the main **Dopamine** target
2. Go to "General" tab
3. Set **iOS Deployment Target**: 16.1 or later (Live Activities require iOS 16.1+)

### Step 7: Build and Run

1. Select the **Dopamine** scheme (not the Widget scheme)
2. Build the project: `Cmd + B`
3. Fix any compilation errors if they appear
4. Run on a physical device: `Cmd + R`
   - ⚠️ **Note**: Live Activities DO NOT work in the Simulator. You MUST test on a physical device.

## Testing the Live Activity

### Test Steps:

1. **Launch the app** on your iPhone (iOS 16.1+)
2. **Navigate to the Profile tab** (bottom navigation)
3. **Add an activity to cart** from the Menu or Home tab
4. **Go back to Profile** to see "Your Cart"
5. **Tap the green Play button** on a cart item
6. **Lock your phone** or move the app to background

### Expected Results:

✅ **Lock Screen**: You should see a card with:
- Activity emoji icon
- Activity name
- Countdown timer (MM:SS format)
- Progress bar showing time elapsed
- "X min left" label

✅ **Dynamic Island** (iPhone 14 Pro+):
- **Minimal**: Shows emoji icon
- **Compact**: Shows emoji and countdown timer
- **Expanded**: Shows full activity details, timer, and progress bar

✅ **Notifications Center**: Live Activity also appears in the notification center

### Test Controls:

- **Pause button** (orange): Pauses the timer and Live Activity
- **Stop button** (red): Stops and removes the Live Activity
- **Play again** (green): Resumes the countdown

## Troubleshooting

### Issue: "Module 'ActivityKit' not found"
**Solution**: Make sure ActivityKit framework is added to both targets (Step 4)

### Issue: Live Activity doesn't appear
**Solutions**:
1. Check that `NSSupportsLiveActivities` is set to YES in main app Info.plist
2. Ensure you're testing on a physical device (not simulator)
3. Check iOS version is 16.1 or higher
4. Verify Widget Extension is properly added to the app bundle
5. Check Console for error messages

### Issue: Widget Extension build fails
**Solutions**:
1. Verify `TimerActivityAttributes.swift` is added to both targets
2. Check that Info.plist path is correct for Widget target
3. Clean build folder: `Shift + Cmd + K`, then rebuild

### Issue: Live Activity shows but timer doesn't update
**Solutions**:
1. Check that the app has proper permissions
2. Verify `LiveActivityManager` timer is starting correctly
3. Check Console logs for timer update messages

### Issue: Dynamic Island doesn't show
**Solutions**:
1. Ensure you're using iPhone 14 Pro or later
2. Dynamic Island requires iOS 16.1+ and specific hardware
3. Compact view should still appear on other devices

## Code Structure

### Live Activity Flow:

```
User taps Start button
    ↓
ProfileView.onStart callback
    ↓
LiveActivityManager.startActivity()
    ↓
Creates Activity<TimerActivityAttributes>
    ↓
Starts internal Timer (1 second interval)
    ↓
Updates Live Activity every second
    ↓
When timer reaches 0:
    ↓
LiveActivityManager.completeActivity()
    ↓
Shows final state, then dismisses
```

### File Dependencies:

```
TimerActivityAttributes.swift
    ↓ (used by)
LiveActivityManager.swift & DopamineTimerLiveActivity.swift
    ↓ (used by)
ProfileView.swift
```

## Additional Configuration (Optional)

### Customize Live Activity Appearance:

Edit `DopamineTimerWidget/DopamineTimerLiveActivity.swift`:
- Change colors in the `LiveActivityView`
- Modify the progress bar gradient
- Update font styles and sizes
- Adjust spacing and padding

### Add Notification on Completion:

In `LiveActivityManager.swift`, modify `completeActivity()`:
```swift
func completeActivity(activityId: String) {
    // ... existing code ...

    // Add local notification
    let content = UNMutableNotificationContent()
    content.title = "Activity Complete!"
    content.body = "Your \(activityName) session has finished."
    content.sound = .default

    let request = UNNotificationRequest(identifier: activityId, content: content, trigger: nil)
    UNUserNotificationCenter.current().add(request)
}
```

## Next Steps

1. Complete the Xcode setup steps above
2. Test on a physical device
3. Customize the appearance if desired
4. Consider adding push notification updates for background operation
5. Add analytics tracking for Live Activity usage

## Support

For issues or questions:
- Check the troubleshooting section above
- Review Apple's Live Activities documentation: https://developer.apple.com/documentation/activitykit
- Check Xcode console for error messages

---

**Created**: 2025-11-04
**iOS Version Required**: 16.1+
**Devices**: iPhone only (Live Activities not available on iPad)
