# NotificationKit

A comprehensive Swift Package for managing local notifications across all Apple platforms, built for Swift 6.1+ with modern concurrency support.

## Features

- **🌍 Universal**: Works across iOS 15+, macOS 12+, tvOS 15+, watchOS 8+, and visionOS 1+
- **⚡ Modern**: Built with Swift 6.1+ concurrency features (async/await, actors, structured concurrency)
- **🔒 Type-Safe**: Comprehensive error handling with detailed error types
- **📱 Platform-Aware**: Handles platform-specific notification behaviors and limitations
- **🧪 Well-Tested**: Comprehensive unit test coverage
- **📚 Documented**: Full DocC documentation for all public APIs
- **🎯 Focused**: Zero external dependencies - uses only system frameworks
- **💾 Persistence**: Optional SwiftData integration for notification tracking and analytics

## Platform Support

| Platform | Minimum Version | Notes |
|----------|-----------------|--------|
| iOS | 18.0+ | Full notification support with location triggers |
| macOS | 15.0+ | Full notification support (no location triggers) |
| tvOS | 18.0+ | Enhanced notification support for Apple TV |
| watchOS | 10.0+ | Rich notifications with improved interactions |
| visionOS | 2.0+ | Advanced spatial notification support |

## Installation

### Swift Package Manager

Add NotificationKit to your project using Xcode:

1. File → Add Package Dependencies
2. Enter the repository URL: `https://github.com/yourusername/NotificationKit.git`
3. Select version requirements

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/NotificationKit.git", from: "1.1.0")
]
```

## Quick Start

```swift
import NotificationKit

// Use the shared manager
let manager = NotificationKit.shared

// Request permission
let granted = await manager.requestPermission()
guard granted else {
    print("Notification permission denied")
    return
}

// Schedule a simple notification
let request = NotificationRequest(
    id: "welcome",
    title: "Welcome!",
    body: "Thanks for using NotificationKit",
    trigger: .timeInterval(5) // 5 seconds from now
)

try await manager.schedule(request)
```

## Persistence & Analytics

NotificationKit includes optional SwiftData persistence for tracking notification history and analytics:

```swift
// Enable persistence when creating the manager
let manager = NotificationManager(enablePersistence: true)

// Or use in-memory persistence for testing
let testManager = NotificationManager(enablePersistence: true, inMemoryPersistence: true)

// Get notification history
let history = try await manager.notificationHistory(limit: 100)
let recentHistory = try await manager.notificationHistory(
    limit: 50,
    since: Calendar.current.date(byAdding: .day, value: -7, to: Date())
)

// Get notification statistics
let stats = try await manager.notificationStatistics()
print("Delivered: \(stats.deliveredCount)")
print("Cancelled: \(stats.cancelledCount)")
print("Failed: \(stats.failedCount)")

// Mark notifications as delivered (typically called in UNUserNotificationCenterDelegate)
try await manager.markAsDelivered(notificationWithId: "notification-id")

// Cleanup old notification records
let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
try await manager.cleanupOldNotifications(olderThan: thirtyDaysAgo)
```

### Notification Status Lifecycle

When persistence is enabled, notifications automatically track their lifecycle:
- **`.created`**: Initial state when notification is created
- **`.scheduled`**: Successfully scheduled with the system
- **`.delivered`**: Delivered to the user (must be marked manually via delegate)
- **`.cancelled`**: Cancelled before delivery
- **`.failed`**: Failed to schedule or deliver

## Advanced Usage

### Scheduling Different Types of Notifications

#### Time-Based Notifications
```swift
// One-time notification after 1 hour
let oneTimeRequest = NotificationRequest(
    id: "reminder",
    title: "One Hour Reminder",
    body: "This was scheduled an hour ago",
    trigger: .timeInterval(3600)
)

// Repeating notification every 24 hours
let dailyRequest = NotificationRequest(
    id: "daily",
    title: "Daily Reminder",
    body: "This repeats every day",
    trigger: .timeInterval(86400, repeats: true)
)
```

#### Calendar-Based Notifications
```swift
// Daily at 9 AM
var morningComponents = DateComponents()
morningComponents.hour = 9
morningComponents.minute = 0

let morningRequest = NotificationRequest(
    id: "morning-reminder",
    title: "Good Morning!",
    body: "Start your day right",
    trigger: .calendar(dateComponents: morningComponents, repeats: true)
)

