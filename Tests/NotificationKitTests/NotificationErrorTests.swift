//
//  NotificationErrorTest.swift
//  NotificationKit
//
//  Created by Chon Torres on 6/13/25.
//

import XCTest
@testable import NotificationKit

/// Test suite for NotificationError functionality.
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 10.0, visionOS 2.0, *)
final class NotificationErrorTests: XCTestCase {

    func testPermissionDeniedError() {
        let error = NotificationError.permissionDenied

        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("Permission") == true)
        XCTAssertNotNil(error.failureReason)
    }

    func testSchedulingFailedError() {
        let underlyingError = NSError(domain: "TestDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        let error = NotificationError.schedulingFailed(underlyingError)

        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("Failed to schedule") == true)
        XCTAssertNotNil(error.failureReason)
    }

    func testInvalidContentError() {
        let error = NotificationError.invalidContent(reason: "Title is empty")

        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("Invalid notification content") == true)
        XCTAssertTrue(error.errorDescription?.contains("Title is empty") == true)
    }

    func testInvalidTriggerError() {
        let error = NotificationError.invalidTrigger(reason: "Date is in the past")

        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("Invalid notification trigger") == true)
        XCTAssertTrue(error.errorDescription?.contains("Date is in the past") == true)
    }
    
    func testPersistenceSetupFailedError() {
        let underlyingError = NSError(domain: "PersistenceDomain", code: 2, userInfo: [NSLocalizedDescriptionKey: "Database setup failed"])
        let error = NotificationError.persistenceSetupFailed(underlyingError)

        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("Failed to setup notification persistence") == true)
        XCTAssertTrue(error.errorDescription?.contains("Database setup failed") == true)
        XCTAssertNotNil(error.failureReason)
        XCTAssertTrue(error.failureReason?.contains("could not be initialized") == true)
    }
    
    func testPersistenceOperationFailedError() {
        let underlyingError = NSError(domain: "PersistenceDomain", code: 3, userInfo: [NSLocalizedDescriptionKey: "Save operation failed"])
        let error = NotificationError.persistenceOperationFailed(underlyingError)

        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("Notification persistence operation failed") == true)
        XCTAssertTrue(error.errorDescription?.contains("Save operation failed") == true)
        XCTAssertNotNil(error.failureReason)
        XCTAssertTrue(error.failureReason?.contains("could not be completed") == true)
    }
}
