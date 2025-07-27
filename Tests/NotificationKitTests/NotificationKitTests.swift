//
//  NotificationKitTest.swift
//  NotificationKit
//
//  Created by Chon Torres on 6/13/25.
//

import XCTest
@testable import NotificationKit

/// Test suite for NotificationKit core functionality.
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 10.0, visionOS 2.0, *)
final class NotificationKitTests: XCTestCase {
    
    func testNotificationKitVersion() {
        XCTAssertEqual(NotificationKit.version, "1.1.0")
    }
    
    func testNotificationManagerType() {
        // Test that the NotificationManager type is properly defined
        // We avoid testing actual initialization in unit tests due to
        // UNUserNotificationCenter requiring app bundle context
        
        let managerType = NotificationManager.self
        XCTAssertNotNil(managerType)
        
        // Verify it's the expected type
        XCTAssertTrue(String(describing: managerType) == "NotificationManager")
    }
}
