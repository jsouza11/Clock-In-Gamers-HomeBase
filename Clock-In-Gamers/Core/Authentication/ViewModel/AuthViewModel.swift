//
//  AuthViewModel.swift
//  Clock-In-Gamers
//
//  Created by Jake Souza on 4/29/25.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreCombineSwift

protocol AuthenticationFormProtocol {
    var formisValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: UserData?

    init() {
        self.userSession = Auth.auth().currentUser

        Task {
            await fetchUser()
            await patchMissingIsClockedInField()
        }
    }

    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch {
            print("DEBUG: Failed to login with error: \(error.localizedDescription)")
        }
    }

    func createUser(withEmail email: String, password: String, fullName: String, username: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user

            let user = UserData(
                id: result.user.uid,
                fullName: fullName,
                email: email,
                username: username.lowercased(),
                isClockedIn: false,
                friends: [],
                friendRequests: FriendRequests()
            )

            let encodedUser = try Firestore.Encoder().encode(user)

            try await Firestore.firestore()
                .collection("users")
                .document(result.user.uid)
                .setData(encodedUser)

            await fetchUser()
        } catch {
            print("DEBUG: Failed to create user: \(error.localizedDescription)")
            throw error
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("DEBUG: Failed to sign out with error: \(error.localizedDescription)")
        }
    }

    func deleteAccount() {
        // Placeholder for account deletion logic
    }

    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("DEBUG: No user ID found.")
            self.userSession = nil
            self.currentUser = nil
            return
        }

        do {
            let snapshot = try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .getDocument()

            if let user = try? snapshot.data(as: UserData.self) {
                self.currentUser = user
                print("DEBUG: Successfully fetched user: \(user)")
            } else {
                print("DEBUG: Failed to decode UserData from snapshot.")
                self.userSession = nil
                self.currentUser = nil
            }
        } catch {
            print("DEBUG: Firestore error: \(error.localizedDescription)")
            self.userSession = nil
            self.currentUser = nil
        }
    }

    func updateClockStatus(isClockedIn: Bool) async {
        guard let uid = userSession?.uid else { return }

        await Task.detached(priority: .background) {
            do {
                try await Firestore.firestore()
                    .collection("users")
                    .document(uid)
                    .updateData(["isClockedIn": isClockedIn])

                await MainActor.run {
                    self.currentUser?.isClockedIn = isClockedIn
                    print("DEBUG: Clock status updated to \(isClockedIn)")
                }

            } catch {
                print("DEBUG: Failed to update clock status: \(error.localizedDescription)")
            }
        }.value
    }

    func patchMissingIsClockedInField() async {
        guard let uid = userSession?.uid else { return }

        let docRef = Firestore.firestore().collection("users").document(uid)

        do {
            let snapshot = try await docRef.getDocument()
            if let data = snapshot.data(), data["isClockedIn"] == nil {
                try await docRef.updateData(["isClockedIn": false])
                print("Patched isClockedIn for user.")
            }
        } catch {
            print("Error patching user document: \(error.localizedDescription)")
        }
    }

    func sendFriendRequest(toUsername: String) async {
        guard let uid = userSession?.uid else { return }
        let manager = FriendManager()
        try? await manager.sendFriendRequest(toUsername: toUsername, fromUID: uid)
    }

    func acceptFriendRequest(fromUID: String) async {
        guard let uid = userSession?.uid else { return }
        let manager = FriendManager()
        try? await manager.acceptFriendRequest(fromUID: fromUID, toUID: uid)
    }

    func declineFriendRequest(fromUID: String) async {
        guard let uid = userSession?.uid else { return }
        let manager = FriendManager()
        try? await manager.declineFriendRequest(fromUID: fromUID, toUID: uid)
    }

    func removeFriend(friendUID: String) async {
        guard let myUID = currentUser?.id else { return }
        let db = Firestore.firestore()

        let batch = db.batch()
        let meRef = db.collection("users").document(myUID)
        let themRef = db.collection("users").document(friendUID)

        batch.updateData(["friends": FieldValue.arrayRemove([friendUID])], forDocument: meRef)
        batch.updateData(["friends": FieldValue.arrayRemove([myUID])], forDocument: themRef)

        do {
            try await batch.commit()
            await fetchUser()
        } catch {
            print("Failed to remove friend: \(error.localizedDescription)")
        }
    }
}

extension AuthViewModel {
    static var preview: AuthViewModel {
        let vm = AuthViewModel()
        vm.currentUser = UserData.MOCK_USER
        return vm
    }
}
