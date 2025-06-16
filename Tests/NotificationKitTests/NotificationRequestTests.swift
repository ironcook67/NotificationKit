//
//  File.swift
//  NotificationKit
//
//  Created by Chon Torres on 6/13/25.
//

import XCTest
@testable import NotificationKit
@preconcurrency import UserNotifications

/// Test suite for NotificationRequest functionality.
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 10.0, visionOS 2.0, *)
final class NotificationRequestTests: XCTestCase {

    func testBasicNotificationRequest() {
        let request = NotificationRequest(
            id: "test-1",
            title: "Test Title",
            body: "Test Body"
        )

        XCTAssertEqual(request.id, "test-1")
        XCTAssertEqual(request.title, "Test Title")
        XCTAssertEqual(request.body, "Test Body")
        XCTAssertNil(request.subtitle)
        XCTAssertNil(request.trigger)
    }

    func testNotificationRequestWithAllProperties() {
        let trigger = NotificationTrigger.timeInterval(60, repeats: false)
        let userInfo = ["key": "value"]

        let request = NotificationRequest(
            id: "test-2",
            title: "Full Test",
            body: "Test Body",
            subtitle: "Test Subtitle",
            trigger: trigger,
            badge: NSNumber(value: 5),
            sound: .default,
            categoryIdentifier: "test-category",
            userInfo: userInfo,
            threadIdentifier: "test-thread"
        )

        XCTAssertEqual(request.id, "test-2")
        XCTAssertEqual(request.title, "Full Test")
        XCTAssertEqual(request.body, "Test Body")
        XCTAssertEqual(request.subtitle, "Test Subtitle")
        XCTAssertNotNil(request.trigger)
        XCTAssertEqual(request.badge, NSNumber(value: 5))
        XCTAssertEqual(request.categoryIdentifier, "test-category")
        XCTAssertEqual(request.threadIdentifier, "test-thread")
    }

    func testUNNotificationRequestConversion() {
        let request = NotificationRequest(
            id: "conversion-test",
            title: "Conversion Title",
            body: "Conversion Body"
        )

        let unRequest = request.toUNNotificationRequest()

        XCTAssertEqual(unRequest.identifier, "conversion-test")
        XCTAssertEqual(unRequest.content.title, "Conversion Title")
        XCTAssertEqual(unRequest.content.body, "Conversion Body")
        XCTAssertNil(unRequest.trigger)
    }
}
