# Dopamine Menu Configuration Guide

This guide explains how to implement and use the Dopamine Menu feature in your app.

## Overview

The Dopamine Menu is a categorized system for organizing activities that help boost mood and motivation. It's structured like a restaurant menu with different categories, each serving a specific purpose in the user's daily routine.

## Menu Categories

### 1. Starters (⚡)
**Purpose:** Quick 5–10 minute activities for a fast mood lift

**Description:** Like an appetizer before a meal, these activities provide immediate gratification and help you get started when motivation is low.

**Examples:**
- Short walk around the block
- Stretching exercises
- Listening to a favorite song
- Deep breathing exercises
- Quick tidy-up of one surface

---

### 2. Mains (🎯)
**Purpose:** Longer, more fulfilling activities (30-120 min)

**Description:** These are the "main course" activities that provide deeper satisfaction and a stronger sense of accomplishment.

**Examples:**
- Full workout session
- Organizing a room or closet
- Cooking a complete meal
- Working on a personal project
- Reading a book chapter

---

### 3. Sides (🔧)
**Purpose:** Complementary actions that make tasks easier or more enjoyable

**Description:** These enhance your main activities, like side dishes complement a meal.

**Examples:**
- Setting reminders for tasks
- Playing music while cleaning
- Preparing a workspace
- Using a timer for focused work
- Creating a task checklist

---

### 4. Desserts (🍰)
**Purpose:** Pleasurable activities to enjoy in moderation

**Description:** Sweet rewards that should be consumed mindfully, not as the main source of dopamine.

**Examples:**
- Watching a TV show episode
- Social media scrolling (time-limited)
- Gaming session
- Snacking on treats
- Online shopping browsing

---

### 5. Specials (⭐)
**Purpose:** Planned or goal-oriented activities for extra motivation

**Description:** Featured activities that align with your long-term goals and personal growth.

**Examples:**
- Journaling session
- Learning a new skill
- Creative projects (art, writing, music)
- Meditation practice
- Goal planning and reflection

---

## Technical Implementation

### Architecture

```
┌─────────────────────────────────────┐
│        Firestore Database           │
│    menu/categories (document)       │
│  ├── starters: MenuCategoryInfo     │
│  ├── mains: MenuCategoryInfo        │
│  ├── sides: MenuCategoryInfo        │
│  ├── desserts: MenuCategoryInfo     │
│  ├── specials: MenuCategoryInfo     │
│  └── updatedAt: Timestamp           │
└─────────────┬───────────────────────┘
              │
              ↓
┌─────────────────────────────────────┐
│         MenuService.swift           │
│  - fetchMenuConfiguration()         │
│  - listenToMenuConfiguration()      │
│  - updateCategoryInfo()             │
│  - seedMenuConfiguration()          │
└─────────────┬───────────────────────┘
              │
              ↓
┌─────────────────────────────────────┐
│       MenuViewModel.swift           │
│  - @Published menuConfiguration     │
│  - loadMenuConfiguration()          │
│  - getCategoryInfo(for:)            │
│  - getCategoryDescription(for:)     │
└─────────────┬───────────────────────┘
              │
              ↓
┌─────────────────────────────────────┐
│         SwiftUI Views               │
│  Display categories with            │
│  descriptions and icons             │
└─────────────────────────────────────┘
```

### Data Models

#### MenuCategoryInfo
```swift
struct MenuCategoryInfo: Codable {
    let title: String       // e.g., "Starters"
    let description: String // Full description
    let icon: String        // Emoji icon
    let order: Int          // Sort order (1-5)
}
```

#### MenuConfiguration
```swift
struct MenuConfiguration: Codable {
    let starters: MenuCategoryInfo
    let mains: MenuCategoryInfo
    let sides: MenuCategoryInfo
    let desserts: MenuCategoryInfo
    let specials: MenuCategoryInfo
    let updatedAt: Date
}
```

---

## Setup Instructions

