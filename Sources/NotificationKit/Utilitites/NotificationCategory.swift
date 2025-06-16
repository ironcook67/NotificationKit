//
//  NotificationCategory.swift
//  NotificationKit
//
//  Created by Chon Torres on 6/13/25.
//

import Foundation
@preconcurrency import UserNotifications

/// A utility for creating and managing notification categories and actions.
///
/// `NotificationCategory` provides a convenient way to set up interactive notifications
/// with custom actions that users can perform without opening the app.
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 10.0, visionOS 2.0, *)
public struct NotificationCategory: Sendable {

    /// The unique identifier for this category.
    public let identifier: String

    /// The actions available for this category.
    public let actions: [UNNotificationAction]

    /// The placeholder text to display in the notification interface.
    public let intentIdentifiers: [String]

    /// Options for how the category should be handled.
    public let options: UNNotificationCategoryOptions

    /// Creates a new notification category.
    ///
    /// - Parameters:
    ///   - identifier: The unique identifier for this category.
    ///   - actions: The actions available for this category.
    ///   - intentIdentifiers: Intent identifiers for Siri integration.
    ///   - options: Options for how the category should be handled.
    public init(
        identifier: String,
        actions: [UNNotificationAction] = [],
        intentIdentifiers: [String] = [],
        options: UNNotificationCategoryOptions = []
    ) {
        self.identifier = identifier
        self.actions = actions
        self.intentIdentifiers = intentIdentifiers
        self.options = options
    }

    /// Converts this category to a `UNNotificationCategory`.
    ///
    /// - Returns: A `UNNotificationCategory` configured with this category's properties.
    public func toUNNotificationCategory() -> UNNotificationCategory {
        return UNNotificationCategory(
            identifier: identifier,
            actions: actions,
            intentIdentifiers: intentIdentifiers,
            options: options
        )
    }

    /// Registers this category with the notification center.
    ///
    /// - Parameter notificationCenter: The notification center to register with. Defaults to current.
    public func register(with notificationCenter: UNUserNotificationCenter = .current()) async {
        let existingCategories = await notificationCenter.notificationCategories()
        var categories = Set(existingCategories)
        categories.insert(toUNNotificationCategory())
        notificationCenter.setNotificationCategories(categories)
    }
}
