//
//  Home.swift
//  Clock-In-Gamers
//
//  Created by Jake Souza on 4/24/25.
//

import SwiftUI
import FirebaseFirestore

struct Home: View {
    @State private var showNotifications = false
    @State private var friendsData: [UserData] = []
    @State private var showRemoveAlert = false
    @State private var friendToRemove: UserData?

    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack {
                    // Welcome & Status
                    VStack(alignment: .leading, spacing: 10) {
                        if let user = viewModel.currentUser {
                            Text(user.isClockedIn ? "Welcome back, \(user.username)!" : "Welcome, \(user.username)!")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.top, 20)
                                .foregroundColor(.white)

                            Text(user.isClockedIn ? "You're clocked in." : "Ready to start your session?")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        } else {
                            Text("Loading user...")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)

                    // Widget
                    if let user = viewModel.currentUser {
                        TopWidgetView(
                            isClockedIn: user.isClockedIn,
                            clockIn: {}, // optional legacy
                            clockOut: {},
                            fullName: user.username,
                            onClockStatusChanged: {
                                Task {
                                    await viewModel.fetchUser()
                                    await loadFriends()
                                }
                            }
                        )
                        .environmentObject(viewModel)
                    }

                    // Friends List Header
                    HStack {
                        Text("Friends List")
                            .foregroundColor(.white)
                            .font(.title)
                            .padding(.leading)

                        Spacer()

                        NavigationLink(destination: AddFriendView()) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .padding(.trailing)
                        }
                    }
                    .padding(.top)

                    Divider()
                        .background(Color.white)
                        .padding(.horizontal)

                    // Friends List
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(friendsData) { friend in
                                UserRowView(user: friend)
                                    .padding(.horizontal)
                                    .onTapGesture {
                                        friendToRemove = friend
                                        showRemoveAlert = true
                                    }
                            }

                        }
                        .padding()
                    }

                    Spacer()
                }
                .background(Color.black.edgesIgnoringSafeArea(.all))
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showNotifications = true
                        }) {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "bell")
                                    .foregroundColor(.white)
                                    .font(.title2)

                                if let incoming = viewModel.currentUser?.friendRequests.incoming,
                                   !incoming.isEmpty {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 10, height: 10)
                                        .offset(x: 8, y: -8)
                                }
                            }
                        }
                    }
                }
                .sheet(isPresented: $showNotifications) {
                    NotificationCenterView()
                        .environmentObject(viewModel)
                }
                .alert("Remove Friend?", isPresented: $showRemoveAlert, presenting: friendToRemove) { friend in
                    Button("Remove", role: .destructive) {
                        Task {
                            await removeFriend(friend)
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                } message: { friend in
                    Text("Are you sure you want to remove @\(friend.username) from your friends?")
                }

                .onAppear {
                    Task {
                        await loadFriends()
                    }
                }
            }
            .modifier(MainBackground())
        }
    }

    // MARK: - Load friends from Firestore
    func loadFriends() async {
        guard let currentUser = viewModel.currentUser else { return }
        let db = Firestore.firestore()
        var fetchedFriends: [UserData] = []

        for uid in currentUser.friends {
            let doc = try? await db.collection("users").document(uid).getDocument()
            if let friend = try? doc?.data(as: UserData.self) {
                fetchedFriends.append(friend)
            }
        }

        DispatchQueue.main.async {
            self.friendsData = fetchedFriends
        }
    }
    
    func removeFriend(_ friend: UserData) async {
        guard let currentUser = viewModel.currentUser else { return }
        let db = Firestore.firestore()

        let batch = db.batch()
        let currentRef = db.collection("users").document(currentUser.id)
        let friendRef = db.collection("users").document(friend.id)

        batch.updateData([
            "friends": FieldValue.arrayRemove([friend.id])
        ], forDocument: currentRef)

        batch.updateData([
            "friends": FieldValue.arrayRemove([currentUser.id])
        ], forDocument: friendRef)

        do {
            try await batch.commit()
            await viewModel.fetchUser()
            await loadFriends()
        } catch {
            print("Error removing friend: \(error.localizedDescription)")
        }
    }
}


