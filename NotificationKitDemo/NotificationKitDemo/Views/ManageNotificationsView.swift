//
//  ManageNotificationsView.swift
//  NotificationKitDemo
//
//  Created by Chon Torres on 6/16/25.
//

import SwiftUI

struct ManageNotificationsView: View {
    @EnvironmentObject var notificationManager: NotificationDemoManager

    var body: some View {
        NavigationView {
            List {
                Section("Pending Notifications (\(notificationManager.pendingNotifications.count))") {
                    if notificationManager.pendingNotifications.isEmpty {
                        Text("No pending notifications")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        ForEach(notificationManager.pendingNotifications, id: \.identifier) { notification in
                            PendingNotificationRow(notification: notification)
                        }
                    }

                    if !notificationManager.pendingNotifications.isEmpty {
                        Button("Cancel All Pending") {
                            notificationManager.cancelAllNotifications()
                        }
                        .foregroundColor(.red)
                    }
                }

                Section("Delivered Notifications (\(notificationManager.deliveredNotifications.count))") {
                    if notificationManager.deliveredNotifications.isEmpty {
                        Text("No delivered notifications")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        ForEach(notificationManager.deliveredNotifications, id: \.request.identifier) { notification in
                            DeliveredNotificationRow(notification: notification)
                        }
                    }

                    if !notificationManager.deliveredNotifications.isEmpty {
                        Button("Clear All Delivered") {
                            notificationManager.removeAllDeliveredNotifications()
                        }
                        .foregroundColor(.red)
                    }
                }

                if !notificationManager.statusMessage.isEmpty {
                    Section {
                        Text(notificationManager.statusMessage)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Manage")
            .refreshable {
                await notificationManager.refreshNotifications()
            }
        }
    }
}

struct PendingNotificationRow: View {
    @EnvironmentObject var notificationManager: NotificationDemoManager
    let notification: UNNotificationRequest

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading) {
                    Text(notification.content.title)
                        .font(.headline)

                    if !notification.content.body.isEmpty {
                        Text(notification.content.body)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }

                Spacer()

                Button("Cancel") {
                    notificationManager.cancelNotification(withId: notification.identifier)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }

            HStack {
                Image(systemName: triggerIcon)
                    .foregroundColor(.blue)
                Text(triggerDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    private var triggerIcon: String {
        if let trigger = notification.trigger {
            switch trigger {
            case is UNTimeIntervalNotificationTrigger:
                return "clock"
            case is UNCalendarNotificationTrigger:
                return "calendar"
            case is UNLocationNotificationTrigger:
                return "location"
            default:
                return "bell"
            }
        }
        return "bell"
    }

    private var triggerDescription: String {
        guard let trigger = notification.trigger else {
            return "Immediate"
        }

        switch trigger {
        case let timeInterval as UNTimeIntervalNotificationTrigger:
            let interval = Int(timeInterval.timeInterval)
            return "In \(interval) seconds" + (timeInterval.repeats ? " (repeating)" : "")

        case let calendar as UNCalendarNotificationTrigger:
            let components = calendar.dateComponents
            if let hour = components.hour, let minute = components.minute {
                return "Daily at \(hour):\(String(format: "%02d", minute))"
            }
            return "Calendar-based" + (calendar.repeats ? " (repeating)" : "")

        case let location as UNLocationNotificationTrigger:
            return "Location-based" + (location.repeats ? " (repeating)" : "")

        default:
            return "Unknown trigger"
        }
    }
}

struct DeliveredNotificationRow: View {
    @EnvironmentObject var notificationManager: NotificationDemoManager
    let notification: UNNotification

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading) {
                    Text(notification.request.content.title)
                        .font(.headline)

                    if !notification.request.content.body.isEmpty {
                        Text(notification.request.content.body)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }

                Spacer()

                Button("Remove") {
                    notificationManager.removeDeliveredNotification(withId: notification.request.identifier)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }

            Text("Delivered: \(notification.date.formatted(.dateTime.hour().minute()))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}

