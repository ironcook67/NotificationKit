# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

NotificationKit is a comprehensive Swift Package for managing local notifications across all Apple platforms (iOS 18+, macOS 15+, tvOS 18+, watchOS 10+, visionOS 2+). It's built with Swift 6.1+ and modern concurrency support (async/await, actors, structured concurrency).

## Architecture

### Core Components

- **NotificationKit**: Main entry point providing the shared manager instance and version info
- **NotificationManager**: Core class for all notification operations (scheduling, permissions, management)
- **NotificationRequest**: Data model representing a notification to be scheduled
- **NotificationTrigger**: Enum defining when notifications should fire (time, calendar, location)
- **NotificationCategory**: Interactive notification categories with actions
- **NotificationError**: Comprehensive error types for debugging

### Persistence Components (SwiftData)

- **PersistentNotificationRequest**: SwiftData model for storing notification data
- **NotificationPersistenceManager**: Manages CRUD operations for notification persistence
- **NotificationStatus**: Enum tracking notification lifecycle states (created, scheduled, delivered, cancelled, failed)
- **PersistentTriggerData**: Helper for serializing trigger data to JSON

### Directory Structure

```
Sources/NotificationKit/
├── NotificationKit.swift                      # Main entry point
├── NotificationManager.swift                  # Core manager class
├── NotificationPersistenceManager.swift       # SwiftData persistence layer
├── Models/
│   ├── NotificationError.swift                # Error definitions
│   ├── NotificationRequest.swift              # Request data model
│   ├── NotificationTrigger.swift              # Trigger types
│   └── PersistentNotificationRequest.swift    # SwiftData model
└── Utilities/
    └── NotificationCategory.swift             # Interactive categories

Tests/NotificationKitTests/         # Unit tests
NotificationKitDemo/               # Demo app with examples
```

## Development Commands

### Building and Testing
```bash
# Build the package
swift build

# Run all tests
swift test

# Run specific test file
swift test --filter NotificationKitTests.NotificationRequestTests
swift test --filter NotificationKitTests.NotificationPersistenceTests

# Build with release configuration
swift build -c release

# Build tests only
swift build --build-tests

# Generate code coverage
swift test --enable-code-coverage

# Clean build artifacts
swift package clean
```

### Package Management
```bash
# Update dependencies
swift package update

# Show dependency graph
swift package show-dependencies

# Dump package manifest as JSON
swift package dump-package

# Generate documentation
swift package generate-documentation
```

## Swift Features Used

- **Swift 6.1+** with strict concurrency enabled
- **Concurrency features**: async/await, actors, @Sendable conformance
- **Platform availability**: Uses @available for multi-platform support
- **Zero dependencies**: Only system frameworks (UserNotifications, Foundation, CoreLocation)

## Platform-Specific Notes

### iOS-Only Features
- Location-based notifications using `UNLocationNotificationTrigger`
- CoreLocation integration for region monitoring

### Platform Limitations
- **macOS**: No location-based notification support
- **Testing**: Some components require device/simulator due to notification center bundle context

## Testing Approach

- Unit tests cover all error types, request models, and triggers
- Use dependency injection for `NotificationManager` testing
- Mock `UNUserNotificationCenter` for isolated testing
- Platform-specific tests use conditional compilation (`#if os(iOS)`)

## Code Conventions

- **Concurrency**: All async operations use structured concurrency
- **Error Handling**: Comprehensive error types with detailed information
- **Documentation**: Full DocC documentation for public APIs
- **Availability**: Proper platform availability annotations
- **Thread Safety**: Classes marked as `@unchecked Sendable` where appropriate

## Persistence with SwiftData

NotificationKit includes optional persistence using SwiftData for tracking notification history and analytics.

### Enabling Persistence
```swift
// Enable persistence when creating NotificationManager
let manager = NotificationManager(enablePersistence: true)

// Or use in-memory persistence for testing
let testManager = NotificationManager(enablePersistence: true, inMemoryPersistence: true)
```

### Key Persistence Features
- **Automatic tracking**: All scheduled notifications are automatically saved
- **Status lifecycle**: Tracks created → scheduled → delivered/cancelled/failed states
- **History queries**: Retrieve notifications by status, date range, trigger type
- **Statistics**: Get counts by status and trigger type
- **Cleanup**: Remove old notification records
- **Cross-platform**: Works on all supported platforms

### Using Persistence Methods
```swift
// Get notification history
let history = try await manager.notificationHistory(limit: 100)

// Get statistics
let stats = try await manager.notificationStatistics()

// Mark notification as delivered (call in delegate)
try await manager.markAsDelivered(notificationWithId: "notification-id")

// Cleanup old records
let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
try await manager.cleanupOldNotifications(olderThan: thirtyDaysAgo)
```

## Demo App

The `NotificationKitDemo` directory contains a full SwiftUI demo app showing:
- Permission requests
- Different notification types (time, calendar, location)
- Interactive notifications
- Notification management
- **Persistence features**: History view, statistics, cleanup
- Platform-specific features