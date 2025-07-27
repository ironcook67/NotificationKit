//
//  PersistentNotificationRequest.swift
//  NotificationKit
//
//  Created by Claude Code on 7/27/25.
//

import Foundation
import SwiftData
@preconcurrency import UserNotifications
#if os(iOS)
@preconcurrency import CoreLocation
#endif

/// A SwiftData model for persisting notification requests.
///
/// `PersistentNotificationRequest` stores notification data in a persistent store,
/// allowing for tracking scheduled notifications, history, and analytics across app launches.
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 10.0, visionOS 2.0, *)
@Model
public final class PersistentNotificationRequest: @unchecked Sendable {
    
    /// The unique identifier for this notification request.
    @Attribute(.unique) public var id: String
    
    /// The title of the notification.
    public var title: String
    
    /// The body text of the notification.
    public var body: String?
    
    /// The subtitle of the notification.
    public var subtitle: String?
    
    /// The trigger data serialized as JSON.
    public var triggerData: Data?
    
    /// The trigger type for easier querying.
    public var triggerType: String?
    
    /// The app badge number to set when the notification is delivered.
    public var badge: Int?
    
    /// The sound name to play when the notification is delivered.
    public var soundName: String?
    
    /// The category identifier for the notification.
    public var categoryIdentifier: String?
    
    /// Additional user information serialized as JSON.
    public var userInfoData: Data?
    
    /// The thread identifier for grouping notifications.
    public var threadIdentifier: String?
    
    /// When this notification was created.
    public var createdAt: Date
    
    /// When this notification was scheduled.
    public var scheduledAt: Date?
    
    /// When this notification was delivered (if known).
    public var deliveredAt: Date?
    
    /// When this notification was cancelled.
    public var cancelledAt: Date?
    
    /// The current status of the notification (stored as raw value).
    private var statusRawValue: String
    
    /// The current status of the notification.
    public var status: NotificationStatus {
        get {
            NotificationStatus(rawValue: statusRawValue) ?? .created
        }
        set {
            statusRawValue = newValue.rawValue
        }
    }
    
    /// Creates a new persistent notification request.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for this notification.
    ///   - title: The title of the notification.
    ///   - body: The body text of the notification.
    ///   - subtitle: The subtitle of the notification.
    ///   - triggerData: The trigger data serialized as JSON.
    ///   - triggerType: The trigger type for easier querying.
    ///   - badge: The app badge number to set.
    ///   - soundName: The sound name to play.
    ///   - categoryIdentifier: The category identifier for grouping and actions.
    ///   - userInfoData: Additional user information serialized as JSON.
    ///   - threadIdentifier: The thread identifier for grouping.
    ///   - createdAt: When this notification was created.
    ///   - status: The current status of the notification.
    public init(
        id: String,
        title: String,
        body: String? = nil,
        subtitle: String? = nil,
        triggerData: Data? = nil,
        triggerType: String? = nil,
        badge: Int? = nil,
        soundName: String? = nil,
        categoryIdentifier: String? = nil,
        userInfoData: Data? = nil,
        threadIdentifier: String? = nil,
        createdAt: Date = Date(),
        status: NotificationStatus = .created
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.subtitle = subtitle
        self.triggerData = triggerData
        self.triggerType = triggerType
        self.badge = badge
        self.soundName = soundName
        self.categoryIdentifier = categoryIdentifier
        self.userInfoData = userInfoData
        self.threadIdentifier = threadIdentifier
        self.createdAt = createdAt
        self.statusRawValue = status.rawValue
    }
    
    /// Creates a persistent notification request from a `NotificationRequest`.
    ///
    /// - Parameter request: The notification request to convert.
    /// - Returns: A persistent notification request.
    public static func from(_ request: NotificationRequest) throws -> PersistentNotificationRequest {
        let triggerData: Data?
        let triggerType: String?
        
        if let trigger = request.trigger {
            triggerData = try JSONEncoder().encode(PersistentTriggerData.from(trigger))
            triggerType = PersistentTriggerData.from(trigger).type
        } else {
            triggerData = nil
            triggerType = nil
        }
        
        let userInfoData: Data?
        if !request.userInfo.isEmpty {
            userInfoData = try JSONSerialization.data(withJSONObject: request.userInfo)
        } else {
            userInfoData = nil
        }
        
        let soundName: String?
        if let sound = request.sound {
            if sound == UNNotificationSound.default {
                soundName = "default"
            } else {
                soundName = "custom" // For custom sounds, we'd need additional handling
            }
        } else {
            soundName = nil
        }
        
        return PersistentNotificationRequest(
            id: request.id,
            title: request.title,
            body: request.body,
            subtitle: request.subtitle,
            triggerData: triggerData,
            triggerType: triggerType,
            badge: request.badge?.intValue,
            soundName: soundName,
            categoryIdentifier: request.categoryIdentifier,
            userInfoData: userInfoData,
            threadIdentifier: request.threadIdentifier
        )
    }
    
    /// Converts this persistent request back to a `NotificationRequest`.
    ///
    /// - Returns: A notification request.
    public func toNotificationRequest() throws -> NotificationRequest {
        let trigger: NotificationTrigger?
        if let triggerData = triggerData {
            let persistentTrigger = try JSONDecoder().decode(PersistentTriggerData.self, from: triggerData)
            trigger = try persistentTrigger.toNotificationTrigger()
        } else {
            trigger = nil
        }
        
        let userInfo: [AnyHashable: Any]
        if let userInfoData = userInfoData {
            userInfo = try JSONSerialization.jsonObject(with: userInfoData) as? [AnyHashable: Any] ?? [:]
        } else {
            userInfo = [:]
        }
        
        let sound: UNNotificationSound?
        if let soundName = soundName {
            sound = soundName == "default" ? .default : nil
        } else {
            sound = nil
        }
        
        let badgeNumber: NSNumber?
        if let badge = badge {
            badgeNumber = NSNumber(value: badge)
        } else {
            badgeNumber = nil
        }
        
        return NotificationRequest(
            id: id,
            title: title,
            body: body,
            subtitle: subtitle,
            trigger: trigger,
            badge: badgeNumber,
            sound: sound,
            categoryIdentifier: categoryIdentifier,
            userInfo: userInfo,
            threadIdentifier: threadIdentifier
        )
    }
}

