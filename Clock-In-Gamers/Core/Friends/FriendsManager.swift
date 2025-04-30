//
//  FriendsManager.swift
//  Clock-In-Gamers
//
//  Created by Jake Souza on 4/30/25.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreCombineSwift



class FriendManager {
    
    private let db = Firestore.firestore()

    func sendFriendRequest(toUsername: String, fromUID: String) async throws {
        let usersRef = db.collection("users")

        let snapshot = try await usersRef.whereField("username", isEqualTo: toUsername).getDocuments()
        guard let recipientDoc = snapshot.documents.first else {
            throw NSError(domain: "UserNotFound", code: 404)
        }

        let recipientUID = recipientDoc.documentID

        try await usersRef.document(recipientUID).updateData([
            "friendRequests.incoming": FieldValue.arrayUnion([fromUID])
        ])

        try await usersRef.document(fromUID).updateData([
            "friendRequests.outgoing": FieldValue.arrayUnion([recipientUID])
        ])
    }

    func acceptFriendRequest(fromUID: String, toUID: String) async throws {
        let usersRef = db.collection("users")

        try await usersRef.document(toUID).updateData([
            "friends": FieldValue.arrayUnion([fromUID]),
            "friendRequests.incoming": FieldValue.arrayRemove([fromUID])
        ])

        try await usersRef.document(fromUID).updateData([
            "friends": FieldValue.arrayUnion([toUID]),
            "friendRequests.outgoing": FieldValue.arrayRemove([toUID])
        ])
    }

    func declineFriendRequest(fromUID: String, toUID: String) async throws {
        let usersRef = db.collection("users")

        try await usersRef.document(toUID).updateData([
            "friendRequests.incoming": FieldValue.arrayRemove([fromUID])
        ])

        try await usersRef.document(fromUID).updateData([
            "friendRequests.outgoing": FieldValue.arrayRemove([toUID])
        ])
    }

    func fetchFriends(forUID uid: String) async throws -> [UserData] {
        let doc = try await db.collection("users").document(uid).getDocument()
        guard let friendIDs = doc.data()?["friends"] as? [String] else { return [] }

        var friends: [UserData] = []

        for id in friendIDs {
            let friendDoc = try await db.collection("users").document(id).getDocument()
            if let user = try? friendDoc.data(as: UserData.self) {
                friends.append(user)
            }
        }

        return friends
    }
}
