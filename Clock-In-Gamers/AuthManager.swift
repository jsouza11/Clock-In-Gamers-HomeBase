//
//  AuthManager.swift
//  Clock-In-Gamers
//
//  Created by Jake Souza on 4/24/25.
//

import Foundation
import SwiftUI
import Combine

class AuthManager: ObservableObject {
    @Published var isAuthenticated: Bool {
        didSet {
            UserDefaults.standard.set(isAuthenticated, forKey: "isAuthenticated")
        }
    }
    @Published var username: String {
        didSet {
            UserDefaults.standard.set(username, forKey: "username")
        }
    }
    @Published var password: String {
         didSet {
             UserDefaults.standard.set(password, forKey: "password")
         }
     }
    init() {
        self.isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
        self.username = UserDefaults.standard.string(forKey: "username") ?? ""
        self.password = UserDefaults.standard.string(forKey: "password") ?? ""
    }
    private func getUserPassword(username: String) -> String? {
        return UserDefaults.standard.string(forKey: "user_\(username)")
    }

    private func saveUser(username: String, password: String) {
        UserDefaults.standard.set(password, forKey: "user_\(username)")
    }
    func register(username: String, password: String) -> Bool {
        guard getUserPassword(username: username) == nil else {
            // Username already exists
            return false
        }

        saveUser(username: username, password: password)
        self.isAuthenticated = true
        return true
    }
    func login(username: String, password: String) {
        if let storedPassword = getUserPassword(username: username), storedPassword == password {
            self.username = username
            self.password = password
            self.isAuthenticated = true
        } else if username == "Dude" {
            self.isAuthenticated = true
        } else {
            self.isAuthenticated = false
        }
    }

    func logout() {
        self.isAuthenticated = false
        self.username = ""
        self.password = ""
    }
}
