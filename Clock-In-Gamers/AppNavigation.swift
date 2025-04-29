//
//  AppNavigation.swift
//  Clock-In-Gamers
//
//  Created by Jake Souza on 4/24/25.
//

import SwiftUI

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
                            .animation(.bouncy)
                        Text("Home")
                    }
                ProfileView()
                    .tabItem {
                        Image(systemName: "person.circle")
                            .animation(.bouncy)
                        Text("Profile")
                    }
                Schedule()
                    .tabItem {
                        Image(systemName: "calendar")
                            .animation(.bouncy)
                        Text("Schedule")
                    }
                NotificationCenterView()
                    .tabItem {
                        Image(systemName: "bell")
                            .animation(.bouncy)
                        Text("Notifications")
                    }
            }
            .navigationTitle("Clock-In-Gamers") // Title on top
        }
    }
}

#Preview {
    AppNavigation()
}
