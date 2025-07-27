//
//  NotificationTriggerTests.swift
//  NotificationKit
//
//  Created by Chon Torres on 6/13/25.
//

import XCTest
@testable import NotificationKit
@preconcurrency import UserNotifications
#if os(iOS)
@preconcurrency import CoreLocation
#endif

/// Test suite for NotificationTrigger functionality.
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 10.0, visionOS 2.0, *)
final class NotificationTriggerTests: XCTestCase {

    func testTimeIntervalTrigger() {
        let trigger = NotificationTrigger.timeInterval(60, repeats: false)
        let unTrigger = trigger.toUNNotificationTrigger()

        XCTAssertTrue(unTrigger is UNTimeIntervalNotificationTrigger)

        if let timeIntervalTrigger = unTrigger as? UNTimeIntervalNotificationTrigger {
            XCTAssertEqual(timeIntervalTrigger.timeInterval, 60)
            XCTAssertFalse(timeIntervalTrigger.repeats)
        }
    }

    func testDateTrigger() {
        let date = Date(timeIntervalSinceNow: 3600) // 1 hour from now
        let trigger = NotificationTrigger.date(date, repeats: false)
        let unTrigger = trigger.toUNNotificationTrigger()

        XCTAssertTrue(unTrigger is UNCalendarNotificationTrigger)

        if let calendarTrigger = unTrigger as? UNCalendarNotificationTrigger {
            XCTAssertFalse(calendarTrigger.repeats)
        }
    }

    func testCalendarTrigger() {
        var components = DateComponents()
        components.hour = 9
        components.minute = 0

        let trigger = NotificationTrigger.calendar(dateComponents: components, repeats: true)
        let unTrigger = trigger.toUNNotificationTrigger()

        XCTAssertTrue(unTrigger is UNCalendarNotificationTrigger)

        if let calendarTrigger = unTrigger as? UNCalendarNotificationTrigger {
            XCTAssertTrue(calendarTrigger.repeats)
            XCTAssertEqual(calendarTrigger.dateComponents.hour, 9)
            XCTAssertEqual(calendarTrigger.dateComponents.minute, 0)
        }
    }

    func testLocationTrigger() {
#if os(iOS)
        let region = CLCircularRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            radius: 1000,
            identifier: "test-region"
        )

        let trigger = NotificationTrigger.location(region: region, repeats: false)
        let unTrigger = trigger.toUNNotificationTrigger()

        XCTAssertTrue(unTrigger is UNLocationNotificationTrigger)

        if let locationTrigger = unTrigger as? UNLocationNotificationTrigger,
           let circularRegion = locationTrigger.region as? CLCircularRegion {
            XCTAssertFalse(locationTrigger.repeats)
            XCTAssertEqual(circularRegion.center.latitude, 37.7749, accuracy: 0.0001)
            XCTAssertEqual(circularRegion.center.longitude, -122.4194, accuracy: 0.0001)
            XCTAssertEqual(circularRegion.radius, 1000, accuracy: 0.1)
            XCTAssertEqual(circularRegion.identifier, "test-region")
        }
#endif
    }
}
