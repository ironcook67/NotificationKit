//
//  PersistentTriggerDataTests.swift
//  NotificationKitTests
//
//  Created by Claude Code on 7/27/25.
//

import XCTest
@testable import NotificationKit
#if os(iOS)
@preconcurrency import CoreLocation
#endif

/// Test suite for PersistentTriggerData functionality.
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 10.0, visionOS 2.0, *)
final class PersistentTriggerDataTests: XCTestCase {

    func testTimeIntervalTriggerSerialization() throws {
        let trigger = NotificationTrigger.timeInterval(300, repeats: true)
        let persistentData = PersistentTriggerData.from(trigger)
        
        XCTAssertEqual(persistentData.type, "timeInterval")
        XCTAssertEqual(persistentData.timeInterval, 300)
        XCTAssertNil(persistentData.date)
        XCTAssertNil(persistentData.dateComponents)
        XCTAssertTrue(persistentData.repeats)
        
        // Test round-trip conversion
        let convertedTrigger = try persistentData.toNotificationTrigger()
        if case .timeInterval(let interval, let repeats) = convertedTrigger {
            XCTAssertEqual(interval, 300)
            XCTAssertTrue(repeats)
        } else {
            XCTFail("Expected timeInterval trigger")
        }
    }
    
    func testDateTriggerSerialization() throws {
        let testDate = Date()
        let trigger = NotificationTrigger.date(testDate, repeats: false)
        let persistentData = PersistentTriggerData.from(trigger)
        
        XCTAssertEqual(persistentData.type, "date")
        XCTAssertNil(persistentData.timeInterval)
        XCTAssertEqual(persistentData.date!.timeIntervalSince1970, testDate.timeIntervalSince1970, accuracy: 1.0)
        XCTAssertNil(persistentData.dateComponents)
        XCTAssertFalse(persistentData.repeats)
        
        // Test round-trip conversion
        let convertedTrigger = try persistentData.toNotificationTrigger()
        if case .date(let date, let repeats) = convertedTrigger {
            XCTAssertEqual(date.timeIntervalSince1970, testDate.timeIntervalSince1970, accuracy: 1.0)
            XCTAssertFalse(repeats)
        } else {
            XCTFail("Expected date trigger")
        }
    }
    
    func testCalendarTriggerSerialization() throws {
        var components = DateComponents()
        components.hour = 14
        components.minute = 30
        components.weekday = 2 // Monday
        
        let trigger = NotificationTrigger.calendar(dateComponents: components, repeats: true)
        let persistentData = PersistentTriggerData.from(trigger)
        
        XCTAssertEqual(persistentData.type, "calendar")
        XCTAssertNil(persistentData.timeInterval)
        XCTAssertNil(persistentData.date)
        XCTAssertNotNil(persistentData.dateComponents)
        XCTAssertEqual(persistentData.dateComponents?.hour, 14)
        XCTAssertEqual(persistentData.dateComponents?.minute, 30)
        XCTAssertEqual(persistentData.dateComponents?.weekday, 2)
        XCTAssertTrue(persistentData.repeats)
        
        // Test round-trip conversion
        let convertedTrigger = try persistentData.toNotificationTrigger()
        if case .calendar(let dateComponents, let repeats) = convertedTrigger {
            XCTAssertEqual(dateComponents.hour, 14)
            XCTAssertEqual(dateComponents.minute, 30)
            XCTAssertEqual(dateComponents.weekday, 2)
            XCTAssertTrue(repeats)
        } else {
            XCTFail("Expected calendar trigger")
        }
    }
    
    #if os(iOS)
    func testLocationTriggerSerialization() throws {
        let region = CLCircularRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            radius: 1000,
            identifier: "test-region"
        )
        region.notifyOnEntry = true
        region.notifyOnExit = false
        
        let trigger = NotificationTrigger.location(region: region, repeats: false)
        let persistentData = PersistentTriggerData.from(trigger)
        
        XCTAssertEqual(persistentData.type, "location")
        XCTAssertNil(persistentData.timeInterval)
        XCTAssertNil(persistentData.date)
        XCTAssertNil(persistentData.dateComponents)
        XCTAssertFalse(persistentData.repeats)
        XCTAssertEqual(persistentData.locationLatitude, 37.7749, accuracy: 0.0001)
        XCTAssertEqual(persistentData.locationLongitude, -122.4194, accuracy: 0.0001)
        XCTAssertEqual(persistentData.locationRadius, 1000)
        XCTAssertEqual(persistentData.locationIdentifier, "test-region")
        XCTAssertEqual(persistentData.locationNotifyOnEntry, true)
        XCTAssertEqual(persistentData.locationNotifyOnExit, false)
        
