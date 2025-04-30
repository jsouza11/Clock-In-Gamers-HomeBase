//
//  Clock_In_GamersApp.swift
//  Clock-In-Gamers
//
//  Created by Celeste Jolie on 2/11/25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}



@main
struct Clock_In_GamersApp: App {
    
    @StateObject var viewModel = AuthViewModel()
    
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
        
    }
}
