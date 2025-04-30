//
//  AppNavigation.swift
//  Clock-In-Gamers
//
//  Created by Jake Souza on 4/24/25.
//

import SwiftUI

// Chatroom View
struct ChatroomView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.white)

                Text("Chatroom coming soon...")
                    .font(.title2)
                    .foregroundColor(.white)
            }
        }
    }
}

// App Navigation View
struct AppNavigation: View {
    init() {
        UITabBar.appearance().unselectedItemTintColor = UIColor.white
    }

    var body: some View {
        NavigationStack {
            TabView {
                Home()
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }

                ProfileView()
                    .tabItem {
                        Image(systemName: "person.circle")
                        Text("Profile")
                    }

                Schedule()
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Schedule")
                    }

                ChatroomView()
                    .tabItem {
                        Image(systemName: "bubble.left.and.bubble.right")
                        Text("Chatroom")
                    }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                }
            }
        }
    }
}

#Preview {
    AppNavigation()
}
