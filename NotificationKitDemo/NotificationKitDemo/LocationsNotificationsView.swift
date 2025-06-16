//
//  LocationsNotificationsView.swift
//  NotificationKitDemo
//
//  Created by Chon Torres on 6/16/25.
//

import SwiftUI
import CoreLocation

struct LocationNotificationsView: View {
    @EnvironmentObject var notificationManager: NotificationDemoManager
    @State private var latitude: String = "37.7749"
    @State private var longitude: String = "-122.4194"
    @State private var radius: String = "1000"
    @State private var locationTitle = "Location Alert"
    @State private var locationBody = "You've arrived at your destination!"

    var body: some View {
        NavigationView {
            Form {
                Section("Location Permission") {
                    LocationPermissionView()
                }

                if notificationManager.isLocationPermissionGranted && notificationManager.permissionStatus == .authorized {
                    Section("Preset Locations") {
                        PresetLocationButtons()
                    }

                    Section("Custom Location") {
                        CustomLocationControls(
                            latitude: $latitude,
                            longitude: $longitude,
                            radius: $radius,
                            locationTitle: $locationTitle,
                            locationBody: $locationBody
                        )
                    }
                } else {
                    Section {
                        Text("Location and notification permissions are required for location-based notifications.")
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }

                if !notificationManager.statusMessage.isEmpty {
                    Section {
                        Text(notificationManager.statusMessage)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Location")
        }
    }
}

struct LocationPermissionView: View {
    @EnvironmentObject var notificationManager: NotificationDemoManager

    var body: some View {
        HStack {
            Image(systemName: notificationManager.isLocationPermissionGranted ? "location.fill" : "location.slash")
                .foregroundColor(notificationManager.isLocationPermissionGranted ? .green : .red)

            VStack(alignment: .leading) {
                Text("Location Access")
                    .font(.headline)
                Text(notificationManager.isLocationPermissionGranted ? "Granted" : "Required for location notifications")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if !notificationManager.isLocationPermissionGranted {
                Button("Request Permission") {
                    notificationManager.requestLocationPermission()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

struct PresetLocationButtons: View {
    @EnvironmentObject var notificationManager: NotificationDemoManager

    let presetLocations = [
        ("Apple Park", 37.3349, -122.0090, 500.0),
        ("Golden Gate Bridge", 37.8199, -122.4783, 200.0),
        ("Times Square", 40.7580, -73.9855, 100.0),
        ("Eiffel Tower", 48.8584, 2.2945, 150.0)
    ]

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            ForEach(presetLocations, id: \.0) { location in
                Button(location.0) {
                    Task {
                        await notificationManager.scheduleLocationNotification(
                            latitude: location.1,
                            longitude: location.2,
                            radius: location.3,
                            title: "Welcome to \(location.0)!",
                            body: "You've arrived at a famous landmark."
                        )
                    }
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

struct CustomLocationControls: View {
    @EnvironmentObject var notificationManager: NotificationDemoManager
    @Binding var latitude: String
    @Binding var longitude: String
    @Binding var radius: String
    @Binding var locationTitle: String
    @Binding var locationBody: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                TextField("Latitude", text: $latitude)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)

                TextField("Longitude", text: $longitude)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
            }

            TextField("Radius (meters)", text: $radius)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)

            TextField("Notification Title", text: $locationTitle)
                .textFieldStyle(.roundedBorder)

            TextField("Notification Body", text: $locationBody, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...4)

            Button("Schedule Location Notification") {
                guard let lat = Double(latitude),
                      let lon = Double(longitude),
                      let rad = Double(radius) else {
                    notificationManager.statusMessage = "❌ Invalid coordinates or radius"
                    return
                }

                Task {
                    await notificationManager.scheduleLocationNotification(
                        latitude: lat,
                        longitude: lon,
                        radius: rad,
                        title: locationTitle,
                        body: locationBody
                    )
                }
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
        }
    }
}
