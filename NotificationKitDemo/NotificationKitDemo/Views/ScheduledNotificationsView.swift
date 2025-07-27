//
//  ScheduledNotificationsView.swift
//  NotificationKitDemo
//
//  Created by Chon Torres on 6/16/25.
//

import SwiftUI

struct ScheduleNotificationsView: View {
    @EnvironmentObject var notificationManager: NotificationDemoManager
    @State private var timeInterval: Double = 5
    @State private var customTitle = "Test Notification"
    @State private var customBody = "This is a test notification from NotificationKit!"
    @State private var selectedHour = 9
    @State private var selectedMinute = 0

    var body: some View {
        NavigationView {
            Form {
                Section("Permission Status") {
                    PermissionStatusView()
                }

                if notificationManager.permissionStatus == .authorized {
                    Section("Quick Actions") {
                        QuickNotificationButtons()
                    }

                    Section("Time-Based Notifications") {
                        TimeBasedNotificationControls(
                            timeInterval: $timeInterval,
                            customTitle: $customTitle,
                            customBody: $customBody
                        )
                    }

                    Section("Daily Notifications") {
                        DailyNotificationControls(
                            selectedHour: $selectedHour,
                            selectedMinute: $selectedMinute,
                            customTitle: $customTitle,
                            customBody: $customBody
                        )
                    }
                }

                if !notificationManager.statusMessage.isEmpty {
                    Section {
                        Text(notificationManager.statusMessage)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Schedule")
        }
    }
}

struct PermissionStatusView: View {
    @EnvironmentObject var notificationManager: NotificationDemoManager

    var body: some View {
        HStack {
            Image(systemName: statusIcon)
                .foregroundColor(statusColor)

            VStack(alignment: .leading) {
                Text("Notifications")
                    .font(.headline)
                Text(statusText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if notificationManager.permissionStatus != .authorized {
                Button("Request Permission") {
                    Task {
                        await notificationManager.requestPermission()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private var statusIcon: String {
        switch notificationManager.permissionStatus {
        case .authorized:
            return "checkmark.circle.fill"
        case .denied:
            return "xmark.circle.fill"
        case .notDetermined:
            return "questionmark.circle.fill"
        case .provisional, .ephemeral:
            return "clock.circle.fill"
        @unknown default:
            return "questionmark.circle.fill"
        }
    }

    private var statusColor: Color {
        switch notificationManager.permissionStatus {
        case .authorized:
            return .green
        case .denied:
            return .red
        case .notDetermined:
            return .orange
        case .provisional, .ephemeral:
            return .blue
        @unknown default:
            return .gray
        }
    }

    private var statusText: String {
        switch notificationManager.permissionStatus {
        case .authorized:
            return "Granted - Ready to send notifications"
        case .denied:
            return "Denied - Enable in Settings"
        case .notDetermined:
            return "Not requested yet"
        case .provisional:
            return "Provisional - Limited notifications"
        case .ephemeral:
            return "Ephemeral - Temporary access"
        @unknown default:
            return "Unknown status"
        }
    }
}

struct QuickNotificationButtons: View {
    @EnvironmentObject var notificationManager: NotificationDemoManager

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button("5 seconds") {
                    Task {
                        await notificationManager.scheduleTimeIntervalNotification(
                            seconds: 5,
                            title: "Quick Test",
                            body: "This notification was scheduled 5 seconds ago!"
                        )
                    }
                }
                .buttonStyle(.bordered)

                Button("30 seconds") {
                    Task {
                        await notificationManager.scheduleTimeIntervalNotification(
                            seconds: 30,
                            title: "Half Minute Test",
                            body: "This notification was scheduled 30 seconds ago!"
                        )
                    }
                }
                .buttonStyle(.bordered)
            }

            Button("2 minutes") {
                Task {
                    await notificationManager.scheduleTimeIntervalNotification(
                        seconds: 120,
                        title: "Two Minute Test",
                        body: "This notification was scheduled 2 minutes ago!"
                    )
                }
            }
            .buttonStyle(.bordered)
        }
    }
}

struct TimeBasedNotificationControls: View {
    @EnvironmentObject var notificationManager: NotificationDemoManager
    @Binding var timeInterval: Double
    @Binding var customTitle: String
    @Binding var customBody: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Custom Time Interval: \(Int(timeInterval)) seconds")
                .font(.headline)

            Slider(value: $timeInterval, in: 1...300, step: 1) {
                Text("Time Interval")
            }
            .accentColor(.blue)

            TextField("Notification Title", text: $customTitle)
                .textFieldStyle(.roundedBorder)

            TextField("Notification Body", text: $customBody, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...4)

            Button("Schedule Custom Notification") {
                Task {
                    await notificationManager.scheduleTimeIntervalNotification(
                        seconds: timeInterval,
                        title: customTitle,
                        body: customBody
                    )
                }
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
        }
    }
}

struct DailyNotificationControls: View {
    @EnvironmentObject var notificationManager: NotificationDemoManager
    @Binding var selectedHour: Int
    @Binding var selectedMinute: Int
    @Binding var customTitle: String
    @Binding var customBody: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Notification Time")
                .font(.headline)

            HStack {
                Picker("Hour", selection: $selectedHour) {
                    ForEach(0..<24, id: \.self) { hour in
                        Text("\(hour):00").tag(hour)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)

                Picker("Minute", selection: $selectedMinute) {
                    ForEach([0, 15, 30, 45], id: \.self) { minute in
                        Text(":\(String(format: "%02d", minute))").tag(minute)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
            }
            .frame(height: 120)

            Button("Schedule Daily Notification") {
                Task {
                    await notificationManager.scheduleDailyNotification(
                        hour: selectedHour,
                        minute: selectedMinute,
                        title: customTitle,
                        body: customBody
                    )
                }
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
        }
    }
}
