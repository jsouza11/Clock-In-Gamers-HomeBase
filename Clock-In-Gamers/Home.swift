//
//  Home.swift
//  Clock-In-Gamers
//
//  Created by Jake Souza on 4/24/25.
//

import SwiftUI

struct Home: View {
    @State var isClockedIn: Bool = false
    @State private var showNotifications = false
    @EnvironmentObject var appData: AppData

    private func clockIn() {
        isClockedIn = true
    }

    private func clockOut() {
        isClockedIn = false
    }

    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(isClockedIn ? "Good day gamer, time to clock in" : "Good day gamer, time to clock out")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top, 20)
                            .foregroundColor(.white)

                        Text(isClockedIn ? "Let's see your stats for today." : "Ready to start another gaming session?")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)

                    TopWidgetView(isClockedIn: $isClockedIn, clockIn: clockIn, clockOut: clockOut)

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

                    Divider()
                        .background(Color.white)
                        .padding(.horizontal)

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
                    if let firstUser = appData.allUsers.first {
                        if firstUser.name == "Frank" {
                            firstUser.isClockedIn = true
                            if firstUser.clockedInAt == nil {
                                firstUser.clockedInAt = Date()
                            }
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showNotifications = true
                        }) {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "bell")
                                    .foregroundColor(.white)
                                    .font(.title2)

                                if !NotificationCenterStorage.shared.upcomingEvents.isEmpty {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 10, height: 10)
                                        .offset(x: 8, y: -8)
                                }
                            }
                        }
                    }
                }
                .sheet(isPresented: $showNotifications) {
                    NotificationCenterView()
                }
            }
            .modifier(MainBackground())
        }
    }
}

#Preview {
    Home()
        .environmentObject(AppData())
}

