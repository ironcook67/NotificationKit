//
//  NotificationKitDemoApp.swift
//  NotificationKitDemo
//
//  Created by Chon Torres on 6/16/25.
//

import SwiftUI
import NotificationKit

@main
struct NotificationKitDemoApp: App {
    @State private var notificationManager = NotificationDemoManager()

    var body: some Scene {

        WindowGroup {
            ContentView()
                .environmentObject(notificationManager)
                .task {
                    await notificationManager.initialize()
                }
        }
    }
}
