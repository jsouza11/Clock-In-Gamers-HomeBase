//
//  FriendProfView.swift
//  Clock-In-Gamers
//
//  Created by Celeste Jolie on 4/30/25.
//

import SwiftUI
import Firebase

struct FriendProfView: View {
    let friend: UserData
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var isRemoving = false
    @State private var showConfirmation = false

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("@\(friend.username)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text(friend.fullName)
                    .font(.title3)
                    .foregroundColor(.gray)

                Text(friend.isClockedIn ? "Online" : "Offline")
                    .font(.subheadline)
                    .foregroundColor(friend.isClockedIn ? .green : .red)
            }
            .padding(.top, 40)

            Spacer()

            Button(action: {
                showConfirmation = true
            }) {
                Text("Remove Friend")
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .disabled(isRemoving)

            Spacer()
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Friend Profile")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Are you sure you want to remove @\(friend.username)?", isPresented: $showConfirmation) {
            Button("Remove", role: .destructive) {
                Task {
                    isRemoving = true
                    await viewModel.removeFriend(friendUID: friend.id)
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) { }
        }
    }
}

#Preview {
    FriendProfView(friend: .MOCK_USER)
        .environmentObject(AuthViewModel.preview)
}

