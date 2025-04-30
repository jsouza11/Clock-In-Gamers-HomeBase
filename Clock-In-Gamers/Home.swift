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
    @EnvironmentObject var viewModel: AuthViewModel
    
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack {
                    
                    
                    VStack(alignment: .leading, spacing: 10) {
                        if let isClockedIn = viewModel.currentUser?.isClockedIn {
                            Text(isClockedIn ? "Good day gamer, time to clock in" : "Good day gamer, time to clock out")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.top, 20)
                                .foregroundColor(.white)
                            
                            Text(isClockedIn ? "Let's see your stats for today." : "Ready to start another gaming session?")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        } else {
                            Text("Loading user status...")
                                .font(.title3)
                                .foregroundColor(.gray)
                        }
                        if let user = viewModel.currentUser {
                            TopWidgetView(
                                isClockedIn: user.isClockedIn,
                                fullName: user.fullName
                            )
                            .environmentObject(viewModel)
                        } else {
                            ProgressView("Loading profile...")
                                .foregroundColor(.white)
                                .padding()
                        }
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Friends List")
                                    .foregroundColor(.white)
                                    .font(.title)
                                    .padding(.horizontal)
                            }
                            Spacer()
                        }
                        .padding(.top)
                        
                        Divider()
                            .background(Color.white)
                            .padding(.horizontal)
                        
                        ScrollView {
                            VStack(spacing: 20) {
                                // Mocked friend list for now (since allUsers isn't part of AuthViewModel)
                                let friends: [UserData] = [
                                    UserData(id: "1", fullName: "Alex Rivera", email: "alex@example.com", isClockedIn: true),
                                    UserData(id: "2", fullName: "Sam Lee", email: "sam@example.com", isClockedIn: true),
                                    UserData(id: "3", fullName: "Toni Patel", email: "toni@example.com", isClockedIn: true)
                                ]
                                
                                ForEach(friends) { user in
                                    UserRowView(user: user)
                                        .padding(.horizontal)
                                }
                            }
                            .padding()
                        }
                        
                        Spacer()
                    }
                    .background(Color.black.edgesIgnoringSafeArea(.all))
                    .onAppear {
                        Task {
                            await viewModel.fetchUser()
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
}

#Preview {
    Home()
        .environmentObject(AuthViewModel())
        .environmentObject(AppData())
}
