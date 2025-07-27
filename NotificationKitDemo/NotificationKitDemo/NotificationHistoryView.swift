//
//  NotificationHistoryView.swift
//  NotificationKitDemo
//
//  Created by Claude Code on 7/27/25.
//

import SwiftUI
import NotificationKit

struct NotificationHistoryView: View {
    @ObservedObject var demoManager: NotificationDemoManager
    
    var body: some View {
        NavigationView {
            VStack {
                if demoManager.manager.isPersistenceEnabled {
                    List {
                        Section("Statistics") {
                            statisticsSection
                        }
                        
                        Section("Recent Notifications") {
                            historySection
                        }
                        
                        Section("Actions") {
                            cleanupSection
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "Persistence Disabled",
                        systemImage: "externaldrive.badge.xmark",
                        description: Text("Notification history requires persistence to be enabled.")
                    )
                }
            }
            .navigationTitle("Notification History")
            .refreshable {
                await demoManager.refreshNotifications()
            }
        }
    }
    
    @ViewBuilder
    private var statisticsSection: some View {
        ForEach(Array(demoManager.notificationStats.keys.sorted()), id: \.self) { key in
            HStack {
                Text(key.capitalized.replacingOccurrences(of: "_", with: " "))
                Spacer()
                Text("\(demoManager.notificationStats[key] ?? 0)")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private var historySection: some View {
        if demoManager.notificationHistory.isEmpty {
            Text("No notification history")
                .foregroundColor(.secondary)
                .italic()
        } else {
            ForEach(demoManager.notificationHistory, id: \.id) { notification in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(notification.title)
                            .font(.headline)
                        Spacer()
                        statusBadge(for: notification.status)
                    }
                    
                    if let body = notification.body {
                        Text(body)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        if let triggerType = notification.triggerType {
                            Label(triggerType, systemImage: triggerIcon(for: triggerType))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(notification.createdAt, style: .relative)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
    
    @ViewBuilder
    private var cleanupSection: some View {
        Button(action: {
            Task {
                await demoManager.cleanupOldNotifications()
            }
        }) {
            Label("Cleanup Old Notifications", systemImage: "trash")
        }
        .foregroundColor(.red)
    }
    
    private func statusBadge(for status: NotificationStatus) -> some View {
        Text(status.rawValue.capitalized)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(statusColor(for: status).opacity(0.2))
            .foregroundColor(statusColor(for: status))
            .cornerRadius(4)
    }
    
    private func statusColor(for status: NotificationStatus) -> Color {
        switch status {
        case .created:
            return .blue
        case .scheduled:
            return .orange
        case .delivered:
            return .green
        case .cancelled:
            return .gray
        case .failed:
            return .red
        }
    }
    
    private func triggerIcon(for triggerType: String) -> String {
        switch triggerType {
        case "timeInterval":
            return "clock"
        case "calendar":
            return "calendar"
        case "date":
            return "calendar.badge.clock"
        case "location":
            return "location"
        default:
            return "bell"
        }
    }
}

#Preview {
    NotificationHistoryView(demoManager: NotificationDemoManager())
}