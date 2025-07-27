//
//  SettingsView.swift
//  NotificationKitDemo
//
//  Created by Chon Torres on 6/16/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var notificationManager: NotificationDemoManager

    var body: some View {
        NavigationView {
            Form {
                Section("NotificationKit Demo") {
                    HStack {
                        Image(systemName: "bell.badge.waveform")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("NotificationKit")
                                .font(.headline)
                            Text("v1.1.0")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Section("Current Status") {
                    HStack {
                        Text("Notification Permission")
                        Spacer()
                        Text(permissionStatusText)
                            .foregroundColor(permissionStatusColor)
                    }

                    HStack {
                        Text("Location Permission")
                        Spacer()
                        Text(notificationManager.isLocationPermissionGranted ? "Granted" : "Not Granted")
                            .foregroundColor(notificationManager.isLocationPermissionGranted ? .green : .red)
                    }

                    HStack {
                        Text("Pending Notifications")
                        Spacer()
                        Text("\(notificationManager.pendingNotifications.count)")
                            .foregroundColor(.blue)
                    }

                    HStack {
                        Text("Delivered Notifications")
                        Spacer()
                        Text("\(notificationManager.deliveredNotifications.count)")
                            .foregroundColor(.green)
                    }
                }

                Section("Actions") {
                    Button("Refresh Status") {
                        Task {
                            await notificationManager.refreshNotifications()
                        }
                    }

                    Button("Open Settings") {
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsUrl)
                        }
                    }
                }

                Section("About") {
                    Text("This demo app showcases the features of NotificationKit, a comprehensive Swift Package for managing notifications across Apple platforms.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("Features demonstrated:")
                        .font(.caption)
                        .fontWeight(.semibold)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("• Time-based notifications")
                        Text("• Calendar-based notifications")
                        Text("• Location-based notifications (iOS)")
                        Text("• Notification management")
                        Text("• Permission handling")
                        Text("• Real-time status updates")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }

    private var permissionStatusText: String {
        switch notificationManager.permissionStatus {
        case .authorized: return "Granted"
        case .denied: return "Denied"
        case .notDetermined: return "Not Requested"
        case .provisional: return "Provisional"
        case .ephemeral: return "Ephemeral"
        @unknown default: return "Unknown"
        }
    }

    private var permissionStatusColor: Color {
        switch notificationManager.permissionStatus {
        case .authorized: return .green
        case .denied: return .red
        case .notDetermined: return .orange
        case .provisional, .ephemeral: return .blue
        @unknown default: return .gray
        }
    }
}
