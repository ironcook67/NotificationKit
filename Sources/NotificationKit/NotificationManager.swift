//
//  NotificationManager.swift
//  NotificationKit
//
//  Created by Chon Torres on 6/13/25.
//

import Foundation
@preconcurrency import UserNotifications

/// The main interface for managing notifications across Apple platforms.
///
/// `NotificationManager` provides a comprehensive set of tools for working with
/// local notifications, including scheduling, cancellation, and permission management.
/// All operations are designed to work seamlessly across iOS, macOS, tvOS, watchOS,
/// and visionOS.
///
/// ## Thread Safety
///
/// This class is thread-safe and all methods can be called from any queue.
/// Async methods will automatically switch to appropriate queues as needed.
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 10.0, visionOS 2.0, *)
public final class NotificationManager: @unchecked Sendable {

    /// The underlying notification center used for all operations.
    private let notificationCenter: UNUserNotificationCenter

    /// Creates a new notification manager with a custom notification center.
    ///
    /// - Parameter notificationCenter: The notification center to use.
    ///
    /// - Note: This initializer is primarily for testing with mock notification centers.
    public init(notificationCenter: UNUserNotificationCenter) {
        self.notificationCenter = notificationCenter
    }

    /// Creates a new notification manager with the current notification center.
    ///
    /// This is a convenience initializer that uses `UNUserNotificationCenter.current()`.
    /// It may not work in unit test environments due to bundle context requirements.
    public convenience init() {
        self.init(notificationCenter: UNUserNotificationCenter.current())
    }

    // MARK: - Permission Management

    /// Requests permission to send notifications to the user.
    ///
    /// This method will present the system permission dialog if the user hasn't
    /// been asked before. On subsequent calls, it returns the current permission status.
    ///
    /// - Parameter options: The types of notifications to request permission for.
    /// - Returns: `true` if permission was granted, `false` otherwise.
    ///
    /// ## Platform Differences
    ///
    /// - **macOS**: May require additional entitlements for certain notification types
    /// - **tvOS**: Limited notification support - primarily for background app refresh
    /// - **watchOS**: Notifications are managed by the paired iPhone app
    /// - **visionOS**: Full notification support with spatial considerations
    ///
    /// ## Example
    ///
    /// ```swift
    /// let manager = NotificationManager()
    /// let granted = await manager.requestPermission([.alert, .sound, .badge])
    ///
    /// if granted {
    ///     print("Notifications enabled")
    /// } else {
    ///     print("User denied notification permission")
    /// }
    /// ```
    public func requestPermission(_ options: UNAuthorizationOptions = [.alert, .sound, .badge]) async -> Bool {
        do {
            return try await notificationCenter.requestAuthorization(options: options)
        } catch {
            // Log error but don't crash - return false to indicate failure
            return false
        }
    }

    /// Gets the current notification authorization status.
    ///
    /// - Returns: The current authorization status for notifications.
    public func authorizationStatus() async -> UNAuthorizationStatus {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus
    }

    /// Gets the current notification settings for the app.
    ///
    /// This includes information about which types of notifications are enabled
    /// and the current authorization status.
    ///
    /// - Returns: The current notification settings.
    public func notificationSettings() async -> UNNotificationSettings {
        return await notificationCenter.notificationSettings()
    }

    // MARK: - Scheduling Notifications

    /// Schedules a local notification.
    ///
    /// This method adds a notification request to the system. The notification
    /// will be delivered according to the trigger specified in the request.
    ///
    /// - Parameter request: The notification request to schedule.
    /// - Throws: ``NotificationError`` if the request cannot be scheduled.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let request = NotificationRequest(
    ///     id: "daily-reminder",
    ///     title: "Daily Check-in",
    ///     body: "Time for your daily review!",
    ///     trigger: .calendar(dateComponents: DateComponents(hour: 9, minute: 0))
    /// )
    ///
    /// try await manager.schedule(request)
    /// ```
    public func schedule(_ request: NotificationRequest) async throws {
        let unRequest = request.toUNNotificationRequest()

        do {
            try await notificationCenter.add(unRequest)
        } catch {
            throw NotificationError.schedulingFailed(error)
        }
    }

    /// Schedules multiple notification requests.
    ///
    /// This is a convenience method for scheduling multiple notifications at once.
    /// If any individual request fails, the entire operation will throw an error.
    ///
    /// - Parameter requests: The notification requests to schedule.
    /// - Throws: ``NotificationError`` if any request cannot be scheduled.
    public func schedule(_ requests: [NotificationRequest]) async throws {
        for request in requests {
            try await schedule(request)
        }
    }

    // MARK: - Managing Notifications

    /// Cancels pending notifications with the specified identifiers.
    ///
    /// - Parameter identifiers: The identifiers of notifications to cancel.
    public func cancelPendingNotifications(withIdentifiers identifiers: [String]) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    /// Cancels a single pending notification.
    ///
    /// - Parameter identifier: The identifier of the notification to cancel.
    public func cancelPendingNotification(withIdentifier identifier: String) {
        cancelPendingNotifications(withIdentifiers: [identifier])
    }

    /// Cancels all pending notifications.
    public func cancelAllPendingNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }

    /// Removes delivered notifications from the notification center.
    ///
    /// - Parameter identifiers: The identifiers of delivered notifications to remove.
    public func removeDeliveredNotifications(withIdentifiers identifiers: [String]) {
        notificationCenter.removeDeliveredNotifications(withIdentifiers: identifiers)
    }

    /// Removes all delivered notifications from the notification center.
    public func removeAllDeliveredNotifications() {
        notificationCenter.removeAllDeliveredNotifications()
    }

    // MARK: - Querying Notifications

    /// Gets all pending notification requests.
    ///
    /// - Returns: An array of pending notification requests.
    public func pendingNotificationRequests() async -> [UNNotificationRequest] {
        return await notificationCenter.pendingNotificationRequests()
    }

    /// Gets all delivered notifications.
    ///
    /// - Returns: An array of delivered notifications.
    public func deliveredNotifications() async -> [UNNotification] {
        return await notificationCenter.deliveredNotifications()
    }

    /// Checks if a notification with the given identifier is pending.
    ///
    /// - Parameter identifier: The identifier to check for.
    /// - Returns: `true` if a notification with the identifier is pending, `false` otherwise.
    public func hasPendingNotification(withIdentifier identifier: String) async -> Bool {
        let pending = await pendingNotificationRequests()
        return pending.contains { $0.identifier == identifier }
    }
}
