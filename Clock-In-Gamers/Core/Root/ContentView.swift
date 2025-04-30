//
//  ContentView.swift
//  Clock-In-Gamers
//
//  Created by Celeste Jolie on 2/11/25.
//
import SwiftUI

struct ContentView: View {
    // Usernames array
   // @State private var users: [UserData] = []
  //  @State private var isClockedIn = false
   // @ObservedObject var appData = AppData()
   // @StateObject var authManager = AuthManager()
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        Group {
            if viewModel.userSession != nil {
                ProfView()
            }
            else {
                LoginView()
            }
            
            
            
            
            //Login(isUserAuthed: authManager.isAuthenticated)
               // .environmentObject(appData)
                //.environmentObject(authManager)
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
    
  
}
