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
            Image(systemName: "person.circle.fill") // Static icon
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
                .padding()
            
            Spacer()
            
            Text(user.fullName)
                .foregroundColor(.white)
                .font(.title2)
            
            Spacer()
            
            Text(user.email)
                .foregroundColor(.gray)
                .font(.subheadline)
        }
        .padding(.horizontal)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }
}
