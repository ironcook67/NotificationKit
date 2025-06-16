# NotificationKit Demo iOS App

A comprehensive iOS demo application showcasing all the features and capabilities of the NotificationKit Swift Package. This app demonstrates how to integrate and use NotificationKit in a real-world iOS application with a clean, modern SwiftUI interface.

![iOS](https://img.shields.io/badge/iOS-18.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-6.1-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0-green)
![Xcode](https://img.shields.io/badge/Xcode-16.0%2B-blue)

## 🌟 Features Demonstrated

### ✅ Core Notification Features
- **Permission Management**: Request and monitor notification permissions
- **Time-based Notifications**: Schedule notifications with custom time intervals
- **Calendar-based Notifications**: Set up recurring daily notifications
- **Location-based Notifications**: Trigger notifications based on geographic regions (iOS only)
- **Interactive UI**: Modern SwiftUI interface with real-time updates

### 🎯 Notification Management
- **Pending Notifications**: View and manage scheduled notifications
- **Delivered Notifications**: Track and clear delivered notifications
- **Bulk Operations**: Cancel all pending or clear all delivered notifications
- **Real-time Updates**: Automatic refresh of notification lists

### 📱 User Experience
- **Permission Status Indicators**: Visual feedback for notification and location permissions
- **Quick Actions**: One-tap buttons for common notification scenarios
- **Custom Scheduling**: Flexible controls for creating personalized notifications
- **Preset Locations**: Famous landmarks for easy location notification testing

## 🏗️ App Architecture

### SwiftUI + MVVM Pattern
```
NotificationKitDemoApp/
├── App/
│   ├── NotificationKitDemoApp.swift      # Main app entry point
│   └── ContentView.swift                 # Tab view container
├── Managers/
│   └── NotificationDemoManager.swift     # Main business logic & state management
├── Views/
│   ├── ScheduleNotificationsView.swift   # Notification scheduling interface
│   ├── ManageNotificationsView.swift     # Notification management interface
│   ├── LocationNotificationsView.swift   # Location-based notifications
│   └── SettingsView.swift               # App settings and status
└── Components/
    ├── PermissionStatusView.swift        # Permission status indicators
    ├── QuickNotificationButtons.swift    # Quick action buttons
    └── NotificationRow.swift            # List item components
```

### Key Components

#### **NotificationDemoManager**
- **@MainActor**: Ensures UI updates happen on the main thread
- **@ObservableObject**: Reactive state management with SwiftUI
- **Combines**: NotificationKit, CoreLocation, and UserNotifications
- **Handles**: Permission requests, notification scheduling, and status monitoring

#### **Four Main Views**
1. **Schedule**: Create and schedule different types of notifications
2. **Manage**: View and manage pending/delivered notifications
3. **Location**: Set up location-based notifications with map integration
4. **Settings**: Monitor app status and access system settings

## 📋 Requirements

- **iOS**: 18.0 or later
- **Xcode**: 16.0 or later
- **Swift**: 6.1 or later
- **NotificationKit**: 1.0.0 or later

## 🚀 Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/NotificationKit.git
cd NotificationKit/Demo
```

### 2. Install NotificationKit Dependency

#### Option A: Local Package (Recommended for testing)
1. In Xcode, go to **File → Add Package Dependencies**
2. Click **Add Local**
3. Select the `NotificationKit` folder from the cloned repository
4. Click **Add Package**

#### Option B: Remote Package
1. In Xcode, go to **File → Add Package Dependencies**
2. Enter: `https://github.com/yourusername/NotificationKit.git`
3. Select version `1.0.0` or later
4. Click **Add Package**

### 3. Configure App Permissions

Add the following keys to your `Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app uses location to demonstrate location-based notifications.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs location access to show location-based notification features.</string>
```

### 4. Build and Run
```bash
# Using Xcode
1. Open NotificationKitDemo.xcodeproj
2. Select your target device or simulator
3. Press Cmd+R to build and run

# Using command line
xcodebuild -project NotificationKitDemo.xcodeproj -scheme NotificationKitDemo -destination 'platform=iOS Simulator,name=iPhone 15' build
```

## 🎯 Usage Guide

### First Launch Setup

1. **Launch the app** on your iOS device or simulator
2. **Grant Notification Permission** when prompted (or use the "Request Permission" button)
3. **Grant Location Permission** for location-based features (optional)
4. **Start exploring** the different notification types!

### Testing Notifications

#### **Quick Test (5 seconds)**
1. Go to the **Schedule** tab
2. Tap the **"5 seconds"** button
3. Wait 5 seconds to see the notification appear

#### **Custom Time Notification**
1. Go to the **Schedule** tab
2. Adjust the time slider to your desired interval
3. Customize the title and body text
4. Tap **"Schedule Custom Notification"**

#### **Daily Recurring Notification**
1. Go to the **Schedule** tab
2. Set your preferred hour and minute
3. Tap **"Schedule Daily Notification"**
4. The notification will repeat daily at that time

#### **Location-Based Notification** (iOS only)
1. Go to the **Location** tab
2. Choose a preset location (e.g., "Apple Park")
3. Or enter custom coordinates
4. The notification will trigger when you enter that area

### Managing Notifications

#### **View Pending Notifications**
1. Go to the **Manage** tab
2. See all scheduled notifications
3. Cancel individual notifications or all at once

#### **Clear Delivered Notifications**
1. Go to the **Manage** tab
2. Scroll to "Delivered Notifications"
3. Remove individual notifications or clear all

## 🛠️ Customization

### Adding New Notification Types

```swift
// In NotificationDemoManager.swift
func scheduleCustomNotification() async {
    do {
        let request = NotificationRequest(
            id: "custom-\(UUID().uuidString)",
            title: "Custom Notification",
            body: "Your custom notification body",
            trigger: .timeInterval(60), // 1 minute
            sound: .default,
            badge: NSNumber(value: 1)
        )
        
        try await manager.schedule(request)
        await refreshNotifications()
        statusMessage = "✅ Custom notification scheduled"
    } catch {
        statusMessage = "❌ Failed: \(error.localizedDescription)"
    }
}
```

### Adding New UI Components

```swift
struct CustomNotificationView: View {
    @EnvironmentObject var notificationManager: NotificationDemoManager
    
    var body: some View {
        VStack {
            // Your custom UI here
            Button("Custom Action") {
                Task {
                    await notificationManager.scheduleCustomNotification()
                }
            }
        }
    }
}
```

### Extending Preset Locations

```swift
// In LocationNotificationsView.swift
let presetLocations = [
    ("Your Location", latitude, longitude, radius),
    ("Apple Park", 37.3349, -122.0090, 500.0),
    ("Your Custom Location", 40.7128, -74.0060, 200.0)
    // Add more locations here
]
```

## 🐛 Troubleshooting

### Common Issues

#### **Notifications Not Appearing**
- ✅ Check notification permissions in Settings
- ✅ Ensure the app is backgrounded when notifications should appear
- ✅ Verify notification scheduling was successful (check status messages)
- ✅ Check Do Not Disturb settings

#### **Location Notifications Not Working**
- ✅ Grant location permission to the app
- ✅ Ensure you're testing on a physical device (location simulation can be unreliable)
- ✅ Check that the radius is reasonable (not too small)
- ✅ Verify coordinates are correct

#### **App Crashes on Launch**
- ✅ Ensure iOS 18.0+ deployment target
- ✅ Verify NotificationKit dependency is properly added
- ✅ Check that required permissions are in Info.plist

#### **Build Errors**
- ✅ Clean build folder (Cmd+Shift+K)
- ✅ Update to Xcode 16.0+
- ✅ Verify Swift 6.1 compatibility
- ✅ Check NotificationKit package version

### Testing Tips

#### **Simulator Testing**
```bash
# Test notifications in simulator
xcrun simctl push <device_id> <bundle_id> notification.json

# Example notification.json
{
  "aps": {
    "alert": {
      "title": "Test Notification",
      "body": "This is a test notification"
    },
    "sound": "default"
  }
}
```

#### **Device Testing**
- **Background the app** to see notifications
- **Use short time intervals** (5-30 seconds) for quick testing
- **Test location notifications** in areas with good GPS signal
- **Monitor console logs** for debugging information

## 📖 Learning Resources

### Understanding the Code

#### **State Management Pattern**
```swift
@StateObject private var notificationManager = NotificationDemoManager()
@EnvironmentObject var notificationManager: NotificationDemoManager
```

#### **Async/Await Usage**
```swift
Task {
    await notificationManager.scheduleTimeIntervalNotification(
        seconds: timeInterval,
        title: customTitle,
        body: customBody
    )
}
```

#### **SwiftUI Integration**
```swift
.task {
    await notificationManager.initialize()
}
.refreshable {
    await notificationManager.refreshNotifications()
}
```

### NotificationKit Documentation
- [📚 Full Documentation](../README.md)
- [🔧 API Reference](../Sources/NotificationKit/)
- [🧪 Unit Tests](../Tests/NotificationKitTests/)

## 🤝 Contributing

We welcome contributions to improve the demo app! Here are some ideas:

### Enhancement Ideas
- [ ] Rich notification attachments (images, videos)
- [ ] Interactive notification actions
- [ ] Notification grouping and threading
- [ ] Apple Watch complications
- [ ] Shortcuts app integration
- [ ] Widget for quick notification scheduling

### How to Contribute
1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/new-feature`
3. **Make your changes** with clear, well-documented code
4. **Add tests** if applicable
5. **Submit a pull request** with a clear description

### Code Style Guidelines
- Follow Swift 6.1 best practices
- Use SwiftUI for all UI components
- Maintain async/await patterns
- Add proper documentation comments
- Include error handling

## 📄 License

This demo app is part of the NotificationKit project and is available under the MIT License. See the [LICENSE](../LICENSE) file for more details.

## 🙏 Acknowledgments

- **Apple** for the excellent UserNotifications and CoreLocation frameworks
- **Swift Community** for Swift 6.1 concurrency features
- **SwiftUI** for the modern, declarative UI framework

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/NotificationKit/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/NotificationKit/discussions)
- **Documentation**: [NotificationKit Docs](../README.md)

---

**Happy Coding!** 🚀

*Built with ❤️ using NotificationKit and SwiftUI*
