//
//  User.swift
//  Clock-In-Gamers
//
//  Created by Jake Souza on 4/29/25.
//

import Foundation

struct UserData: Identifiable, Codable {
    let id: String
    let fullName: String
    let email: String
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullName) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
}

extension UserData {
    static var MOCK_USER = UserData(id: NSUUID().uuidString, fullName: "Jake Souza", email: "jake@example.com")
        
}
