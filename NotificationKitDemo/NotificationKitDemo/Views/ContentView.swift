//
//  ContentView.swift
//  NotificationKitDemo
//
//  Created by Chon Torres on 6/16/25.
//

import SwiftUI
import NotificationKit

struct ContentView: View {
    @EnvironmentObject var notificationManager: NotificationDemoManager
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ScheduleNotificationsView()
                .tabItem {
                    Image(systemName: "bell.badge.fill")
                    Text("Schedule")
                }
                .tag(0)

            ManageNotificationsView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Manage")
                }
                .tag(1)

            LocationNotificationsView()
                .tabItem {
                    Image(systemName: "location.fill")
                    Text("Location")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(3)
        }
        .navigationTitle("NotificationKit Demo")
    }
}

