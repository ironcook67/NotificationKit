//
//  NotificationStatusTests.swift
//  NotificationKitTests
//
//  Created by Claude Code on 7/27/25.
//

import XCTest
@testable import NotificationKit

/// Test suite for NotificationStatus functionality.
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 10.0, visionOS 2.0, *)
final class NotificationStatusTests: XCTestCase {

    func testNotificationStatusRawValues() {
        XCTAssertEqual(NotificationStatus.created.rawValue, "created")
        XCTAssertEqual(NotificationStatus.scheduled.rawValue, "scheduled")
        XCTAssertEqual(NotificationStatus.delivered.rawValue, "delivered")
        XCTAssertEqual(NotificationStatus.cancelled.rawValue, "cancelled")
        XCTAssertEqual(NotificationStatus.failed.rawValue, "failed")
    }
    
    func testNotificationStatusAllCases() {
        let allCases = NotificationStatus.allCases
        XCTAssertEqual(allCases.count, 5)
        XCTAssertTrue(allCases.contains(.created))
        XCTAssertTrue(allCases.contains(.scheduled))
        XCTAssertTrue(allCases.contains(.delivered))
        XCTAssertTrue(allCases.contains(.cancelled))
        XCTAssertTrue(allCases.contains(.failed))
    }
    
    func testNotificationStatusCodable() throws {
        let statuses: [NotificationStatus] = [.created, .scheduled, .delivered, .cancelled, .failed]
        
        for status in statuses {
            // Test encoding
            let encoded = try JSONEncoder().encode(status)
            XCTAssertFalse(encoded.isEmpty)
            
            // Test decoding
            let decoded = try JSONDecoder().decode(NotificationStatus.self, from: encoded)
            XCTAssertEqual(decoded, status)
        }
    }
    
    func testNotificationStatusFromRawValue() {
        XCTAssertEqual(NotificationStatus(rawValue: "created"), .created)
        XCTAssertEqual(NotificationStatus(rawValue: "scheduled"), .scheduled)
        XCTAssertEqual(NotificationStatus(rawValue: "delivered"), .delivered)
        XCTAssertEqual(NotificationStatus(rawValue: "cancelled"), .cancelled)
        XCTAssertEqual(NotificationStatus(rawValue: "failed"), .failed)
        XCTAssertNil(NotificationStatus(rawValue: "invalid"))
    }
    
    func testNotificationStatusEquality() {
        XCTAssertEqual(NotificationStatus.created, NotificationStatus.created)
        XCTAssertNotEqual(NotificationStatus.created, NotificationStatus.scheduled)
        XCTAssertNotEqual(NotificationStatus.delivered, NotificationStatus.cancelled)
    }
}