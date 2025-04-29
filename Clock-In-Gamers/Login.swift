//
//  Login.swift
//  Clock-In-Gamers
//
//  Created by Jake Souza on 4/24/25.
//

import SwiftUI

func isValidUser() -> Bool {
    return true;
}

struct Login: View {
    @State var userName = ""
    @State var password = ""
    @State var registerUserName = ""
    @State var registerPassword = ""
    @State var showingAlert: Bool = false
    @State var alertMessage: String = ""
    @State var shouldNavigate: Bool = false
    @State var errorLoggingIn: Bool = false
    @EnvironmentObject var theUser : User
    @EnvironmentObject var appData : AppData
    @EnvironmentObject var authManager: AuthManager
    
    init(isUserAuthed : Bool) {
        shouldNavigate = isUserAuthed
    }
    
    func login() {
        if userName.isEmpty || password.isEmpty {
            alertMessage = "Please enter both username and password."
            showingAlert = true
            return
        }
        authManager.login(username: userName, password: password)
        if !authManager.isAuthenticated {
            alertMessage = "Invalid username or password."
            showingAlert = true
        } else {
            let logInUser = appData.allUsers.first { user in
                return user.name == userName
            }
            if let activeLoggedInUser = logInUser {
                appData.activeUser = activeLoggedInUser
                shouldNavigate = true
            }
        }
    }
    func register() {
        if registerUserName.isEmpty || registerPassword.isEmpty {
            alertMessage = "Please enter both username and password."
            showingAlert = true
            return
        }

        if authManager.register(username: registerUserName, password: registerPassword) {
            let newUser = User(bio: "Hello whats going on", name: registerUserName, discordLink: "", steamUserName: "", xboxUserName: "", status: StatusType.CLOCKEDIN, points: 100, type: GamerType.RELIABLE, isClockedIn: true)
            appData.activeUser = newUser
            appData.allUsers.append(newUser)
            shouldNavigate = true
        } else {
            alertMessage = "Username already exists."
            showingAlert = true
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                VStack {
                    VStack {
                        Text("Register")
                            .font(.largeTitle)
                            .padding()
                        
                        VStack(alignment: .leading) {
                            Text("Username:")
                            TextField("Username", text: $registerUserName)
                                .background(Color.white)
                                .foregroundColor(.black)
                                .font(.title2)
                        }
                        VStack(alignment: .leading) {
                            Text("Password:")
                            SecureField("Password", text: $registerPassword)
                                .background(Color.white)
                                .foregroundColor(.black)
                                .font(.title2)
                        }

                        Button(action: {
                            register()
                        }) {
                            HStack {
                                Text("Register")
                                Image(systemName: "arrow.right")
                            }
                        }
                        .padding(10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(3.0)

                    }
                    .padding()
                    VStack {
                        Text("Login")
                            .font(.largeTitle)
                            .padding()
                        
                        VStack {
                            VStack(alignment: .leading) {
                                Text("Username:")
                                TextField("userName", text: $userName)
                                    .background(Color.white)
                                    .foregroundColor(.black)
                                    .font(.title2)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Password:")
                                TextField("password", text: $password)
                                    .background(Color.white)
                                    .foregroundColor(.black)
                                    .font(.title2)
                            }

                        }
                        .padding(20)
                        
                        VStack {
                            if errorLoggingIn {
                                Text("Wrong username or password")
                                Text("Try again")
                            }
                            Button(action: {
                                login()
                                errorLoggingIn = false;
                                shouldNavigate = true
                                if isValidUser() {
                                    
                                } else {
                                    errorLoggingIn = true;
                                }
                            }) {
                                HStack {
                                    Text("Submit")
                                    Image(systemName: "arrow.right")
                                }
                            }
                            .padding(10)
                            .background(Color.blue)
                            .cornerRadius(3.0)
                        }
                    }
                }
                .navigationDestination(isPresented: $shouldNavigate) {
                    AppNavigation()
                        .navigationBarBackButtonHidden(true)
                }
                .modifier(MainBackground())
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Login Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .edgesIgnoringSafeArea(.all) // Extend the view to the edges of the screen
    }
}

#Preview {
    Login(isUserAuthed: false)
}