### Step 1: Seed Menu Configuration

Run this code **once** to populate Firestore with menu data:

```swift
// In DopamineApp.swift or any appropriate place
Task {
    try? await MenuService.shared.seedMenuConfiguration()
}
```

This creates the following structure in Firestore:

```
menu/
└── categories/
    ├── starters: {title, description, icon, order}
    ├── mains: {title, description, icon, order}
    ├── sides: {title, description, icon, order}
    ├── desserts: {title, description, icon, order}
    ├── specials: {title, description, icon, order}
    └── updatedAt: Timestamp
```

### Step 2: Update Firestore Security Rules

Add this rule to allow authenticated users to read menu data:

```javascript
match /menu/{document=**} {
  allow read: if isAuthenticated();
  allow write: if false; // Only admins via Firebase Console
}
```

### Step 3: Fetch Menu Configuration

In your ViewModel:

```swift
@MainActor
class MenuViewModel: ObservableObject {
    @Published var menuConfiguration: MenuConfiguration?
    private let menuService = MenuService.shared

    func loadMenuConfiguration() async {
        do {
            menuConfiguration = try await menuService.fetchMenuConfiguration()
        } catch {
            // Fallback to default
            menuConfiguration = MenuConfiguration.default
        }
    }
}
```

---

## Usage Examples

### Display Category Information

```swift
struct CategoryHeaderView: View {
    let category: ActivityCategory
    @ObservedObject var viewModel: MenuViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(viewModel.getCategoryIcon(for: category))
                    .font(.title2)

                Text(viewModel.getCategoryTitle(for: category))
                    .font(.headline)
            }

            Text(viewModel.getCategoryDescription(for: category))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}
```

### Get Category Description

```swift
// In MenuViewModel
func getCategoryDescription(for category: ActivityCategory) -> String {
    return menuConfiguration?.getCategoryInfo(for: category).description
        ?? MenuConfiguration.default.getCategoryInfo(for: category).description
}
```

### Real-time Updates

For real-time synchronization when menu descriptions change:

```swift
class MenuViewModel: ObservableObject {
    private var menuListener: ListenerRegistration?

    func startListening() {
        menuListener = menuService.listenToMenuConfiguration()
    }

    deinit {
        menuListener?.remove()
    }
}
```

---

## Customization

### Update Category Description

To update a category description (admin only, via Firebase Console or backend):

```swift
let newInfo = MenuCategoryInfo(
    title: "Starters",
    description: "Updated description here",
    icon: "⚡",
    order: 1
)

try await MenuService.shared.updateCategoryInfo(
    category: .starters,
    info: newInfo
)
```

### Update Entire Menu

```swift
let updatedConfig = MenuConfiguration(
    starters: /* ... */,
    mains: /* ... */,
    sides: /* ... */,
    desserts: /* ... */,
    specials: /* ... */,
    updatedAt: Date()
)

try await MenuService.shared.updateMenuConfiguration(updatedConfig)
```

---

## Best Practices

### 1. **Offline-First Design**
- Menu configuration is cached by Firestore
- Always provide fallback to `MenuConfiguration.default`
- Handle fetch errors gracefully

### 2. **Load Early**
- Fetch menu configuration during app initialization
- Load before displaying category screens
- Consider prefetching during splash screen

### 3. **Error Handling**
```swift
do {
    menuConfiguration = try await menuService.fetchMenuConfiguration()
} catch {
    print("Error loading menu: \(error.localizedDescription)")
    // Use default configuration
    menuConfiguration = MenuConfiguration.default
}
```

### 4. **Admin Updates**
- Don't allow users to modify menu descriptions directly
- Use Firebase Console for admin updates
- Or implement a separate admin panel with proper authentication

### 5. **Performance**
- Fetch menu configuration once per session
- Use real-time listeners only if descriptions change frequently
- Cache in memory after initial fetch

---

## Security Considerations

