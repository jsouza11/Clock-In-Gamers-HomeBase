//
//  NotificationCenterStorage.swift
//  Clock-In-Gamers
//
//  Created by Jake Souza on 4/30/25.
//

import Foundation

class NotificationCenterStorage: ObservableObject {
    static let shared = NotificationCenterStorage()

    @Published var upcomingEvents: [Event] = []

    func addEvent(_ event: Event) {
        upcomingEvents.append(event)
    }

    func clearEvents() {
        upcomingEvents.removeAll()
    }
}
