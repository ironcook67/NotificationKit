//
//  NotificationTrigger.swift
//  NotificationKit
//
//  Created by Chon Torres on 6/13/25.

import Foundation
@preconcurrency import UserNotifications
#if os(iOS)
@preconcurrency import CoreLocation
#endif

/// Represents different types of triggers for scheduling notifications.
///
/// `NotificationTrigger` provides a Swift-friendly wrapper around the various
/// `UNNotificationTrigger` types, making it easier to work with different
/// scheduling scenarios.
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 10.0, visionOS 2.0, *)
public enum NotificationTrigger: @unchecked Sendable {

    /// Triggers the notification after a specified time interval.
    ///
    /// - Parameters:
    ///   - timeInterval: The time interval in seconds after which to deliver the notification.
    ///   - repeats: Whether the notification should repeat at the specified interval.
    case timeInterval(TimeInterval, repeats: Bool = false)

    /// Triggers the notification at a specific date and time.
    ///
    /// - Parameters:
    ///   - date: The date and time when the notification should be delivered.
    ///   - repeats: Whether the notification should repeat.
    case date(Date, repeats: Bool = false)

    /// Triggers the notification based on calendar components.
    ///
    /// This is useful for scheduling notifications at specific times (e.g., daily at 9 AM).
    ///
    /// - Parameters:
    ///   - dateComponents: The date components that determine when to deliver the notification.
    ///   - repeats: Whether the notification should repeat based on the date components.
    case calendar(dateComponents: DateComponents, repeats: Bool = false)

#if os(iOS)
    /// Triggers the notification when entering or leaving a geographic region.
    ///
    /// - Parameters:
    ///   - region: The geographic region that triggers the notification.
    ///   - repeats: Whether the notification should repeat when the condition is met again.
    ///
    /// - Note: Only available on iOS.
    case location(region: CLCircularRegion, repeats: Bool = false)
#endif

    /// Converts this trigger to a `UNNotificationTrigger`.
    ///
    /// This method is used internally to create the appropriate system trigger.
    ///
    /// - Returns: A `UNNotificationTrigger` configured for this trigger type.
    internal func toUNNotificationTrigger() -> UNNotificationTrigger? {
        switch self {
        case .timeInterval(let interval, let repeats):
            return UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: repeats)

        case .date(let date, let repeats):
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            return UNCalendarNotificationTrigger(dateMatching: components, repeats: repeats)

        case .calendar(let dateComponents, let repeats):
            return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)

#if os(iOS)
        case .location(let region, let repeats):
            return UNLocationNotificationTrigger(region: region, repeats: repeats)
#endif
        }
    }
}
