//
//  UserDetailView.swift
//  Clock-In-Gamers
//
//  Created by Jake Souza on 4/24/25.
//

import SwiftUI

struct UserDetailView: View {
    @ObservedObject var user: User
    @State private var currentTime = Date()
    
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text("User Information")
                        .font(.largeTitle)
                        .padding()
                }
            }
            Spacer()
            HStack {
                VStack(spacing: 20) {
                    Text("Name: \(user.name)")
                        .font(.title)
                    Text("Status: \(user.isClockedIn ? "Clocked In" : "Clocked Out")")
                        .font(.title)
                    if let lastClockIn = user.clockedInAt {
                        if user.isClockedIn {
                            let duration = currentTime.timeIntervalSince(lastClockIn)
                            let minutes = Int(duration) / 60
                            let seconds = Int(duration) % 60
                            Text("Clocked in for: \(String(format: "%02d:%02d", minutes, seconds))")
                                .font(.title)
                        } else {
                            let duration = currentTime.timeIntervalSince(lastClockIn)
                            let minutes = Int(duration) / 60
                            if minutes > 0 {
                                Text("Last clocked in: \(minutes) minutes ago")
                                    .font(.title)
                            } else {
                                Text("Last clocked in: <1 minute ago")
                                    .font(.title)
                            }
                        }
                    }
                }
            }
            Spacer()
        }
        .navigationBarTitle(Text(user.name), displayMode: .inline)
        .onAppear {
            // Ensure Frank is always clocked in and the timer runs
            if user.name == "Frank" {
                user.isClockedIn = true
                if user.clockedInAt == nil {
                    user.clockedInAt = Date()
                }
            }
        }
        .onReceive(timer) { input in
            if user.name == "Frank" {
                currentTime = input
            }
        }
    }
}
