//
//  AuthViewModel.swift
//  Clock-In-Gamers
//
//  Created by Jake Souza on 4/29/25.
//

import Foundation
import Firebase
import FirebaseAuth
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
        }
    }
    
    func signIn(withEmail email: String, password:String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch {
            print("DEBUG failed to login with error \(error.localizedDescription)")
        }
    }
    
    func createUser(withEmail email: String, password: String, fullname:String) async throws {
        do {
                let result = try await Auth.auth().createUser(withEmail: email, password: password)
                self.userSession = result.user
                let user = UserData(id: result.user.uid, fullName: fullname, email: email)
                let encodedUser = try Firestore.Encoder().encode(user)
                try await Firestore.firestore()
                    .collection("users")
                    .document(result.user.uid)
                    .setData(encodedUser)
            await fetchUser()
            } catch {
                print("Failed to create user: \(error.localizedDescription)")
            }
    }
    
    func signOut()  {
        do {
            try Auth.auth().signOut() //signs out user on backend
            self.userSession = nil  // wipes out user session and takes us back to login screen
            self.currentUser = nil  // wipes out current user data model
        } catch {
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
    }
    
    func deleteAccount()  {
        
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: UserData.self)
        
        print("DEBUG: Current user is \(self.currentUser)")
    }
}
