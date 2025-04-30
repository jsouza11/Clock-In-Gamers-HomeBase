//
//  AddFriendsView.swift
//  Clock-In-Gamers
//
//  Created by Jake Souza on 4/30/25.
//

import SwiftUI

struct AddFriendView: View {
    @State private var username: String = ""
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var message: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("Add Friend")
                .font(.title)
                .bold()

            TextField("Enter username", text: $username)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .textInputAutocapitalization(.never)

            Button("Send Friend Request") {
                Task {
                    if !username.isEmpty {
                        await viewModel.sendFriendRequest(toUsername: username)
                        message = "Request sent to \(username)"
                        username = ""
                    }
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            if let msg = message {
                Text(msg)
                    .font(.subheadline)
                    .foregroundColor(.green)
            }

            Spacer()
        }
        .padding()
    }
}