// Specific date and time
let specificDate = Calendar.current.date(
    byAdding: .day, 
    value: 7, 
    to: Date()
)!

let eventRequest = NotificationRequest(
    id: "event-reminder",
    title: "Event Reminder",
    body: "Your event is coming up!",
    trigger: .date(specificDate)
)
```

#### Location-Based Notifications (iOS only)
```swift
#if os(iOS)
@preconcurrency import CoreLocation

let region = CLCircularRegion(
    center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
    radius: 1000,
    identifier: "san-francisco-downtown"
)
region.notifyOnEntry = true
region.notifyOnExit = false

let locationRequest = NotificationRequest(
    id: "location-reminder",
    title: "Welcome to San Francisco!",
    body: "You've arrived at your destination",
    trigger: .location(region: region)
)
#endif
```

### Managing Notifications

```swift
// Check current permission status
let status = await manager.authorizationStatus()
print("Authorization status: \(status)")

// Get all pending notifications
let pending = await manager.pendingNotificationRequests()
print("Pending notifications: \(pending.count)")

// Cancel specific notifications
manager.cancelPendingNotification(withIdentifier: "daily")

// Cancel multiple notifications
manager.cancelPendingNotifications(withIdentifiers: ["reminder", "event"])

// Cancel all pending notifications
manager.cancelAllPendingNotifications()

// Remove delivered notifications
manager.removeDeliveredNotifications(withIdentifiers: ["welcome"])
manager.removeAllDeliveredNotifications()
```

### Interactive Notifications with Categories

```swift
import UserNotifications

// Create actions
let snoozeAction = UNNotificationAction(
    identifier: "snooze",
    title: "Snooze 10 min",
    options: []
)

let dismissAction = UNNotificationAction(
    identifier: "dismiss",
    title: "Dismiss",
    options: [.destructive]
)

// Create category
let category = NotificationCategory(
    identifier: "alarm",
    actions: [snoozeAction, dismissAction],
    options: [.customDismissAction]
)

// Register category
await category.register()

// Use category in notification
let alarmRequest = NotificationRequest(
    id: "alarm",
    title: "Alarm",
    body: "Time to wake up!",
    categoryIdentifier: "alarm",
    sound: .default
)

try await manager.schedule(alarmRequest)
```

### Error Handling

```swift
do {
    try await manager.schedule(request)
} catch NotificationError.permissionDenied {
    // Handle permission denied
    print("Please enable notifications in Settings")
} catch NotificationError.schedulingFailed(let error) {
    // Handle scheduling failure
    print("Failed to schedule: \(error.localizedDescription)")
} catch NotificationError.invalidContent(let reason) {
    // Handle invalid content
    print("Invalid content: \(reason)")
} catch {
    // Handle other errors
    print("Unexpected error: \(error)")
}
```

### Location Monitoring vs. Notification Triggers

It's important to understand the distinction between the two location-based APIs:

#### **CLMonitor** (iOS 17+)
```swift
// For general location monitoring in your app
@preconcurrency import CoreLocation

let monitor = await CLMonitor("LocationMonitor")
let condition = CLMonitor.CircularGeographicCondition(
    center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
    radius: 1000
)

await monitor.add(condition, identifier: "downtown", assuming: .unsatisfied)

for try await event in await monitor.events {
    // Handle location events in your app
    if event.state == .satisfied {
        // User entered the region - trigger a local notification manually
        let request = NotificationRequest(
            id: "entered-downtown",
            title: "Welcome!",
            body: "You've entered downtown San Francisco",
            trigger: .timeInterval(1) // Immediate notification
        )
        try await manager.schedule(request)
    }
}
```

#### **UNLocationNotificationTrigger** (iOS only)
```swift
// For system-managed location-triggered notifications
#if os(iOS)
@preconcurrency import CoreLocation

let region = CLCircularRegion(
    center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
    radius: 1000,
    identifier: "downtown-notifications"
)
region.notifyOnEntry = true

let locationRequest = NotificationRequest(
    id: "location-notification",
    title: "Welcome!",
    body: "You've entered downtown San Francisco",
    trigger: .location(region: region)
)

