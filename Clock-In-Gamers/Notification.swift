//
//  Notification.swift
//  Clock-In-Gamers
//
//  Created by Celeste Jolie on 4/28/25.
//

import SwiftUI

struct NotificationCenterView: View {
    @StateObject private var storage = NotificationCenterStorage.shared

    var body: some View {
        NavigationStack {
            VStack {
                if storage.upcomingEvents.isEmpty {
                    Text("No upcoming reminders.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(storage.upcomingEvents) { event in
                            VStack(alignment: .leading, spacing: 5) {
                                Text(event.title)
                                    .font(.headline)
                                Text(event.date, style: .date)
                                    .font(.subheadline)
                                Text(event.date, style: .time)
                                    .font(.subheadline)
                            }
                            .padding(.vertical, 5)
                        }
                        .onDelete(perform: deleteEvent)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Notifications")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !storage.upcomingEvents.isEmpty {
                        Button("Clear All") {
                            clearAllEvents()
                        }
                    }
                }
            }
            .onAppear {
                storage.loadUpcomingEvents()
            }
        }
    }

    func deleteEvent(at offsets: IndexSet) {
        storage.deleteEvents(at: offsets)
    }

    func clearAllEvents() {
        storage.clearAll()
    }
}

// MARK: - Shared Storage Singleton

class NotificationCenterStorage: ObservableObject {
    static let shared = NotificationCenterStorage()
    
    @Published var allEvents: [Event] = []
    
    var upcomingEvents: [Event] {
        allEvents.filter { $0.date > Date() }
            .sorted { $0.date < $1.date }
    }

    private init() { }

    func loadUpcomingEvents() {
        // Already loaded in-memory for now
    }

    func addEvent(_ event: Event) {
        allEvents.append(event)
    }

    func deleteEvents(at offsets: IndexSet) {
        allEvents.remove(atOffsets: offsets)
    }

    func clearAll() {
        allEvents.removeAll()
    }
}

#Preview {
    NotificationCenterView()
}