/// Represents the status of a notification in the persistence system.
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 10.0, visionOS 2.0, *)
public enum NotificationStatus: String, Codable, CaseIterable, Sendable {
    /// The notification has been created but not yet scheduled.
    case created
    
    /// The notification has been scheduled with the system.
    case scheduled
    
    /// The notification has been delivered to the user.
    case delivered
    
    /// The notification has been cancelled before delivery.
    case cancelled
    
    /// The notification failed to schedule or deliver.
    case failed
}

/// A helper struct for serializing trigger data.
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 10.0, visionOS 2.0, *)
public struct PersistentTriggerData: Codable, Sendable {
    public let type: String
    public let timeInterval: TimeInterval?
    public let date: Date?
    public let dateComponents: DateComponents?
    public let repeats: Bool
    
    #if os(iOS)
    public let locationLatitude: Double?
    public let locationLongitude: Double?
    public let locationRadius: Double?
    public let locationIdentifier: String?
    public let locationNotifyOnEntry: Bool?
    public let locationNotifyOnExit: Bool?
    #endif
    
    public static func from(_ trigger: NotificationTrigger) -> PersistentTriggerData {
        switch trigger {
        case .timeInterval(let interval, let repeats):
            #if os(iOS)
            return PersistentTriggerData(
                type: "timeInterval",
                timeInterval: interval,
                date: nil,
                dateComponents: nil,
                repeats: repeats,
                locationLatitude: nil,
                locationLongitude: nil,
                locationRadius: nil,
                locationIdentifier: nil,
                locationNotifyOnEntry: nil,
                locationNotifyOnExit: nil
            )
            #else
            return PersistentTriggerData(
                type: "timeInterval",
                timeInterval: interval,
                date: nil,
                dateComponents: nil,
                repeats: repeats
            )
            #endif
            
        case .date(let date, let repeats):
            #if os(iOS)
            return PersistentTriggerData(
                type: "date",
                timeInterval: nil,
                date: date,
                dateComponents: nil,
                repeats: repeats,
                locationLatitude: nil,
                locationLongitude: nil,
                locationRadius: nil,
                locationIdentifier: nil,
                locationNotifyOnEntry: nil,
                locationNotifyOnExit: nil
            )
            #else
            return PersistentTriggerData(
                type: "date",
                timeInterval: nil,
                date: date,
                dateComponents: nil,
                repeats: repeats
            )
            #endif
            
        case .calendar(let dateComponents, let repeats):
            #if os(iOS)
            return PersistentTriggerData(
                type: "calendar",
                timeInterval: nil,
                date: nil,
                dateComponents: dateComponents,
                repeats: repeats,
                locationLatitude: nil,
                locationLongitude: nil,
                locationRadius: nil,
                locationIdentifier: nil,
                locationNotifyOnEntry: nil,
                locationNotifyOnExit: nil
            )
            #else
            return PersistentTriggerData(
                type: "calendar",
                timeInterval: nil,
                date: nil,
                dateComponents: dateComponents,
                repeats: repeats
            )
            #endif
            
        #if os(iOS)
        case .location(let region, let repeats):
            return PersistentTriggerData(
                type: "location",
                timeInterval: nil,
                date: nil,
                dateComponents: nil,
                repeats: repeats,
                locationLatitude: region.center.latitude,
                locationLongitude: region.center.longitude,
                locationRadius: region.radius,
                locationIdentifier: region.identifier,
                locationNotifyOnEntry: region.notifyOnEntry,
                locationNotifyOnExit: region.notifyOnExit
            )
        #endif
        }
    }
    
    public func toNotificationTrigger() throws -> NotificationTrigger {
        switch type {
        case "timeInterval":
            guard let timeInterval = timeInterval else {
                throw NotificationError.invalidContent(reason: "Missing time interval for timeInterval trigger")
            }
            return .timeInterval(timeInterval, repeats: repeats)
            
        case "date":
            guard let date = date else {
                throw NotificationError.invalidContent(reason: "Missing date for date trigger")
            }
            return .date(date, repeats: repeats)
            
        case "calendar":
            guard let dateComponents = dateComponents else {
                throw NotificationError.invalidContent(reason: "Missing date components for calendar trigger")
            }
            return .calendar(dateComponents: dateComponents, repeats: repeats)
            
        #if os(iOS)
        case "location":
            guard let latitude = locationLatitude,
                  let longitude = locationLongitude,
                  let radius = locationRadius,
                  let identifier = locationIdentifier else {
                throw NotificationError.invalidContent(reason: "Missing location data for location trigger")
            }
            
            let region = CLCircularRegion(
                center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                radius: radius,
                identifier: identifier
            )
            region.notifyOnEntry = locationNotifyOnEntry ?? true
            region.notifyOnExit = locationNotifyOnExit ?? false
            
            return .location(region: region, repeats: repeats)
        #endif
            
        default:
            throw NotificationError.invalidContent(reason: "Unknown trigger type: \(type)")
        }
    }
}