//
//  NotificationPersistenceManager.swift
//  NotificationKit
//
//  Created by Claude Code on 7/27/25.
//

import Foundation
import SwiftData
@preconcurrency import UserNotifications

/// Manages persistent storage of notification data using SwiftData.
///
/// `NotificationPersistenceManager` provides CRUD operations for notification requests,
/// tracks notification history, and enables analytics and reporting functionality.
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 10.0, visionOS 2.0, *)
public final class NotificationPersistenceManager: ObservableObject, @unchecked Sendable {
    
    /// The SwiftData model container.
    public let container: ModelContainer
    
    /// Creates a new persistence manager with a custom model container.
    ///
    /// - Parameter container: The SwiftData model container to use.
    public init(container: ModelContainer) {
        self.container = container
    }
    
    /// Gets the main model context for database operations.
    @MainActor
    public var context: ModelContext {
        container.mainContext
    }
    
    /// Creates a new persistence manager with default configuration.
    ///
    /// - Parameter inMemory: Whether to use in-memory storage (useful for testing).
    /// - Throws: `NotificationError.persistenceSetupFailed` if container creation fails.
    public convenience init(inMemory: Bool = false) throws {
        let schema = Schema([PersistentNotificationRequest.self])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )
        
        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            self.init(container: container)
        } catch {
            throw NotificationError.persistenceSetupFailed(error)
        }
    }
    
    // MARK: - Create Operations
    
    /// Saves a notification request to persistent storage.
    ///
    /// - Parameter request: The notification request to save.
    /// - Throws: `NotificationError.persistenceOperationFailed` if saving fails.
    public func save(_ request: NotificationRequest) async throws {
        try await MainActor.run {
            do {
                let persistentRequest = try PersistentNotificationRequest.from(request)
                context.insert(persistentRequest)
                try context.save()
            } catch {
                throw NotificationError.persistenceOperationFailed(error)
            }
        }
    }
    
    /// Saves multiple notification requests to persistent storage.
    ///
    /// - Parameter requests: The notification requests to save.
    /// - Throws: `NotificationError.persistenceOperationFailed` if saving fails.
    public func save(_ requests: [NotificationRequest]) async throws {
        try await MainActor.run {
            do {
                for request in requests {
                    let persistentRequest = try PersistentNotificationRequest.from(request)
                    context.insert(persistentRequest)
                }
                try context.save()
            } catch {
                throw NotificationError.persistenceOperationFailed(error)
            }
        }
    }
    
    // MARK: - Read Operations
    
    /// Retrieves a notification request by its identifier.
    ///
    /// - Parameter id: The unique identifier of the notification request.
    /// - Returns: The notification request if found, nil otherwise.
    /// - Throws: `NotificationError.persistenceOperationFailed` if retrieval fails.
    public func notificationRequest(withId id: String) async throws -> NotificationRequest? {
        try await MainActor.run {
            do {
                let descriptor = FetchDescriptor<PersistentNotificationRequest>(
                    predicate: #Predicate { $0.id == id }
                )
                let persistentRequests = try context.fetch(descriptor)
                return try persistentRequests.first?.toNotificationRequest()
            } catch {
                throw NotificationError.persistenceOperationFailed(error)
            }
        }
    }
    
    /// Retrieves all notification requests with optional filtering.
    ///
    /// - Parameters:
    ///   - status: Filter by notification status (optional).
    ///   - triggerType: Filter by trigger type (optional).
    ///   - limit: Maximum number of results (optional).
    /// - Returns: An array of notification requests.
    /// - Throws: `NotificationError.persistenceOperationFailed` if retrieval fails.
    public func notificationRequests(
        status: NotificationStatus? = nil,
        triggerType: String? = nil,
        limit: Int? = nil
    ) async throws -> [NotificationRequest] {
        try await MainActor.run {
            do {
                var descriptor = FetchDescriptor<PersistentNotificationRequest>()
                
                // Build predicate based on filters
                var predicates: [Predicate<PersistentNotificationRequest>] = []
                
                if let status = status {
                    let statusRawValue = status.rawValue
                    predicates.append(#Predicate<PersistentNotificationRequest> { request in
                        request.status.rawValue == statusRawValue
                    })
                }
                
                if let triggerType = triggerType {
                    predicates.append(#Predicate { $0.triggerType == triggerType })
                }
                
                if !predicates.isEmpty {
                    descriptor.predicate = predicates.reduce(into: predicates[0]) { result, predicate in
                        result = #Predicate<PersistentNotificationRequest> { request in
                            result.evaluate(request) && predicate.evaluate(request)
                        }
                    }
                }
                
                // Apply sorting (most recent first)
                descriptor.sortBy = [SortDescriptor(\.createdAt, order: .reverse)]
                
                // Apply limit
                if let limit = limit {
                    descriptor.fetchLimit = limit
                }
                
                let persistentRequests = try context.fetch(descriptor)
                return try persistentRequests.map { try $0.toNotificationRequest() }
            } catch {
                throw NotificationError.persistenceOperationFailed(error)
            }
        }
    }
    
    /// Retrieves notification history with detailed metadata.
    ///
    /// - Parameters:
    ///   - startDate: Start date for the history range (optional).
    ///   - endDate: End date for the history range (optional).
    ///   - limit: Maximum number of results (optional).
    /// - Returns: An array of persistent notification requests with full metadata.
    /// - Throws: `NotificationError.persistenceOperationFailed` if retrieval fails.
    public func notificationHistory(
        startDate: Date? = nil,
        endDate: Date? = nil,
        limit: Int? = nil
    ) async throws -> [PersistentNotificationRequest] {
        try await MainActor.run {
            do {
                var descriptor = FetchDescriptor<PersistentNotificationRequest>()
                
                // Build date range predicate
                var predicates: [Predicate<PersistentNotificationRequest>] = []
                
                if let startDate = startDate {
                    predicates.append(#Predicate { $0.createdAt >= startDate })
                }
                
                if let endDate = endDate {
                    predicates.append(#Predicate { $0.createdAt <= endDate })
                }
                
                if !predicates.isEmpty {
                    descriptor.predicate = predicates.reduce(into: predicates[0]) { result, predicate in
                        result = #Predicate<PersistentNotificationRequest> { request in
                            result.evaluate(request) && predicate.evaluate(request)
                        }
                    }
                }
                
                // Apply sorting (most recent first)
                descriptor.sortBy = [SortDescriptor(\.createdAt, order: .reverse)]
                
                // Apply limit
                if let limit = limit {
                    descriptor.fetchLimit = limit
                }
                
                return try context.fetch(descriptor)
            } catch {
                throw NotificationError.persistenceOperationFailed(error)
            }
        }
    }
    
    // MARK: - Update Operations
    
    /// Updates the status of a notification request.
    ///
    /// - Parameters:
    ///   - id: The unique identifier of the notification request.
    ///   - status: The new status.
    ///   - timestamp: The timestamp for the status change (defaults to current time).
    /// - Throws: `NotificationError.persistenceOperationFailed` if update fails.
    public func updateStatus(
        forNotificationWithId id: String,
        to status: NotificationStatus,
        at timestamp: Date = Date()
    ) async throws {
        try await MainActor.run {
            do {
                let descriptor = FetchDescriptor<PersistentNotificationRequest>(
                    predicate: #Predicate { $0.id == id }
                )
                let persistentRequests = try context.fetch(descriptor)
                
                guard let persistentRequest = persistentRequests.first else {
                    return // Request not found, nothing to update
                }
                
                persistentRequest.status = status
                
                // Update appropriate timestamp based on status
                switch status {
                case .scheduled:
                    persistentRequest.scheduledAt = timestamp
                case .delivered:
                    persistentRequest.deliveredAt = timestamp
                case .cancelled:
                    persistentRequest.cancelledAt = timestamp
                case .created, .failed:
                    break // No specific timestamp for these states
                }
                
                try context.save()
            } catch {
                throw NotificationError.persistenceOperationFailed(error)
            }
        }
    }
    
    /// Updates multiple notification statuses in a batch operation.
    ///
    /// - Parameters:
    ///   - ids: The unique identifiers of the notification requests.
    ///   - status: The new status.
    ///   - timestamp: The timestamp for the status change (defaults to current time).
    /// - Throws: `NotificationError.persistenceOperationFailed` if update fails.
    public func updateStatus(
        forNotificationsWithIds ids: [String],
        to status: NotificationStatus,
        at timestamp: Date = Date()
    ) async throws {
        do {
            for id in ids {
                try await updateStatus(forNotificationWithId: id, to: status, at: timestamp)
            }
        } catch {
            throw NotificationError.persistenceOperationFailed(error)
        }
    }
    
    // MARK: - Delete Operations
    
    /// Deletes a notification request from persistent storage.
    ///
    /// - Parameter id: The unique identifier of the notification request.
    /// - Throws: `NotificationError.persistenceOperationFailed` if deletion fails.
    public func delete(notificationWithId id: String) async throws {
        try await MainActor.run {
            do {
                let descriptor = FetchDescriptor<PersistentNotificationRequest>(
                    predicate: #Predicate { $0.id == id }
                )
                let persistentRequests = try context.fetch(descriptor)
                
                for request in persistentRequests {
                    context.delete(request)
                }
                
                try context.save()
            } catch {
                throw NotificationError.persistenceOperationFailed(error)
            }
        }
    }
    
    /// Deletes multiple notification requests from persistent storage.
    ///
    /// - Parameter ids: The unique identifiers of the notification requests.
    /// - Throws: `NotificationError.persistenceOperationFailed` if deletion fails.
    public func delete(notificationsWithIds ids: [String]) async throws {
        do {
            for id in ids {
                try await delete(notificationWithId: id)
            }
        } catch {
            throw NotificationError.persistenceOperationFailed(error)
        }
    }
    
    /// Deletes all notification requests with a specific status.
    ///
    /// - Parameter status: The status of notifications to delete.
    /// - Throws: `NotificationError.persistenceOperationFailed` if deletion fails.
    public func deleteAll(withStatus status: NotificationStatus) async throws {
        try await MainActor.run {
            do {
                let statusRawValue = status.rawValue
                let descriptor = FetchDescriptor<PersistentNotificationRequest>(
                    predicate: #Predicate<PersistentNotificationRequest> { request in
                        request.status.rawValue == statusRawValue
                    }
                )
                let persistentRequests = try context.fetch(descriptor)
                
                for request in persistentRequests {
                    context.delete(request)
                }
                
                try context.save()
            } catch {
                throw NotificationError.persistenceOperationFailed(error)
            }
        }
    }
    
    /// Deletes all notification requests older than a specified date.
    ///
    /// - Parameter date: The cutoff date. Notifications created before this date will be deleted.
    /// - Throws: `NotificationError.persistenceOperationFailed` if deletion fails.
    public func deleteAll(olderThan date: Date) async throws {
        try await MainActor.run {
            do {
                let descriptor = FetchDescriptor<PersistentNotificationRequest>(
                    predicate: #Predicate { $0.createdAt < date }
                )
                let persistentRequests = try context.fetch(descriptor)
                
                for request in persistentRequests {
                    context.delete(request)
                }
                
                try context.save()
            } catch {
                throw NotificationError.persistenceOperationFailed(error)
            }
        }
    }
    
    // MARK: - Analytics Operations
    
    /// Gets notification statistics for analytics.
    ///
    /// - Parameters:
    ///   - startDate: Start date for the statistics range (optional).
    ///   - endDate: End date for the statistics range (optional).
    /// - Returns: A dictionary with notification statistics.
    /// - Throws: `NotificationError.persistenceOperationFailed` if retrieval fails.
    public func notificationStatistics(
        startDate: Date? = nil,
        endDate: Date? = nil
    ) async throws -> [String: Int] {
        try await MainActor.run {
            do {
                var descriptor = FetchDescriptor<PersistentNotificationRequest>()
                
                // Build date range predicate
                var predicates: [Predicate<PersistentNotificationRequest>] = []
                
                if let startDate = startDate {
                    predicates.append(#Predicate { $0.createdAt >= startDate })
                }
                
                if let endDate = endDate {
                    predicates.append(#Predicate { $0.createdAt <= endDate })
                }
                
                if !predicates.isEmpty {
                    descriptor.predicate = predicates.reduce(into: predicates[0]) { result, predicate in
                        result = #Predicate<PersistentNotificationRequest> { request in
                            result.evaluate(request) && predicate.evaluate(request)
                        }
                    }
                }
                
                let requests = try context.fetch(descriptor)
                
                // Calculate statistics
                var stats: [String: Int] = [:]
                stats["total"] = requests.count
                
                for status in NotificationStatus.allCases {
                    let count = requests.filter { $0.status == status }.count
                    stats[status.rawValue] = count
                }
                
                // Count by trigger type
                let triggerTypes = Set(requests.compactMap { $0.triggerType })
                for triggerType in triggerTypes {
                    let count = requests.filter { $0.triggerType == triggerType }.count
                    stats["trigger_\(triggerType)"] = count
                }
                
                return stats
            } catch {
                throw NotificationError.persistenceOperationFailed(error)
            }
        }
    }
}