### Read Access
- Only authenticated users can read menu configuration
- No personal user data in menu documents
- Safe to cache and share across users

### Write Access
- Completely restricted to admins
- Updates only via Firebase Console or authenticated backend
- No client-side write operations

---

## Testing

### Test Menu Seeding

```swift
func testSeedMenu() async {
    do {
        try await MenuService.shared.seedMenuConfiguration()
        let config = try await MenuService.shared.fetchMenuConfiguration()

        XCTAssertNotNil(config)
        XCTAssertEqual(config.starters.title, "Starters")
        print("✅ Menu seeding test passed")
    } catch {
        XCTFail("Menu seeding failed: \(error)")
    }
}
```

### Test Fetch

```swift
func testFetchMenu() async {
    let config = try? await MenuService.shared.fetchMenuConfiguration()
    XCTAssertNotNil(config)
    XCTAssertEqual(config?.getAllCategories().count, 5)
}
```

---

## Troubleshooting

### Issue: Menu not loading
**Solution:**
- Check Firestore security rules are published
- Verify user is authenticated
- Check network connectivity
- Verify `menu/categories` document exists in Firestore

### Issue: Getting default values only
**Solution:**
- Run seed function once to populate Firestore
- Check Firebase Console to verify document exists
- Review Firestore logs for permission errors

### Issue: Real-time updates not working
**Solution:**
- Ensure listener is properly registered
- Check listener isn't removed prematurely
- Verify Firestore settings have persistence enabled

---

## API Reference

### MenuService

| Method | Description | Returns |
|--------|-------------|---------|
| `fetchMenuConfiguration()` | Fetches menu from Firestore | `MenuConfiguration` |
| `seedMenuConfiguration()` | Seeds default menu data | `Void` |
| `listenToMenuConfiguration()` | Real-time listener | `ListenerRegistration` |
| `updateCategoryInfo(category:info:)` | Updates single category | `Void` |
| `getCategoryInfo(for:)` | Gets category info | `MenuCategoryInfo` |

### MenuViewModel

| Method | Description | Returns |
|--------|-------------|---------|
| `loadMenuConfiguration()` | Loads menu configuration | `Void` |
| `getCategoryInfo(for:)` | Gets category info | `MenuCategoryInfo` |
| `getCategoryTitle(for:)` | Gets category title | `String` |
| `getCategoryDescription(for:)` | Gets category description | `String` |
| `getCategoryIcon(for:)` | Gets category icon | `String` |

---

## Future Enhancements

### Potential Features

1. **Localization Support**
   - Translate descriptions to multiple languages
   - Store translations in Firestore
   - Detect user's locale and fetch appropriate version

2. **Personalized Descriptions**
   - Allow users to customize category descriptions
   - Store user preferences in their profile
   - Fall back to default if not customized

3. **Dynamic Categories**
   - Allow admins to add/remove categories
   - Store categories as an array instead of fixed fields
   - Support unlimited custom categories

4. **Category Analytics**
   - Track which categories users interact with most
   - Suggest categories based on time of day
   - Personalize ordering based on user behavior

5. **Rich Content**
   - Add images/videos to categories
   - Include tips and motivational quotes
   - Link to educational resources

---

## Support

For issues or questions:
- Check this guide first
- Review the implementation in `MenuService.swift`
- Check Firebase Console for data structure
- Review Firestore security rules

---

## Summary

The Dopamine Menu feature provides a structured, categorized approach to activity management. It's:
- ✅ **Cloud-based**: Stored in Firestore for easy updates
- ✅ **Offline-ready**: Cached for offline access
- ✅ **Flexible**: Easy to update descriptions without app updates
- ✅ **Scalable**: Can be extended with new features
- ✅ **Secure**: Proper access control via Firestore rules

By organizing activities into meaningful categories (Starters, Mains, Sides, Desserts, Specials), users can better understand the purpose and timing of different activities, leading to more intentional dopamine regulation and improved daily routines.
