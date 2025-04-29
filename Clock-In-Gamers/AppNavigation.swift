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
                        .foregroundColor(.white)
                    Text("Profile")
                }
            Schedule()
                .tabItem {
                    Image(systemName: "calendar")
                        .animation(.bouncy)
                        .foregroundColor(.white)
                    Text("Schedule")
                }
        }
    }
}

#Preview {
    AppNavigation()
}
