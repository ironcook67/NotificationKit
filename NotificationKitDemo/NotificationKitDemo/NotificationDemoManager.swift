//
//  NotificationDemoManager.swift
//  NotificationKitDemo
//
//  Created by Chon Torres on 6/16/25.
//

import Foundation
import NotificationKit
import UserNotifications
import CoreLocation

@MainActor
class NotificationDemoManager: NSObject, ObservableObject {
    @Published var permissionStatus: UNAuthorizationStatus = .notDetermined
    @Published var pendingNotifications: [UNNotificationRequest] = []
    @Published var deliveredNotifications: [UNNotification] = []
    @Published var statusMessage = ""
    @Published var isLocationPermissionGranted = false

    private let manager = NotificationManager()
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func initialize() async {
        await updatePermissionStatus()
        await refreshNotifications()
        setupNotificationDelegate()
    }

    func requestPermission() async {
        let granted = await manager.requestPermission([.alert, .sound, .badge])
        await updatePermissionStatus()

        if granted {
            statusMessage = "✅ Notification permission granted!"
        } else {
            statusMessage = "❌ Notification permission denied"
        }

        // Clear message after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.statusMessage = ""
        }
    }

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    private func updatePermissionStatus() async {
        permissionStatus = await manager.authorizationStatus()
    }

    func refreshNotifications() async {
        pendingNotifications = await manager.pendingNotificationRequests()
        deliveredNotifications = await manager.deliveredNotifications()
    }

    private func setupNotificationDelegate() {
        UNUserNotificationCenter.current().delegate = self
    }

    // MARK: - Notification Scheduling

    func scheduleTimeIntervalNotification(seconds: TimeInterval, title: String, body: String) async {
        do {
            let request = NotificationRequest(
                id: "time-\(UUID().uuidString)",
                title: title,
                body: body,
                trigger: .timeInterval(seconds),
                sound: .default
            )

            try await manager.schedule(request)
            await refreshNotifications()
            statusMessage = "⏰ Notification scheduled for \(Int(seconds)) seconds"
        } catch {
            statusMessage = "❌ Failed to schedule notification: \(error.localizedDescription)"
        }

        clearStatusAfterDelay()
    }

    func scheduleDailyNotification(hour: Int, minute: Int, title: String, body: String) async {
        do {
            var components = DateComponents()
            components.hour = hour
            components.minute = minute

            let request = NotificationRequest(
                id: "daily-\(hour)-\(minute)",
                title: title,
                body: body,
                trigger: .calendar(dateComponents: components, repeats: true),
                sound: .default
            )

            try await manager.schedule(request)
            await refreshNotifications()
            statusMessage = "📅 Daily notification scheduled for \(hour):\(String(format: "%02d", minute))"
        } catch {
            statusMessage = "❌ Failed to schedule daily notification: \(error.localizedDescription)"
        }

        clearStatusAfterDelay()
    }

    func scheduleLocationNotification(latitude: Double, longitude: Double, radius: Double, title: String, body: String) async {
#if os(iOS)
        do {
            let region = CLCircularRegion(
                center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                radius: radius,
                identifier: "location-\(UUID().uuidString)"
            )
            region.notifyOnEntry = true
            region.notifyOnExit = false

            let request = NotificationRequest(
                id: "location-\(UUID().uuidString)",
                title: title,
                body: body,
                trigger: .location(region: region),
                sound: .default
            )

            try await manager.schedule(request)
            await refreshNotifications()
            statusMessage = "📍 Location notification scheduled"
        } catch {
            statusMessage = "❌ Failed to schedule location notification: \(error.localizedDescription)"
        }
#else
        statusMessage = "❌ Location notifications only available on iOS"
#endif

        clearStatusAfterDelay()
    }

    // MARK: - Notification Management

    func cancelNotification(withId id: String) {
        manager.cancelPendingNotification(withIdentifier: id)
        Task {
            await refreshNotifications()
            statusMessage = "🗑️ Notification cancelled"
            clearStatusAfterDelay()
        }
    }

    func cancelAllNotifications() {
        manager.cancelAllPendingNotifications()
        Task {
            await refreshNotifications()
            statusMessage = "🗑️ All notifications cancelled"
            clearStatusAfterDelay()
        }
    }

    func removeDeliveredNotification(withId id: String) {
        manager.removeDeliveredNotifications(withIdentifiers: [id])
        Task {
            await refreshNotifications()
            statusMessage = "🧹 Delivered notification removed"
            clearStatusAfterDelay()
        }
    }

    func removeAllDeliveredNotifications() {
        manager.removeAllDeliveredNotifications()
        Task {
            await refreshNotifications()
            statusMessage = "🧹 All delivered notifications removed"
            clearStatusAfterDelay()
        }
    }

    private func clearStatusAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.statusMessage = ""
        }
    }
}

extension NotificationDemoManager: @preconcurrency CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.isLocationPermissionGranted = manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways
        }
    }
}

extension NotificationDemoManager: @preconcurrency UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notifications even when app is in foreground
        completionHandler([.alert, .sound, .badge])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification tap
        print("Notification tapped: \(response.notification.request.identifier)")
        Task {
            await refreshNotifications()
        }
        completionHandler()
    }
}


