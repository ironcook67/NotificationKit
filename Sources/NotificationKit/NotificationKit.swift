// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
@preconcurrency import UserNotifications

/// A comprehensive notification management system for Apple platforms.
///
/// `NotificationKit` provides a unified interface for scheduling, managing, and handling
/// notifications across iOS, macOS, tvOS, watchOS, and visionOS. It leverages Swift 6.1+
/// concurrency features and provides a clean, async/await-based API.
///
/// ## Overview
///
/// The main entry point for notification operations is the ``NotificationManager`` class,
/// which provides methods for:
/// - Requesting notification permissions
/// - Scheduling local notifications
/// - Managing pending and delivered notifications
/// - Handling notification responses
///
/// ## Example Usage
///
/// ```swift
/// import NotificationKit
///
/// let manager = NotificationManager()
///
/// // Request permission
/// let granted = await manager.requestPermission()
///
/// // Schedule a notification
/// let request = NotificationRequest(
///     id: "reminder-1",
///     title: "Daily Reminder",
///     body: "Don't forget to check your tasks!",
///     trigger: .timeInterval(3600) // 1 hour from now
/// )
///
/// try await manager.schedule(request)
/// ```
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 10.0, visionOS 2.0, *)
public struct NotificationKit {
    /// The current version of the NotificationKit package.
    public static let version = "1.0.0"

    /// The shared notification manager instance.
    ///
    /// This provides a convenient way to access notification functionality
    /// without needing to create multiple manager instances.
    ///
    /// - Note: This property creates the manager lazily to avoid bundle context
    ///   issues in test environments. In tests, create managers directly using
    ///   `NotificationManager(notificationCenter:)` with a test-friendly center.
    public static let shared: NotificationManager = {
        return NotificationManager()
    }()

    /// Private initializer to prevent instantiation.
    ///
    /// Use ``NotificationKit/shared`` or create a ``NotificationManager`` directly.
    private init() {}
}
