//
//  IncomingRequestsView.swift
//  Clock-In-Gamers
//
//  Created by Jake Souza on 4/30/25.
//

import SwiftUI

struct IncomingRequestsView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Incoming Friend Requests")
                .font(.title2)
                .bold()
                .padding(.top)

            if let requests = viewModel.currentUser?.friendRequests.incoming, !requests.isEmpty {
                List(requests, id: \.self) { uid in
                    HStack {
                        Text(uid) // You can replace this with a username lookup
                            .font(.body)

                        Spacer()

                        Button("Accept") {
                            Task {
                                await viewModel.acceptFriendRequest(fromUID: uid)
                            }
                        }
                        .foregroundColor(.green)

                        Button("Decline") {
                            Task {
                                await viewModel.declineFriendRequest(fromUID: uid)
                            }
                        }
                        .foregroundColor(.red)
                    }
                }
            } else {
                Text("You have no incoming friend requests.")
                    .foregroundColor(.gray)
                    .padding(.top)
            }

            Spacer()
        }
        .padding()
    }
}
