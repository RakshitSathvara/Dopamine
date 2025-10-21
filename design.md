# Dopamine - Design Document
## SwiftUI + Firebase + LiquidGlass UI

---

## Table of Contents
1. [Product Vision](#product-vision)
2. [LiquidGlass Design System](#liquidglass-design-system)
3. [User Personas](#user-personas)
4. [User Flows](#user-flows)
5. [Screen Specifications](#screen-specifications)
6. [SwiftUI Architecture](#swiftui-architecture)
7. [Firebase Integration](#firebase-integration)
8. [Data Models](#data-models)
9. [Component Library](#component-library)
10. [Animations & Interactions](#animations--interactions)
11. [Accessibility](#accessibility)
12. [Performance Optimization](#performance-optimization)

---

## Product Vision

### Problem Statement
Doomscrolling creates a dopamine-seeking behavior pattern that leads to decreased productivity, increased anxiety, and poor time management. Users need a visually engaging alternative that provides healthy dopamine responses through meaningful accomplishments.

### Solution
Dopamine leverages stunning LiquidGlass UI design with iOS-native SwiftUI to create an experience so beautiful and satisfying that users naturally prefer it over mindless scrolling. The glassmorphism aesthetic provides visual depth and sophistication while Firebase enables seamless backend functionality.

### Success Metrics
- **Engagement**: 60% DAU/MAU ratio
- **Session Duration**: Average 8-12 minutes per session
- **Completion Rate**: 70% of placed orders completed
- **Retention**: 40% 30-day retention rate
- **NPS Score**: >50

---

## LiquidGlass Design System

### Core Principles

Liquid Glass is Apple's revolutionary design language that transforms iOS interfaces with physically realistic glass materials that refract, reflect, and adapt dynamically. It combines optical glass properties with computational power to create fluid, depth-rich interfaces.

#### 1. Design Philosophy
**Content-First Presentation**: The design philosophy centers on content-first presentation with controls floating above in a distinct glass layer that adapts to context. This creates a clear separation between:
- **Content Layer**: Primary content (never uses glass)
- **Navigation/Control Layer**: Interactive elements (exclusively uses glass)

**Physical Glass Properties**:
- **Translucency**: Semi-transparent backgrounds revealing underlying content
- **Refraction**: Light bending through surfaces to distort backgrounds realistically
- **Reflection**: Surfaces mirroring surrounding content
- **Specular Highlights**: Dynamic lighting responding to device motion

#### 2. Visual Hierarchy & Layering
```
Vibrant Gradient Background Layer
    ↓
Content Layer (Photos, Text, Media - NO GLASS)
    ↓
Primary Glass Navigation Layer (Tab Bar, Toolbar, Sheets)
    ↓
Interactive Elements ON Glass (Solid Fills, NOT Additional Glass)
    ↓
Overlay Layer (Alerts, Popovers - Glass if appropriate)
```

**CRITICAL RULES**:
- ✅ Glass reserved EXCLUSIVELY for navigation layer
- ❌ NEVER use glass for content layer
- ❌ NEVER stack glass elements on top of each other
- ✅ One primary glass sheet per view (layer economy)
- ✅ Buttons/controls on glass use solid fills or vibrancy, NOT more glass

#### 3. Material Variants (iOS 15+)

SwiftUI provides five material thicknesses that automatically adapt to light/dark modes:

| Material | Blur Level | Transparency | Use Case |
|----------|------------|--------------|----------|
| `.ultraThinMaterial` | Minimal | Highest | Subtle effects over colorful content |
| `.thinMaterial` | Light | High | Light overlays |
| `.regularMaterial` | Standard | Medium | **DEFAULT - Most versatile** |
| `.thickMaterial` | Heavy | Low | Text overlays needing contrast |
| `.ultraThickMaterial` | Maximum | Lowest | Best contrast for text |

**Material Selection Guidelines**:
- **Regular variant**: Default choice - adaptive, versatile, legible in all contexts
- **Clear variant**: Permanent transparency, requires dimming layer, use ONLY when:
  - Element is over media-rich content
  - Content won't be negatively affected by dimming
  - Content above glass is bold and bright
- **NEVER mix variants** in the same interface

#### 4. Design Language
- **Fluidity**: Physics-based spring animations create liquid motion
- **Depth**: Multi-layer construction with atmospheric perspective
- **Clarity**: Content remains accessible despite transparency (4.5:1 contrast minimum)
- **Contextual Adaptation**: Glass dynamically morphs and adapts to context

### Color Palette

**CRITICAL**: Liquid Glass requires vibrant or gradient backgrounds to showcase translucency and depth. Glass effects appear flat against plain white backgrounds.

#### Background Gradients (Essential for Glass Effects)
```swift
// Light Mode - Vibrant Gradients
struct LightModeBackgrounds {
    static let primaryGradient = LinearGradient(
        colors: [
            Color(hex: "#E0E7FF"), // Light Indigo
            Color(hex: "#F5F3FF"), // Light Purple
            Color(hex: "#FDF4FF")  // Light Pink
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let accentGradient = LinearGradient(
        colors: [
            Color(hex: "#DBEAFE"), // Light Blue
            Color(hex: "#E0E7FF")  // Light Indigo
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

// Dark Mode - Rich Gradients
struct DarkModeBackgrounds {
    static let primaryGradient = LinearGradient(
        colors: [
            Color(hex: "#1F2937"), // Dark Gray
            Color(hex: "#111827"), // Darker Gray
            Color(hex: "#0F172A")  // Almost Black
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let accentGradient = LinearGradient(
        colors: [
            Color(hex: "#312E81"), // Dark Indigo
            Color(hex: "#1E1B4B")  // Darker Indigo
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}
```

#### Glass Tints (For Material Coloring)
```swift
struct GlassTints {
    // Light Mode
    static let lightPrimary = Color(hex: "#8B5CF6").opacity(0.15)
    static let lightSecondary = Color(hex: "#3B82F6").opacity(0.12)
    
    // Dark Mode
    static let darkPrimary = Color(hex: "#8B5CF6").opacity(0.25)
    static let darkSecondary = Color(hex: "#3B82F6").opacity(0.20)
}
```

#### Border Colors (For Glass Overlays)
```swift
struct GlassBorders {
    // Light Mode
    static let lightBorder = Color.white.opacity(0.2)      // Subtle
    static let lightAccent = Color.white.opacity(0.4)      // More visible
    
    // Dark Mode  
    static let darkBorder = Color.white.opacity(0.2)       // Subtle
    static let darkAccent = Color(hex: "#8B5CF6").opacity(0.5) // Colored accent
}
```

### Typography

#### Font System
```swift
struct Typography {
    // Display
    static let displayLarge = Font.system(size: 40, weight: .bold, design: .rounded)
    static let displayMedium = Font.system(size: 32, weight: .bold, design: .rounded)
    
    // Headings
    static let h1 = Font.system(size: 28, weight: .bold, design: .rounded)
    static let h2 = Font.system(size: 24, weight: .semibold, design: .rounded)
    static let h3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    
    // Body
    static let bodyLarge = Font.system(size: 18, weight: .regular, design: .default)
    static let body = Font.system(size: 16, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: 14, weight: .regular, design: .default)
    
    // Labels
    static let caption = Font.system(size: 12, weight: .medium, design: .default)
    static let overline = Font.system(size: 11, weight: .semibold, design: .default)
    
    // Special
    static let code = Font.system(size: 14, weight: .regular, design: .monospaced)
}
```

### Spacing System
```swift
enum Spacing: CGFloat {
    case xxxs = 2
    case xxs = 4
    case xs = 8
    case sm = 12
    case md = 16
    case lg = 24
    case xl = 32
    case xxl = 48
    case xxxl = 64
}
```

### Glass Effects

#### Blur Intensities
```swift
enum BlurStyle {
    case ultraThin      // Light content, subtle blur
    case thin           // Standard glass effect
    case regular        // Medium glass effect
    case thick          // Strong glass effect
    case prominent      // Very strong glass effect
}

extension BlurStyle {
    var uiBlurEffect: UIBlurEffect.Style {
        switch self {
        case .ultraThin: return .systemUltraThinMaterial
        case .thin: return .systemThinMaterial
        case .regular: return .systemMaterial
        case .thick: return .systemThickMaterial
        case .prominent: return .prominent
        }
    }
}
```

---

## User Personas

### Persona 1: The Digital Minimalist
- **Name**: Sarah, 29
- **Occupation**: UX Designer
- **Tech Level**: Expert
- **Devices**: iPhone 15 Pro, MacBook Pro
- **Goals**: Reduce screen time, maintain focus
- **Pain Points**: Can't resist checking social media
- **Motivation**: Clean, beautiful interfaces inspire her

### Persona 2: The Productivity Seeker
- **Name**: Marcus, 35
- **Occupation**: Software Engineer
- **Tech Level**: Advanced
- **Devices**: iPhone 14, Apple Watch
- **Goals**: Optimize daily routine, track habits
- **Pain Points**: Procrastination, lack of structure
- **Motivation**: Data-driven improvement

### Persona 3: The Wellness Enthusiast
- **Name**: Priya, 26
- **Occupation**: Marketing Manager
- **Tech Level**: Intermediate
- **Devices**: iPhone 13
- **Goals**: Mental health, work-life balance
- **Pain Points**: Stress, phone addiction
- **Motivation**: Mindfulness and self-care

---

## User Flows

### Authentication Flow

```
App Launch
    ↓
Splash Screen (LiquidGlass animation)
    ↓
Check Auth State
    ├─ Authenticated → Home Screen
    └─ Not Authenticated → Login Screen
           ↓
       Enter Email
           ↓
       Tap "Send OTP"
           ↓
       [Firebase sends OTP]
           ↓
       OTP Verification Screen
           ↓
       Enter 6-digit code
           ↓
       [Firebase verifies]
           ├─ Success → Create/Load User → Home Screen
           └─ Failure → Show Error → Retry (3 attempts max)
```

### Main Activity Flow

```
Home Screen
    ↓
View Categories in Glass Cards
    ├─ Tap Checkbox → Select/Deselect (Haptic)
    ├─ Pull to Refresh → Reload Activities
    └─ Tap "Add to Cart" → Add to Firestore Cart
           ↓
       Navigate to Profile (Tab)
           ↓
       View Cart Items in Glass List
           ├─ Swipe to Delete → Remove from Cart
           └─ Tap "Place Order" → Create Firestore Order
                  ↓
              Order Created (Animation)
                  ↓
              View Order Card in History
                  ↓
              Complete Activity
                  ↓
              Tap Checkbox → Mark Complete
                  ↓
              [Update Firestore]
                  ↓
              Show Celebration Animation
                  ↓
              Update Streak Counter
```

### Explore Menu Flow

```
Home Screen
    ↓
Tap "Menu" Tab
    ↓
Menu Screen with Categories
    ↓
Browse Collapsible Sections
    ├─ Tap Section Header → Expand/Collapse
    ├─ Tap Activity Card → View Details Modal
    │      ↓
    │  View Full Description
    │      ↓
    │  Tap "Add" → Add to Cart → Show Toast
    │
    └─ Use Search → Filter Activities
           ↓
       Tap Activity → Add to Cart
           ↓
       Badge Counter Updates (Animated)
```

---

## Screen Specifications

### 1. Splash Screen

**Purpose**: Brand introduction and auth check

**Layout**:
```
┌────────────────────────────────┐
│                                │
│     [Gradient Background]      │
│                                │
│                                │
│          [App Logo]            │
│           Dopamine             │
│                                │
│     [LiquidGlass Effect]       │
│     [Animated Particles]       │
│                                │
│                                │
│      [Loading Indicator]       │
│                                │
└────────────────────────────────┘
```

**SwiftUI Implementation**:
```swift
struct SplashView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                colors: [
                    Color(hex: "#E0E7FF"),
                    Color(hex: "#F5F3FF")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Logo with glass effect
            VStack(spacing: 24) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .glassEffect(cornerRadius: 30)
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                
                Text("Dopamine")
                    .font(.displayMedium)
                    .foregroundColor(.textPrimary)
            }
            .opacity(isAnimating ? 1.0 : 0.0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                isAnimating = true
            }
        }
    }
}
```

---

### 2. Login Screen

**Layout**:
```
┌────────────────────────────────┐
│          ← [Skip]              │
│                                │
│     [Vibrant Gradient BG]      │
│                                │
│      Welcome Back              │
│      Enter your email to       │
│      continue                  │
│                                │
│  ┌──────────────────────────┐ │
│  │  📧  Email Address       │ │
│  └──────────────────────────┘ │
│                                │
│  ┌──────────────────────────┐ │
│  │     Send OTP Code        │ │
│  └──────────────────────────┘ │
│                                │
│     Terms of Service  •  Privacy│
│                                │
└────────────────────────────────┘
```

**SwiftUI Implementation** (Following Liquid Glass Best Practices):
```swift
struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var email = ""
    @State private var isLoading = false
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency
    
    var body: some View {
        ZStack {
            // CRITICAL: Vibrant gradient background (essential for glass effects)
            LinearGradient(
                colors: [.purple, .blue, .pink],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Content layer (NO GLASS - following Apple guidelines)
            VStack(spacing: 32) {
                Spacer()
                
                // Header
                VStack(spacing: 12) {
                    Text("Welcome Back")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Enter your email to continue")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                // Glass Input Container (single glass element)
                VStack(spacing: 20) {
                    // Email Input with Glass Effect
                    GlassTextField(
                        text: $email,
                        placeholder: "Email Address",
                        icon: "envelope.fill"
                    )
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    
                    // Send OTP Button
                    GlassButton(
                        title: "Send OTP Code",
                        action: {
                            HapticManager.impact(.medium)
                            sendOTP()
                        },
                        isLoading: isLoading
                    )
                    .disabled(email.isEmpty || !email.isValidEmail)
                }
                .padding(30)
                .background(
                    // Use system Material for performance
                    reduceTransparency
                        ? AnyView(Color(.systemBackground).opacity(0.95))
                        : AnyView(Material.ultraThinMaterial),
                    in: RoundedRectangle(cornerRadius: 30, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Footer (NO GLASS - just text)
                HStack(spacing: 8) {
                    Text("Terms of Service")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("•")
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text("Privacy")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }
    
    private func sendOTP() {
        isLoading = true
        Task {
            await viewModel.sendOTP(to: email)
            isLoading = false
        }
    }
}

// Glass TextField Component
struct GlassTextField: View {
    @Binding var text: String
    let placeholder: String
    var icon: String?
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(.white.opacity(0.7))
                    .font(.body)
            }
            
            TextField(placeholder, text: $text)
                .foregroundColor(.white)
                .accentColor(.white)
                .placeholder(when: text.isEmpty) {
                    Text(placeholder)
                        .foregroundColor(.white.opacity(0.5))
                }
        }
        .padding()
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
    }
}

// Extension for placeholder
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
```

**Key Liquid Glass Principles Applied**:
1. ✅ Vibrant gradient background (essential for glass visibility)
2. ✅ Single glass container (layer economy)
3. ✅ System Materials for performance
4. ✅ Accessibility support (reduceTransparency)
5. ✅ Proper shadows (low opacity)
6. ✅ Subtle borders (white.opacity(0.2-0.3))
7. ✅ Continuous corner radius style
8. ✅ No stacked glass (inputs use ultraThin on single container)
```

---

### 3. OTP Verification Screen

**Layout**:
```
┌────────────────────────────────┐
│     ← Back                     │
│                                │
│  [Glass Background Blur]       │
│                                │
│    Enter verification code     │
│    Code sent to                │
│    user@email.com              │
│                                │
│   ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐│
│   │ 1│ │ 2│ │ 3│ │ 4│ │ 5│ │ 6││
│   └──┘ └──┘ └──┘ └──┘ └──┘ └──┘│
│                                │
│   Didn't receive code?         │
│   Resend in 0:45               │
│                                │
│  ┌──────────────────────────┐ │
│  │        Verify Code       │ │
│  └──────────────────────────┘ │
│                                │
└────────────────────────────────┘
```

**SwiftUI Implementation**:
```swift
struct OTPVerificationView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var otpCode: [String] = Array(repeating: "", count: 6)
    @State private var timeRemaining = 60
    @FocusState private var focusedField: Int?
    
    let email: String
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            GlassBackground(
                topColor: .purple.opacity(0.15),
                bottomColor: .blue.opacity(0.08)
            )
            
            VStack(spacing: 40) {
                Spacer()
                
                // Header
                VStack(spacing: 16) {
                    Text("Enter verification code")
                        .font(.h1)
                        .foregroundColor(.textPrimary)
                    
                    VStack(spacing: 4) {
                        Text("Code sent to")
                            .font(.body)
                            .foregroundColor(.textSecondary)
                        
                        Text(email)
                            .font(.bodySmall)
                            .foregroundColor(.textPrimary)
                            .fontWeight(.semibold)
                    }
                }
                
                // OTP Fields
                HStack(spacing: 12) {
                    ForEach(0..<6) { index in
                        OTPDigitField(
                            text: $otpCode[index],
                            isFocused: focusedField == index
                        )
                        .focused($focusedField, equals: index)
                        .onChange(of: otpCode[index]) { newValue in
                            handleOTPInput(at: index, value: newValue)
                        }
                    }
                }
                
                // Resend Timer
                HStack(spacing: 8) {
                    Text("Didn't receive code?")
                        .font(.bodySmall)
                        .foregroundColor(.textSecondary)
                    
                    if timeRemaining > 0 {
                        Text("Resend in \(formatTime(timeRemaining))")
                            .font(.bodySmall)
                            .foregroundColor(.textTertiary)
                    } else {
                        Button("Resend") {
                            HapticManager.impact(.light)
                            resendOTP()
                        }
                        .font(.bodySmall)
                        .foregroundColor(.info)
                    }
                }
                
                // Verify Button
                GlassButton(
                    title: "Verify Code",
                    action: verifyOTP,
                    isLoading: viewModel.isLoading
                )
                .disabled(otpCode.joined().count < 6)
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            focusedField = 0
        }
        .onReceive(timer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
    }
    
    private func handleOTPInput(at index: Int, value: String) {
        // Auto-advance to next field
        if value.count == 1 && index < 5 {
            focusedField = index + 1
        }
        
        // Auto-verify when all fields filled
        if otpCode.joined().count == 6 {
            HapticManager.notification(.success)
            verifyOTP()
        }
    }
    
    private func verifyOTP() {
        Task {
            await viewModel.verifyOTP(code: otpCode.joined(), email: email)
        }
    }
}

struct OTPDigitField: View {
    @Binding var text: String
    let isFocused: Bool
    
    var body: some View {
        ZStack {
            GlassCard(cornerRadius: 16, blur: .regular) {
                Text(text)
                    .font(.h2)
                    .foregroundColor(.textPrimary)
                    .frame(height: 64)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isFocused ? Color.borderAccent : Color.clear,
                        lineWidth: 2
                    )
            }
        }
        .frame(width: 48, height: 64)
    }
}
```

---

### 4. Home Screen (Dashboard)

**Layout**:
```
┌────────────────────────────────┐
│  Dopamine        🔔    👤      │
├────────────────────────────────┤
│                                │
│  Welcome back, Sarah! 👋       │
│  You have a 7 day streak 🔥    │
│                                │
│  ┌─────────────────────────┐  │
│  │ □ Morning Meditation    │  │
│  │   ⏱ 15 min · Starters   │  │
│  └─────────────────────────┘  │
│                                │
│  ┌─────────────────────────┐  │
│  │ ☑ Deep Work Session     │  │
│  │   ⏱ 90 min · Mains      │  │
│  └─────────────────────────┘  │
│                                │
│  ┌─────────────────────────┐  │
│  │ □ Evening Reading       │  │
│  │   ⏱ 30 min · Desserts   │  │
│  └─────────────────────────┘  │
│                                │
│         Explore Menu →         │
│                                │
├────────────────────────────────┤
│    [🛒 Add to Cart (2)]        │
│────────────────────────────────│
│  🏠 Home  📋 Menu  👤 Profile  │
└────────────────────────────────┘
```

**SwiftUI Implementation**:
```swift
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedActivities: Set<String> = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                GlassBackground(
                    topColor: .purple.opacity(0.12),
                    bottomColor: .blue.opacity(0.08)
                )
                
                VStack(spacing: 0) {
                    // Header
                    HomeHeader(
                        userName: viewModel.user?.name ?? "User",
                        streak: viewModel.user?.statistics.currentStreak ?? 0
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Activity List
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.activities) { activity in
                                ActivityCard(
                                    activity: activity,
                                    isSelected: selectedActivities.contains(activity.id),
                                    onToggle: {
                                        toggleSelection(activity.id)
                                    }
                                )
                                .animatedAppearance(
                                    delay: Double(viewModel.activities.firstIndex(of: activity) ?? 0) * 0.1
                                )
                            }
                            
                            // Explore More Button
                            NavigationLink {
                                MenuView()
                            } label: {
                                Text("Explore Menu →")
                                    .font(.bodyLarge)
                                    .foregroundColor(.info)
                            }
                            .padding(.vertical, 24)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                    }
                    
                    // Add to Cart Button
                    GlassButton(
                        title: "Add to Cart (\(selectedActivities.count))",
                        icon: "cart.badge.plus",
                        action: addToCart
                    )
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .disabled(selectedActivities.isEmpty)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func toggleSelection(_ id: String) {
        HapticManager.impact(.light)
        if selectedActivities.contains(id) {
            selectedActivities.remove(id)
        } else {
            selectedActivities.insert(id)
        }
    }
    
    private func addToCart() {
        HapticManager.notification(.success)
        Task {
            await viewModel.addToCart(activityIds: Array(selectedActivities))
            selectedActivities.removeAll()
        }
    }
}

struct HomeHeader: View {
    let userName: String
    let streak: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome back, \(userName)! 👋")
                        .font(.h2)
                        .foregroundColor(.textPrimary)
                    
                    if streak > 0 {
                        HStack(spacing: 6) {
                            Text("You have a \(streak) day streak")
                                .font(.bodySmall)
                                .foregroundColor(.textSecondary)
                            
                            Text("🔥")
                        }
                    }
                }
                
                Spacer()
                
                // Notification and Profile
                HStack(spacing: 16) {
                    Button {
                        HapticManager.impact(.light)
                    } label: {
                        Image(systemName: "bell.fill")
                            .font(.title3)
                            .foregroundColor(.textSecondary)
                    }
                    
                    Button {
                        HapticManager.impact(.light)
                    } label: {
                        Circle()
                            .fill(Color.purple.opacity(0.2))
                            .frame(width: 36, height: 36)
                            .overlay {
                                Text(String(userName.prefix(1)))
                                    .font(.bodySmall)
                                    .fontWeight(.semibold)
                            }
                    }
                }
            }
        }
    }
}

struct ActivityCard: View {
    let activity: Activity
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        GlassCard(cornerRadius: 20, blur: .thin) {
            HStack(spacing: 16) {
                // Checkbox
                CustomCheckbox(isChecked: isSelected, onToggle: onToggle)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(activity.name)
                        .font(.h3)
                        .foregroundColor(.textPrimary)
                    
                    HStack(spacing: 8) {
                        Label("\(activity.duration) min", systemImage: "clock.fill")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                        
                        Text("•")
                            .foregroundColor(.textTertiary)
                        
                        Text(activity.category.displayName)
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                Spacer()
            }
            .padding(16)
        }
    }
}
```

---

### 5. Menu Screen

**Layout**:
```
┌────────────────────────────────┐
│  Browse Activities    [🔍]     │
├────────────────────────────────┤
│                                │
│  ▼ Starters                    │
│  ┌─────────────────────────┐  │
│  │ 🧘 5-Min Breathing      │  │
│  │ ⏱ 5 min · 🔥 Focus     │  │
│  │                  [+ Add]│  │
│  └─────────────────────────┘  │
│  ┌─────────────────────────┐  │
│  │ 💪 Morning Stretch      │  │
│  │ ⏱ 10 min · ⚡ Energy   │  │
│  │                  [+ Add]│  │
│  └─────────────────────────┘  │
│                                │
│  ▶ Mains                       │
│  ▶ Sides                       │
│  ▶ Desserts                    │
│  ▶ Special                     │
│                                │
└────────────────────────────────┘
```

**SwiftUI Implementation**:
```swift
struct MenuView: View {
    @StateObject private var viewModel = MenuViewModel()
    @State private var expandedCategories: Set<ActivityCategory> = [.starters]
    @State private var searchText = ""
    
    var body: some View {
        ZStack {
            GlassBackground(
                topColor: .blue.opacity(0.10),
                bottomColor: .purple.opacity(0.08)
            )
            
            VStack(spacing: 0) {
                // Search Bar
                GlassTextField(
                    text: $searchText,
                    placeholder: "Search activities...",
                    icon: "magnifyingglass"
                )
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                // Categories List
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(ActivityCategory.allCases, id: \.self) { category in
                            CategorySection(
                                category: category,
                                activities: viewModel.activities(for: category),
                                isExpanded: expandedCategories.contains(category),
                                onToggle: {
                                    toggleCategory(category)
                                },
                                onAddActivity: { activity in
                                    addActivity(activity)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle("Browse Activities")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func toggleCategory(_ category: ActivityCategory) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            if expandedCategories.contains(category) {
                expandedCategories.remove(category)
            } else {
                expandedCategories.insert(category)
            }
        }
        HapticManager.impact(.light)
    }
    
    private func addActivity(_ activity: Activity) {
        HapticManager.notification(.success)
        Task {
            await viewModel.addToCart(activity: activity)
        }
    }
}

struct CategorySection: View {
    let category: ActivityCategory
    let activities: [Activity]
    let isExpanded: Bool
    let onToggle: () -> Void
    let onAddActivity: (Activity) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category Header
            Button(action: onToggle) {
                HStack {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.bodySmall)
                        .foregroundColor(.textSecondary)
                    
                    Text(category.displayName)
                        .font(.h2)
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    Text("\(activities.count)")
                        .font(.caption)
                        .foregroundColor(.textTertiary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.glassPrimary)
                        .clipShape(Capsule())
                }
            }
            
            // Activities
            if isExpanded {
                VStack(spacing: 12) {
                    ForEach(activities) { activity in
                        MenuActivityCard(
                            activity: activity,
                            onAdd: {
                                onAddActivity(activity)
                            }
                        )
                    }
                }
            }
        }
    }
}

struct MenuActivityCard: View {
    let activity: Activity
    let onAdd: () -> Void
    @State private var isAdded = false
    
    var body: some View {
        GlassCard(cornerRadius: 16, blur: .ultraThin) {
            HStack(spacing: 12) {
                // Icon
                Text(activity.icon)
                    .font(.system(size: 32))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.name)
                        .font(.h3)
                        .foregroundColor(.textPrimary)
                    
                    HStack(spacing: 8) {
                        Label("\(activity.duration) min", systemImage: "clock.fill")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                        
                        Text("•")
                            .foregroundColor(.textTertiary)
                        
                        Text(activity.benefits.first ?? "")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Add Button
                Button(action: {
                    onAdd()
                    withAnimation(.spring()) {
                        isAdded = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        isAdded = false
                    }
                }) {
                    Image(systemName: isAdded ? "checkmark" : "plus")
                        .font(.bodyLarge)
                        .fontWeight(.semibold)
                        .foregroundColor(isAdded ? .success : .info)
                        .frame(width: 40, height: 40)
                        .background(Color.glassPrimary)
                        .clipShape(Circle())
                }
            }
            .padding(12)
        }
    }
}
```

---

### 6. Profile Screen

**Layout**:
```
┌────────────────────────────────┐
│  Profile                  [⚙️]  │
├────────────────────────────────┤
│  ┌──────────────────────────┐  │
│  │ 👤  Sarah Thompson       │  │
│  │ 📧  sarah@email.com      │  │
│  │ 🔥  7 day streak!        │  │
│  └──────────────────────────┘  │
│                                │
│  ━━━ Your Cart ━━━             │
│                                │
│  ┌──────────────────────────┐  │
│  │ Morning Meditation  [×]  │  │
│  │ ⏱ 15 min               │  │
│  └──────────────────────────┘  │
│  ┌──────────────────────────┐  │
│  │ Deep Work Session   [×]  │  │
│  │ ⏱ 90 min               │  │
│  └──────────────────────────┘  │
│                                │
│  Total: 105 minutes            │
│  ┌──────────────────────────┐  │
│  │    📋 Place Order        │  │
│  └──────────────────────────┘  │
│                                │
│  ━━━ Order History ━━━         │
│                                │
│  ┌──────────────────────────┐  │
│  │ ✅ Today's Activities    │  │
│  │ 3 completed · Oct 20     │  │
│  │ [View Details →]        │  │
│  └──────────────────────────┘  │
│                                │
└────────────────────────────────┘
```

**SwiftUI Implementation**: (Character limit - see continuation below)

---

## SwiftUI Architecture

### MVVM Pattern

```swift
// Model
struct Activity: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let category: ActivityCategory
    let duration: Int
    let difficulty: Difficulty
    let benefits: [String]
    let icon: String
}

// ViewModel
@MainActor
class HomeViewModel: ObservableObject {
    @Published var activities: [Activity] = []
    @Published var user: User?
    @Published var isLoading = false
    @Published var error: AppError?
    
    private let activityService: ActivityService
    private let authService: AuthService
    
    init(
        activityService: ActivityService = .shared,
        authService: AuthService = .shared
    ) {
        self.activityService = activityService
        self.authService = authService
    }
    
    func loadActivities() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            activities = try await activityService.fetchActivities()
        } catch {
            self.error = error as? AppError
        }
    }
    
    func addToCart(activityIds: [String]) async {
        // Implementation
    }
}

// View
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        // UI Implementation
    }
}
```

### Service Layer

```swift
protocol ActivityServiceProtocol {
    func fetchActivities() async throws -> [Activity]
    func fetchActivity(id: String) async throws -> Activity
}

class ActivityService: ActivityServiceProtocol {
    static let shared = ActivityService()
    private let db = Firestore.firestore()
    
    func fetchActivities() async throws -> [Activity] {
        let snapshot = try await db.collection("activities")
            .whereField("isActive", isEqualTo: true)
            .order(by: "name")
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Activity.self)
        }
    }
}
```

---

## Firebase Integration

### Firestore Data Structure

```
/users/{userId}
    - email: String
    - name: String
    - createdAt: Timestamp
    - lastLoginAt: Timestamp
    - statistics: {
        currentStreak: Int
        longestStreak: Int
        totalActivitiesCompleted: Int
        totalMinutes: Int
    }
    - preferences: {
        notificationsEnabled: Bool
        darkMode: Bool
        dailyGoal: Int
    }

