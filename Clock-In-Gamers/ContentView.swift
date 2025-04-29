//
//  ContentView.swift
//  Clock-In-Gamers
//
//  Created by Celeste Jolie on 2/11/25.
//
import SwiftUI

struct ContentView: View {
    // Usernames array
    @State private var users: [User] = []

    @State private var isClockedIn = false
//    @ObservedObject var theUser = User(bio: "Hello", name: "Victor", discordLink: "", steamUserName: "", xboxUserName: "", status: StatusType.CLOCKEDIN, points: 100, type: GamerType.RELIABLE, isClockedIn: false)
    @ObservedObject var appData = AppData()
    @StateObject var authManager = AuthManager()
    
    init() {
    }

    var body: some View {
        Login(isUserAuthed: authManager.isAuthenticated)
            .environmentObject(appData)
            .environmentObject(authManager)
    }
}



#Preview {
    ContentView()
}