try await manager.schedule(locationRequest)
#endif
```

### Platform-Specific Considerations

#### iOS 18/iPadOS 18
- Enhanced interactive notifications with rich controls
- Improved notification grouping and threading
- Advanced Live Activities integration
- Enhanced focus mode integration
- **Location-based notifications with UNLocationNotificationTrigger**

#### macOS 15
- Redesigned notification center with better organization
- Enhanced focus modes with fine-grained control
- Improved notification scheduling accuracy
- Better integration with Stage Manager
- **Note: Location-based notifications not supported**

#### tvOS 18
- Enhanced notification support for Apple TV apps
- Better background app refresh notifications
- Improved user interaction patterns

#### watchOS 10
- Rich interactive notifications with enhanced haptics
- Improved complication notifications
- Better integration with Digital Crown interactions
- Enhanced notification stacking and management

#### visionOS 2
- Advanced spatial notification positioning
- Context-aware notification placement
- Enhanced immersive app notification handling
- Improved notification interaction in mixed reality contexts

## Best Practices

### 1. Request Permission Thoughtfully
```swift
// Request permission when the user is about to perform an action
// that would benefit from notifications, not immediately on app launch

func setupReminders() async {
    let granted = await manager.requestPermission([.alert, .sound, .badge])
    
    if granted {
        // Proceed with scheduling
    } else {
        // Provide alternative functionality or guide user to Settings
    }
}
```

### 2. Use Meaningful Identifiers
```swift
// Good: Descriptive identifiers
let request = NotificationRequest(
    id: "daily-standup-\(Date().timeIntervalSince1970)",
    title: "Daily Standup",
    body: "Time for the team standup meeting"
)

// Avoid: Generic identifiers
let request = NotificationRequest(
    id: "1",
    title: "Notification",
    body: "Something happened"
)
```

### 3. Handle Notification Responses
```swift
import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        switch response.actionIdentifier {
        case "snooze":
            // Handle snooze action
            scheduleSnoozeNotification()
        case "dismiss":
            // Handle dismiss action
            break
        default:
            // Handle default tap
            break
        }
        
        completionHandler()
    }
}

// Set the delegate
UNUserNotificationCenter.current().delegate = NotificationDelegate()
```

### 4. Test Across Platforms
```swift
#if DEBUG
extension NotificationManager {
    /// Debug helper to schedule a test notification immediately
    func scheduleTestNotification() async throws {
        let request = NotificationRequest(
            id: "test-\(UUID().uuidString)",
            title: "Test Notification",
            body: "This is a test on \(UIDevice.current.systemName)",
            trigger: .timeInterval(1)
        )
        
        try await schedule(request)
    }
}
#endif
```

## API Reference

### Core Classes

- **`NotificationManager`**: Main interface for notification operations
- **`NotificationRequest`**: Represents a notification to be scheduled
- **`NotificationTrigger`**: Defines when notifications should be delivered
- **`NotificationCategory`**: Manages interactive notification categories
- **`NotificationError`**: Comprehensive error types for debugging

### Key Methods

- `requestPermission(_:)`: Request notification permissions
- `schedule(_:)`: Schedule single or multiple notifications
- `cancelPendingNotifications(withIdentifiers:)`: Cancel pending notifications
- `pendingNotificationRequests()`: Get all pending notifications
- `authorizationStatus()`: Check current permission status

## Requirements

- **Swift**: 6.1+
- **Xcode**: 16.0+
- **iOS**: 18.0+
- **macOS**: 15.0+
- **tvOS**: 18.0+
- **watchOS**: 10.0+
- **visionOS**: 2.0+

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/new-feature`
3. Make your changes with tests
4. Run the test suite: `swift test`
5. Submit a pull request

### Development Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/NotificationKit.git
cd NotificationKit

# Run tests
swift test

# Generate documentation
swift package generate-documentation
```

## License

NotificationKit is available under the MIT license. See the LICENSE file for more info.

## Changelog

### 1.1.0
- **NEW**: SwiftData persistence system for notification tracking and analytics
- **NEW**: Notification history and statistics with `notificationHistory()` and `notificationStatistics()`
- **NEW**: Status lifecycle tracking (created → scheduled → delivered/cancelled/failed)
- **NEW**: Cross-platform persistence support with optional in-memory mode for testing
- **FIXED**: SwiftData enum storage compatibility issue with `NotificationStatus`
- **IMPROVED**: Enhanced notification management with persistence cleanup methods
- **IMPROVED**: Better error handling for persistence operations

### 1.0.0
- Initial release
- Cross-platform notification management
- Swift 6.1+ concurrency support
- Comprehensive error handling
- Full DocC documentation
- Platform-specific optimizations
