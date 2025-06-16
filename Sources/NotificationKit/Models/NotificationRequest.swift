//
//  NotificationRequest.swift
//  NotificationKit
//
//  Created by Chon Torres on 6/13/25.
//

import Foundation
@preconcurrency import UserNotifications

/// A request to schedule a local notification.
///
/// `NotificationRequest` encapsulates all the information needed to create and schedule
/// a local notification, including the content, trigger, and optional attachments.
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 10.0, visionOS 2.0, *)
public struct NotificationRequest: @unchecked Sendable {

    /// The unique identifier for this notification request.
    public let id: String

    /// The title of the notification.
    public let title: String

    /// The body text of the notification.
    public let body: String?

    /// The subtitle of the notification (iOS/macOS only).
    public let subtitle: String?

    /// The trigger that determines when the notification should be delivered.
    public let trigger: NotificationTrigger?

    /// The app badge number to set when the notification is delivered.
    public let badge: NSNumber?

    /// The sound to play when the notification is delivered.
    public let sound: UNNotificationSound?

    /// The category identifier for the notification.
    ///
    /// This is used to group notifications and determine which actions are available.
    public let categoryIdentifier: String?

    /// Additional user information to include with the notification.
    public let userInfo: [AnyHashable: Any]

    /// The thread identifier for grouping notifications.
    public let threadIdentifier: String?

    /// Creates a new notification request.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for this notification.
    ///   - title: The title of the notification.
    ///   - body: The body text of the notification.
    ///   - subtitle: The subtitle of the notification (iOS/macOS only).
    ///   - trigger: When the notification should be delivered.
    ///   - badge: The app badge number to set.
    ///   - sound: The sound to play. Defaults to the default sound.
    ///   - categoryIdentifier: The category identifier for grouping and actions.
    ///   - userInfo: Additional user information.
    ///   - threadIdentifier: The thread identifier for grouping.
    public init(
        id: String,
        title: String,
        body: String? = nil,
        subtitle: String? = nil,
        trigger: NotificationTrigger? = nil,
        badge: NSNumber? = nil,
        sound: UNNotificationSound? = .default,
        categoryIdentifier: String? = nil,
        userInfo: [AnyHashable: Any] = [:],
        threadIdentifier: String? = nil
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.subtitle = subtitle
        self.trigger = trigger
        self.badge = badge
        self.sound = sound
        self.categoryIdentifier = categoryIdentifier
        self.userInfo = userInfo
        self.threadIdentifier = threadIdentifier
    }

    /// Converts this request to a `UNNotificationRequest`.
    ///
    /// This method is used internally to create the system notification request.
    ///
    /// - Returns: A `UNNotificationRequest` configured with this request's properties.
    internal func toUNNotificationRequest() -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body ?? ""
        content.subtitle = subtitle ?? ""
        content.badge = badge
        content.sound = sound
        content.categoryIdentifier = categoryIdentifier ?? ""
        content.userInfo = userInfo
        content.threadIdentifier = threadIdentifier ?? ""

        return UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger?.toUNNotificationTrigger()
        )
    }
}
