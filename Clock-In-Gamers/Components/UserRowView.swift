//
//  UserRowView.swift
//  Clock-In-Gamers
//
//  Created by Jake Souza on 4/24/25.
//

import SwiftUI

struct UserRowView: View {
    var user: UserData

    var body: some View {
        HStack {
            Image(systemName: user.isClockedIn ? "circle.fill" : "circle")
                .foregroundColor(user.isClockedIn ? .green : .gray)

            Text(user.username)
                .font(.title2)
                .foregroundColor(.white)

            Spacer()

            Text(user.isClockedIn ? "Online" : "Offline")
                .foregroundColor(user.isClockedIn ? .green : .red)
                .font(.subheadline)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}
