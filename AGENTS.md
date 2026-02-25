# Agents

## Cursor Cloud specific instructions

### Project Overview

Dopamine is a native iOS (SwiftUI) app with a Firebase backend-as-a-service. There is no server-side code, no `Package.swift`, and no web frontend. The Xcode project is at `Dopamine.xcodeproj`.

### Platform Limitation

This project **requires macOS + Xcode** to build, run, and test the full application (iOS simulator or device). On the Linux Cloud Agent VM, the following development tasks are available:

| Task | Available on Linux | Notes |
|---|---|---|
| **Lint** (SwiftLint) | Yes | `swiftlint lint` from repo root |
| **Syntax check** | Yes | `swiftc -parse` on `.swift` files |
| **Full build** (`xcodebuild`) | No | Requires macOS + Xcode + iOS SDK |
| **Run app** (iOS simulator) | No | Requires macOS + Xcode |
| **Unit/UI tests** (`xcodebuild test`) | No | Requires macOS + iOS Simulator |

### How to Lint

```bash
swiftlint lint
```

SwiftLint 0.57.0 is pre-installed at `/usr/local/bin/swiftlint`. No `.swiftlint.yml` config file exists; defaults are used. The codebase currently has ~143 warnings and 9 serious violations (pre-existing).

### How to Syntax-Check All Swift Files

```bash
swiftc -parse $(find . -name "*.swift")
```

Swift 6.0.3 is installed at `/opt/swift/usr/bin/swift`. Make sure `/opt/swift/usr/bin` is on `PATH`.

### Key Caveats

- **No test targets exist** in the Xcode project. The `Tests/` directory mentioned in the README is aspirational; no test files are present.
- **Firebase credentials**: `GoogleService-Info.plist` is in `Dopamine/` with what appears to be real/test credentials. A `.template` version exists at the repo root.
- **Dependencies are managed via Xcode's built-in SPM** (resolved in `Dopamine.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`). There is no standalone `Package.swift`.
- **The DopamineTimerWidget** extension source files exist but the widget target is not yet added to the Xcode project; see `LIVE_ACTIVITY_SETUP.md`.
- For build/run/test instructions requiring macOS, see `README.md` § "Getting Started".
