//
//  UserRowView.swift
//  Clock-In-Gamers
//
//  Created by Jake Souza on 4/24/25.
//

import SwiftUI

struct UserRowView: View {
    var user: User
    
    var body: some View {
        HStack {
            Image(systemName: user.isClockedIn ? "person.circle.fill" : "person.crop.circle.badge.xmark")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
                .padding()
            Spacer()
            Text(user.name)
                .foregroundColor(.white)
                .font(.title2)
            Spacer()
            Text(user.isClockedIn ? "Clocked In" : "Clocked Out")
                .foregroundColor(user.isClockedIn ? .green : .red)
                .font(.title2)
        }
        .padding(.horizontal)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}
