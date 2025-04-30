//
//  AppNavagation.swift
//  Clock-In-Gamers
//
//  Created by Jake Souza on 4/24/25.
//
import SwiftUI

struct AppNavigation: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var selectedTab = 0

    init() {
        UITabBar.appearance().unselectedItemTintColor = UIColor.white
    }

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                Home()
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                    .tag(0)

                ProfView()
                    .tabItem {
                        Image(systemName: "person.circle")
                        Text("Profile")
                    }
                    .tag(1)

                Schedule()
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Schedule")
                    }
                    .tag(2)

                ChatroomView()
                    .tabItem {
                        Image(systemName: "bubble.left.and.bubble.right")
                        Text("Chatroom")
                    }
                    .tag(3)
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
        .environmentObject(AuthViewModel())
        .environmentObject(AppData())
}