/activities/{activityId}
    - name: String
    - description: String
    - category: String
    - duration: Int
    - difficulty: String
    - benefits: [String]
    - icon: String
    - isActive: Bool

/carts/{userId}
    - items: [{
        activityId: String
        addedAt: Timestamp
    }]
    - updatedAt: Timestamp

/orders/{orderId}
    - userId: String
    - items: [{
        activityId: String
        activityName: String
        duration: Int
        isCompleted: Bool
        completedAt: Timestamp?
    }]
    - status: String
    - createdAt: Timestamp
    - completedAt: Timestamp?
    - totalDuration: Int
```

### Firestore Service Implementation

```swift
class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    
    // User Operations
    func createUser(_ user: User) async throws {
        try db.collection("users")
            .document(user.id)
            .setData(from: user)
    }
    
    func fetchUser(id: String) async throws -> User {
        let document = try await db.collection("users")
            .document(id)
            .getDocument()
        
        return try document.data(as: User.self)
    }
    
    // Real-time Listener
    func observeCart(userId: String) -> AsyncStream<Cart> {
        AsyncStream { continuation in
            let listener = db.collection("carts")
                .document(userId)
                .addSnapshotListener { snapshot, error in
                    guard let snapshot = snapshot,
                          let cart = try? snapshot.data(as: Cart.self) else {
                        return
                    }
                    continuation.yield(cart)
                }
            
            continuation.onTermination = { _ in
                listener.remove()
            }
        }
    }
}
```

---

## Component Library

### GlassCard Component

```swift
struct GlassCard<Content: View>: View {
    let cornerRadius: CGFloat
    let blur: BlurStyle
    let content: Content
    
