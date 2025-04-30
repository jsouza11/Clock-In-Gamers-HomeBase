//
//  Notification.swift
//  Clock-In-Gamers
//
//  Created by Celeste Jolie on 4/28/25.
//
//

import SwiftUI
import FirebaseFirestore

struct NotificationCenterView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var loading = false
    @State private var usernames: [String: String] = [:] // UID → username

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Friend Requests")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)

                    Divider().background(Color.gray)

                    if loading {
                        ProgressView("Loading...")
                            .foregroundColor(.white)
                    } else if let requests = viewModel.currentUser?.friendRequests.incoming, !requests.isEmpty {
                        ForEach(requests, id: \.self) { uid in
                            HStack {
                                Text(usernames[uid] ?? uid)
                                    .foregroundColor(.white)
                                    .font(.body)

                                Spacer()

                                Button("Accept") {
                                    Task {
                                        await acceptFriendRequest(fromUID: uid)
                                    }
                                }
                                .foregroundColor(.green)

                                Button("Decline") {
                                    Task {
                                        await declineFriendRequest(fromUID: uid)
                                    }
                                }
                                .foregroundColor(.red)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                        }
                    } else {
                        Text("No incoming friend requests.")
                            .foregroundColor(.gray)
                    }

                    Spacer()
                }
                .padding()
            }
            .background(Color.black.ignoresSafeArea())
            .onAppear {
                Task {
                    await loadUsernames()
                }
            }
            .navigationBarTitle("Notifications", displayMode: .inline)
        }
        .preferredColorScheme(.dark)
    }

    // MARK: Accept request
    private func acceptFriendRequest(fromUID uid: String) async {
        guard let currentUser = viewModel.currentUser else { return }
        loading = true

        let db = Firestore.firestore()
        let batch = db.batch()
        let currentRef = db.collection("users").document(currentUser.id)
        let senderRef = db.collection("users").document(uid)

        batch.updateData([
            "friends": FieldValue.arrayUnion([uid]),
            "friendRequests.incoming": FieldValue.arrayRemove([uid])
        ], forDocument: currentRef)

        batch.updateData([
            "friends": FieldValue.arrayUnion([currentUser.id]),
            "friendRequests.outgoing": FieldValue.arrayRemove([currentUser.id])
        ], forDocument: senderRef)

        do {
            try await batch.commit()
            await viewModel.fetchUser()
        } catch {
            print("Error accepting request: \(error.localizedDescription)")
        }

        loading = false
    }

    // MARK: Decline request
    private func declineFriendRequest(fromUID uid: String) async {
        guard let currentUser = viewModel.currentUser else { return }

        let db = Firestore.firestore()
        let currentRef = db.collection("users").document(currentUser.id)

        do {
            try await currentRef.updateData([
                "friendRequests.incoming": FieldValue.arrayRemove([uid])
            ])
            await viewModel.fetchUser()
        } catch {
            print("Error declining request: \(error.localizedDescription)")
        }
    }

    // MARK: Load usernames for display
    private func loadUsernames() async {
        guard let uids = viewModel.currentUser?.friendRequests.incoming else { return }
        loading = true
        let db = Firestore.firestore()

        for uid in uids {
            let doc = try? await db.collection("users").document(uid).getDocument()
            if let data = doc?.data(), let username = data["username"] as? String {
                usernames[uid] = username
            }
        }
        loading = false
    }
}