        // Test round-trip conversion
        let convertedTrigger = try persistentData.toNotificationTrigger()
        if case .location(let convertedRegion, let repeats) = convertedTrigger {
            XCTAssertEqual(convertedRegion.center.latitude, 37.7749, accuracy: 0.0001)
            XCTAssertEqual(convertedRegion.center.longitude, -122.4194, accuracy: 0.0001)
            XCTAssertEqual(convertedRegion.radius, 1000)
            XCTAssertEqual(convertedRegion.identifier, "test-region")
            XCTAssertTrue(convertedRegion.notifyOnEntry)
            XCTAssertFalse(convertedRegion.notifyOnExit)
            XCTAssertFalse(repeats)
        } else {
            XCTFail("Expected location trigger")
        }
    }
    #endif
    
    func testInvalidTriggerType() {
        #if os(iOS)
        let invalidPersistentData = PersistentTriggerData(
            type: "invalid",
            timeInterval: nil,
            date: nil,
            dateComponents: nil,
            repeats: false,
            locationLatitude: nil,
            locationLongitude: nil,
            locationRadius: nil,
            locationIdentifier: nil,
            locationNotifyOnEntry: nil,
            locationNotifyOnExit: nil
        )
        #else
        let invalidPersistentData = PersistentTriggerData(
            type: "invalid",
            timeInterval: nil,
            date: nil,
            dateComponents: nil,
            repeats: false
        )
        #endif
        
        XCTAssertThrowsError(try invalidPersistentData.toNotificationTrigger()) { error in
            if case NotificationError.invalidContent(let reason) = error {
                XCTAssertTrue(reason.contains("Unknown trigger type"))
            } else {
                XCTFail("Expected invalidContent error")
            }
        }
    }
    
    func testMissingTimeIntervalData() {
        #if os(iOS)
        let invalidPersistentData = PersistentTriggerData(
            type: "timeInterval",
            timeInterval: nil, // Missing required data
            date: nil,
            dateComponents: nil,
            repeats: false,
            locationLatitude: nil,
            locationLongitude: nil,
            locationRadius: nil,
            locationIdentifier: nil,
            locationNotifyOnEntry: nil,
            locationNotifyOnExit: nil
        )
        #else
        let invalidPersistentData = PersistentTriggerData(
            type: "timeInterval",
            timeInterval: nil, // Missing required data
            date: nil,
            dateComponents: nil,
            repeats: false
        )
        #endif
        
        XCTAssertThrowsError(try invalidPersistentData.toNotificationTrigger()) { error in
            if case NotificationError.invalidContent(let reason) = error {
                XCTAssertTrue(reason.contains("Missing time interval"))
            } else {
                XCTFail("Expected invalidContent error")
            }
        }
    }
    
    func testMissingDateData() {
        #if os(iOS)
        let invalidPersistentData = PersistentTriggerData(
            type: "date",
            timeInterval: nil,
            date: nil, // Missing required data
            dateComponents: nil,
            repeats: false,
            locationLatitude: nil,
            locationLongitude: nil,
            locationRadius: nil,
            locationIdentifier: nil,
            locationNotifyOnEntry: nil,
            locationNotifyOnExit: nil
        )
        #else
        let invalidPersistentData = PersistentTriggerData(
            type: "date",
            timeInterval: nil,
            date: nil, // Missing required data
            dateComponents: nil,
            repeats: false
        )
        #endif
        
        XCTAssertThrowsError(try invalidPersistentData.toNotificationTrigger()) { error in
            if case NotificationError.invalidContent(let reason) = error {
                XCTAssertTrue(reason.contains("Missing date"))
            } else {
                XCTFail("Expected invalidContent error")
            }
        }
    }
    
    func testMissingDateComponentsData() {
        #if os(iOS)
        let invalidPersistentData = PersistentTriggerData(
            type: "calendar",
            timeInterval: nil,
            date: nil,
            dateComponents: nil, // Missing required data
            repeats: false,
            locationLatitude: nil,
            locationLongitude: nil,
            locationRadius: nil,
            locationIdentifier: nil,
            locationNotifyOnEntry: nil,
            locationNotifyOnExit: nil
        )
        #else
        let invalidPersistentData = PersistentTriggerData(
            type: "calendar",
            timeInterval: nil,
            date: nil,
            dateComponents: nil, // Missing required data
            repeats: false
        )
        #endif
        
        XCTAssertThrowsError(try invalidPersistentData.toNotificationTrigger()) { error in
            if case NotificationError.invalidContent(let reason) = error {
                XCTAssertTrue(reason.contains("Missing date components"))
            } else {
                XCTFail("Expected invalidContent error")
            }
        }
    }
    
    #if os(iOS)
    func testMissingLocationData() {
        let invalidPersistentData = PersistentTriggerData(
            type: "location",
            timeInterval: nil,
            date: nil,
            dateComponents: nil,
            repeats: false,
            locationLatitude: nil, // Missing required data
            locationLongitude: -122.4194,
            locationRadius: 1000,
            locationIdentifier: "test",
            locationNotifyOnEntry: true,
            locationNotifyOnExit: false
        )
        
        XCTAssertThrowsError(try invalidPersistentData.toNotificationTrigger()) { error in
            if case NotificationError.invalidContent(let reason) = error {
                XCTAssertTrue(reason.contains("Missing location data"))
            } else {
                XCTFail("Expected invalidContent error")
            }
        }
    }
    #endif
}