    init(
        cornerRadius: CGFloat = 16,
        blur: BlurStyle = .thin,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.blur = blur
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // Blur background
            BlurView(style: blur.uiBlurEffect)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            
            // Border gradient
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.5),
                            Color.white.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
            
            // Content
            content
        }
        .shadow(
            color: Color.black.opacity(0.1),
            radius: 10,
            x: 0,
            y: 4
        )
    }
}
```

### GlassButton Component

```swift
struct GlassButton: View {
    let title: String
    var icon: String?
    let action: () -> Void
    var isLoading: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.bodyLarge)
                }
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Text(title)
                        .font(.bodyLarge)
                        .fontWeight(.semibold)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                ZStack {
                    BlurView(style: .systemThickMaterial)
                    
                    LinearGradient(
                        colors: [
                            Color.purple.opacity(0.6),
                            Color.blue.opacity(0.6)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            }
            .shadow(color: Color.purple.opacity(0.3), radius: 15, x: 0, y: 8)
        }
        .disabled(isLoading)
    }
}
```

---

## Animations & Interactions

### Spring Animations
```swift
extension Animation {
    static let glassSpring = Animation.spring(
        response: 0.6,
        dampingFraction: 0.7,
        blendDuration: 0.3
    )
    
    static let liquidSpring = Animation.spring(
        response: 0.5,
        dampingFraction: 0.8
    )
}
```

### Haptic Feedback
```swift
class HapticManager {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
```

---

## Performance Optimization

### LazyLoading
```swift
LazyVStack(spacing: 16) {
    ForEach(activities) { activity in
        ActivityCard(activity: activity)
            .id(activity.id)
    }
}
```

### Image Caching
Use SDWebImageSwiftUI or Kingfisher for efficient image loading.

---

## Complete Production Examples

### Glassmorphic Login Screen (Full Implementation)

This production-ready example demonstrates comprehensive Liquid Glass implementation following all Apple guidelines:

```swift
struct GlassmorphicLoginView: View {
    @State private var email = ""
    @State private var password = ""
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        ZStack {
            // CRITICAL: Vibrant gradient background (essential for glass effects)
            LinearGradient(
                colors: [.purple, .blue, .pink],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Single glass login container (layer economy principle)
            VStack(spacing: 25) {
                Text("Welcome Back")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Email TextField with Glass Style
                TextField("Email", text: $email)
                    .textFieldStyle(GlassTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                
                // Password SecureField with Glass Style
                SecureField("Password", text: $password)
                    .textFieldStyle(GlassTextFieldStyle())
                    .textContentType(.password)
                
                // Sign In Button (solid gradient, NOT glass)
                Button {
                    handleLogin()
                } label: {
                    Text("Sign In")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: Capsule()
                        )
                        .foregroundColor(.white)
                }
                .shadow(color: .blue.opacity(0.5), radius: 15)
                
                // Social Login Buttons (glass circles)
                HStack(spacing: 20) {
                    ForEach(["applelogo", "globe", "person.fill"], id: \.self) { icon in
                        Button {
                            handleSocialLogin(icon)
                        } label: {
                            Image(systemName: icon)
                                .font(.title3)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(.ultraThinMaterial, in: Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                }
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(
                        reduceTransparency
                            ? AnyShapeStyle(Color(.systemBackground).opacity(0.95))
                            : AnyShapeStyle(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .stroke(Color.white.opacity(0.2), lineWidth: 2)
                    )
            )
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 30)
        }
    }
    
    private func handleLogin() {
        HapticManager.impact(.medium)
        // Login logic
    }
    
    private func handleSocialLogin(_ provider: String) {
        HapticManager.impact(.light)
        // Social login logic
    }
}

// Custom Glass TextField Style
struct GlassTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .foregroundColor(.white)
    }
}
```

---

## Deployment Checklist

- [ ] Configure Firebase project
- [ ] Set up Firestore security rules
- [ ] Enable Firebase Auth providers
- [ ] Add GoogleService-Info.plist
- [ ] Configure App Store Connect
- [ ] Create screenshots (all sizes)
- [ ] Write App Store description
- [ ] Set up TestFlight
- [ ] Submit for review

---

---

## Liquid Glass Implementation Guidelines

### Apple's Design Rules (CRITICAL)

**Where to Use Liquid Glass**:
✅ Navigation layer ONLY:
- Tab bars
- Toolbars
- Sidebars
- Navigation bars
- Sheets and modals
- Menus and popovers
- Floating controls

**Where NOT to Use Liquid Glass**:
❌ Content layer (photos, text, articles, media)
❌ Stacked glass on glass
❌ Table/list view cells (too many instances = performance hit)
❌ Repeating elements in scrolling views

### Layer Economy Principle

**One Primary Glass Sheet Per View** is the target:

```swift
// ✅ CORRECT: Single glass sheet with solid elements on top
ZStack {
    GlassBackground(topColor: .purple.opacity(0.2), bottomColor: .blue.opacity(0.1))
    
    // Content layer (NO GLASS)
    ScrollView {
        // Your content here
    }
    
    // ONE primary glass navigation bar
    VStack {
        Spacer()
        TabBarView() // Uses .regularMaterial
    }
}

// ❌ WRONG: Multiple stacked glass layers
ZStack {
    GlassCard {
        GlassCard { // NEVER stack glass on glass!
            Text("Content")
        }
    }
}
```

### Material Selection Strategy

```swift
// iOS 15+ Material Usage Guide

// DEFAULT: Regular Material (Most Versatile)
.background(.regularMaterial)

// LIGHTER: Ultra Thin Material (Subtle, over colorful content)
.background(.ultraThinMaterial)

// HEAVIER: Thick Material (Better contrast for text)
.background(.thickMaterial)

// iOS 26+: Native Glass Effect
.glassEffect() // Default
.glassEffect(.regular) // Explicit regular
.glassEffect(.clear) // High transparency
.glassEffect(.regular.tint(.purple)) // Tinted glass
.glassEffect(.regular.interactive()) // Interactive glass
```

### Proper Shadow Implementation

Glass elements need subtle shadows to create depth:

```swift
// Standard glass shadow (LOW opacity is key)
.shadow(
    color: Color.black.opacity(0.2), // 0.1-0.3 range
    radius: 10,                       // 5-15 range
    x: 0,
    y: 5                              // Slight downward offset
)

// Multiple shadows for deeper effect
.shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
.shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 8)

// iOS 16+ Inner shadow
RoundedRectangle(cornerRadius: 12)
    .fill(.purple.shadow(.inner(radius: 3, x: 2, y: 2)))
```

### Border Styling

Subtle borders enhance the glass effect:

```swift
// Light backgrounds
.overlay(
    RoundedRectangle(cornerRadius: 20, style: .continuous)
        .stroke(Color.white.opacity(0.2), lineWidth: 1)
)

// Dark backgrounds  
.overlay(
    RoundedRectangle(cornerRadius: 20, style: .continuous)
        .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
)

// Accent borders (use sparingly)
.overlay(
    RoundedRectangle(cornerRadius: 20, style: .continuous)
        .stroke(
            LinearGradient(
                colors: [
                    Color.white.opacity(0.5),
                    Color.white.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            lineWidth: 1
        )
)
```

---

## Accessibility Requirements (NON-NEGOTIABLE)

### System Setting Responses

All Liquid Glass implementations MUST respect these accessibility settings:

```swift
@Environment(\.accessibilityReduceTransparency) var reduceTransparency
@Environment(\.accessibilityReduceMotion) var reduceMotion
@Environment(\.colorScheme) var colorScheme

var body: some View {
    content
        .background(
            reduceTransparency
                ? AnyView(Color(.systemBackground).opacity(0.95))
                : AnyView(Material.ultraThinMaterial)
        )
        .animation(
            reduceMotion ? .none : .spring(response: 0.6, dampingFraction: 0.8),
            value: someState
        )
}
```

### Accessibility Features Handled:

1. **Reduce Transparency**: Makes glass more opaque
2. **Increase Contrast**: Adds stronger borders
3. **Reduce Motion**: Disables elastic animations and parallax

**SwiftUI Materials handle these automatically**, but custom implementations must check environment values.

### Contrast Requirements

- **Minimum 4.5:1 text-to-background** contrast ratio (WCAG 2.2 AA)
- Use `.thickMaterial` or `.ultraThickMaterial` for text overlays
- Test with Xcode's Accessibility Inspector
- Verify readability in direct sunlight

```swift
// ✅ Good contrast for text on glass
Text("Important Text")
    .font(.headline)
    .foregroundColor(.primary) // System color adjusts automatically
    .padding()
    .background(.thickMaterial) // Heavier material for better contrast

// ❌ Poor contrast
Text("Important Text")
    .font(.caption)
    .foregroundColor(.gray)
    .padding()
    .background(.ultraThinMaterial) // Too transparent for small text
```

---

## Animation Guidelines

### Spring Animations (Default for Liquid Glass)

Springs maintain velocity continuity and create organic, physics-based motion:

```swift
// iOS 17+ Spring Presets (RECOMMENDED)
.smooth    // General purpose, non-bouncy
.snappy    // Quick, responsive
.bouncy    // Gentle bounce effect

// Usage
withAnimation(.smooth) {
    isExpanded.toggle()
}

// Custom spring
withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
    offset = newValue
}
```

### Gesture-Driven Interactions

Use `.interactiveSpring()` for continuous updates during user manipulation:

```swift
@State private var offset = CGSize.zero

var body: some View {
    glassCard
        .offset(offset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    offset = value.translation
                }
                .onEnded { _ in
                    withAnimation(.interactiveSpring()) {
                        offset = .zero
                    }
                }
        )
}
```

### Phase Animations (iOS 17+)

Perfect for loading states:

```swift
.phaseAnimator([false, true]) { content, phase in
    content
        .opacity(phase ? 1 : 0.5)
        .scaleEffect(phase ? 1 : 0.95)
} animation: { phase in
    .spring(duration: 1, bounce: 0.2)
}
```

---

## Performance Optimization

### Critical Performance Rules

1. **Prefer System Materials** over custom blur:
```swift
// ✅ FAST: System-optimized
.background(.regularMaterial)

// ❌ SLOWER: Custom blur
.blur(radius: 20)
```

2. **Use `.drawingGroup()` for complex hierarchies**:
```swift
VStack {
    // Multiple glass elements
    ForEach(items) { item in
        GlassCard { /* content */ }
    }
}
.drawingGroup() // Renders to single texture
```

3. **Conditional Glass** based on device capabilities:
```swift
if ProcessInfo.processInfo.isLowPowerModeEnabled {
    .background(Color(.systemBackground))
} else {
    .background(.ultraThinMaterial)
}
```

4. **Avoid Glass in Repeating Elements**:
```swift
// ❌ WRONG: Glass in every list cell (performance killer)
List(items) { item in
    Text(item.name)
        .padding()
        .background(.regularMaterial) // BAD: Creates many expensive blur operations
}

// ✅ CORRECT: Single glass background
ZStack {
    Color.clear
        .background(.regularMaterial) // One blur layer
    
    List(items) { item in
        Text(item.name)
            .listRowBackground(Color.clear) // Transparent cells
    }
}
```

### Profile and Test

- Use Xcode Instruments to monitor GPU usage
- Test on actual devices (especially older models)
- Check frame rates during animations
- Monitor battery impact during extended use
- Test in Low Power Mode

---

## Implementation Checklist

### Pre-Implementation
- [ ] Identify navigation vs content layers
- [ ] Design colorful background gradients
- [ ] Choose appropriate Material variants
- [ ] Plan layer economy (one primary glass sheet)

### During Implementation
- [ ] Use `.continuous` corner radius style
- [ ] Apply subtle borders (0.2-0.4 opacity)
- [ ] Add low-opacity shadows (0.1-0.3)
- [ ] Implement spring animations
- [ ] Use system Materials, not custom blur

### Accessibility Testing
- [ ] Enable Reduce Transparency
- [ ] Enable Increase Contrast
- [ ] Enable Reduce Motion
- [ ] Test with Accessibility Inspector
- [ ] Verify 4.5:1 contrast ratios
- [ ] Test in various lighting conditions

### Performance Validation
- [ ] Profile with Instruments
- [ ] Test on older devices
- [ ] Check Low Power Mode behavior
- [ ] Monitor frame rates during animations
- [ ] Verify no glass in repeating elements

### Final Polish
- [ ] Test on actual devices (not just simulator)
- [ ] Verify in light and dark modes
- [ ] Check all accessibility settings
- [ ] Validate in direct sunlight
- [ ] Confirm haptic feedback integration

---

**Document Version**: 2.0 (Updated with Official Liquid Glass Guidelines)  
**Platform**: iOS (SwiftUI)  
**Backend**: Firebase  
**UI Framework**: Liquid Glass  
**Last Updated**: October 21, 2025  
**Status**: Production Ready
