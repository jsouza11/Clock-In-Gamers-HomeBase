//
//  Home.swift
//  Clock-In-Gamers
//
//  Created by Jake Souza on 4/24/25.
//

import SwiftUI

struct Home: View {
    // Methods for clock-in and clock-out actions
    @State var isClockedIn: Bool = false
    @EnvironmentObject var appData: AppData
    
    private func clockIn() {
        isClockedIn = true
        // No need to update user statuses
    }

    private func clockOut() {
        isClockedIn = false
        // No need to update user statuses
    }

    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack {
                    // Top Greeting Message
                    VStack(alignment: .leading, spacing: 10) {
                        Text(isClockedIn ? "Good day gamer, time to clock in" : "Good day gamer, time to clock out")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top, 20)
                        
                        if isClockedIn {
                            Text("Let's see your stats for today.")
                                .font(.subheadline)
                        } else {
                            Text("Ready to start another gaming session?")
                                .font(.subheadline)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Top Widget
                    TopWidgetView(isClockedIn: $isClockedIn, clockIn: clockIn, clockOut: clockOut)
                    
                    // User List Header
                    HStack {
                        VStack {
                            Text("Friend List")
                                .foregroundColor(.white)
                                .font(.title)
                                .padding()
                        }
                        Spacer()
                    }
                    .padding()

                    // Divider between two stacks
                    Divider()
                        .background(Color.white)
                        .padding(.horizontal)

                    // Scrollable User List
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(appData.allUsers) { user in
                                NavigationLink(destination: UserDetailView(user: user)) {
                                    UserRowView(user: user)
                                        .padding(.horizontal)
                                }
                            }
                        }
                        .padding()
                    }

                    Spacer()
                }
                .background(Color.black.edgesIgnoringSafeArea(.all))
                .onAppear {
                    // Ensuring the first user is always clocked in at the start
                    if let firstUser = appData.allUsers.first {
                        if firstUser.name == "Frank" {
                            firstUser.isClockedIn = true
                            if firstUser.clockedInAt == nil {
                                firstUser.clockedInAt = Date()
                            }
                        }
                    }
                }
            }
            .modifier(MainBackground())
        }
    }
}

#Preview {
    Home()
}
