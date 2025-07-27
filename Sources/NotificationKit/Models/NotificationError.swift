//
//  NotificationError.swift
//  NotificationKit
//
//  Created by Chon Torres on 6/13/25.
//

import Foundation

/// Errors that can occur when working with notifications.
///
/// `NotificationError` provides detailed information about what went wrong
/// during notification operations, making it easier to handle and debug issues.
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 10.0, visionOS 2.0, *)
public enum NotificationError: Error, LocalizedError, Sendable {

    /// Permission to send notifications was denied by the user.
    case permissionDenied

    /// The notification request could not be scheduled.
    ///
    /// - Parameter underlyingError: The underlying system error that caused the failure.
    case schedulingFailed(Error)

    /// The notification content is invalid.
    ///
    /// - Parameter reason: A description of why the content is invalid.
    case invalidContent(reason: String)

    /// The notification trigger is invalid.
    ///
    /// - Parameter reason: A description of why the trigger is invalid.
    case invalidTrigger(reason: String)
    
    /// Persistence setup failed.
    ///
    /// - Parameter underlyingError: The underlying error that caused the failure.
    case persistenceSetupFailed(Error)
    
    /// A persistence operation failed.
    ///
    /// - Parameter underlyingError: The underlying error that caused the failure.
    case persistenceOperationFailed(Error)

    /// A user-friendly description of the error.
    public var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Permission to send notifications was denied. Please enable notifications in Settings."

        case .schedulingFailed(let error):
            return "Failed to schedule notification: \(error.localizedDescription)"

        case .invalidContent(let reason):
            return "Invalid notification content: \(reason)"

        case .invalidTrigger(let reason):
            return "Invalid notification trigger: \(reason)"
            
        case .persistenceSetupFailed(let error):
            return "Failed to setup notification persistence: \(error.localizedDescription)"
            
        case .persistenceOperationFailed(let error):
            return "Notification persistence operation failed: \(error.localizedDescription)"
        }
    }

    /// A more detailed description of the error for debugging.
    public var failureReason: String? {
        switch self {
        case .permissionDenied:
            return "The user has not granted permission to send notifications, or has revoked permission."

        case .schedulingFailed(let error):
            return "The system was unable to schedule the notification request. Underlying error: \(error)"

        case .invalidContent(let reason):
            return "The notification content does not meet system requirements: \(reason)"

        case .invalidTrigger(let reason):
            return "The notification trigger is not valid: \(reason)"
            
        case .persistenceSetupFailed(let error):
            return "The notification persistence system could not be initialized. Underlying error: \(error)"
            
        case .persistenceOperationFailed(let error):
            return "The notification persistence operation could not be completed. Underlying error: \(error)"
        }
    }
}
