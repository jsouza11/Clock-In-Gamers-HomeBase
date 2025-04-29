//
//  ProfileView.swift
//  Clock-In-Gamers
//
//  Created by Jake Souza on 4/24/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var isEditing = false
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var authManager : AuthManager

    var discordPurple: Color {
        Color(red: 114 / 255, green: 137 / 255, blue: 218 / 255)
    }
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HStack {
                        Image("kirby")
                            .resizable()
                            .frame(width: 50, height: 50)
                        Text(appData.activeUser.name)
                            .font(.largeTitle)
                    }
                    .padding()

                    if isEditing {
                        Text("User Name")
                            .font(.headline)
                            .padding(.top)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        TextField("Enter your new name", text: $appData.activeUser.name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .accentColor(.white)
                            .cornerRadius(10)
                            .padding()
                            .frame(maxWidth: .infinity)
                        
                        Text("Bio")
                            .font(.headline)
                            .padding(.top)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        TextField("Enter your bio", text: $appData.activeUser.bio)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .accentColor(.white)
                            .cornerRadius(10)
                            .padding()
                            .frame(maxWidth: .infinity)
                        
                        HStack {
                            Image("discord")
                                .resizable()
                                .frame(width: 40, height: 40)
                            TextField("Enter your Discord link", text: $appData.activeUser.discordLink)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                                .background(Color.black)
                                .foregroundColor(.white)
                                .accentColor(.white)
                                .cornerRadius(10)
                                .padding(.leading, 10)
                        }
                        .padding()
                        
                        HStack {
                            Image("steam")
                                .resizable()
                                .frame(width: 40, height: 40)
                            TextField("Enter your Steam username", text: $appData.activeUser.steamUserName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                                .background(Color.black)
                                .foregroundColor(.white)
                                .accentColor(.white)
                                .cornerRadius(10)
                                .padding(.leading, 10)
                        }
                        .padding()
                        
                        HStack {
                            Image("xbox")
                                .resizable()
                                .frame(width: 40, height: 40)
                            TextField("Enter your Xbox username", text: $appData.activeUser.xboxUserName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                                .background(Color.black)
                                .foregroundColor(.white)
                                .accentColor(.white)
                                .cornerRadius(10)
                                .padding(.leading, 10)
                        }
                        .padding()
                    } else {
                        Text(appData.activeUser.bio.isEmpty ? "Hello!" : appData.activeUser.bio)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .padding()

                        if !appData.activeUser.discordLink.isEmpty {
                            HStack {
                                Image("discord")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                if let urlExists = try? URL(string: appData.activeUser.discordLink) {
                                    Link(destination: urlExists) {
                                        Text("Discord link")
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(discordPurple)
                                            .clipShape(Capsule())
                                    }
                                    .padding(.leading, 10)
                                } else {
                                    Text("No link")
                                        .padding(.leading, 10)
                                }
                            }
                            .padding()
                        }

                        if !appData.activeUser.steamUserName.isEmpty {
                            HStack {
                                Image("steam")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                Text(appData.activeUser.steamUserName)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 10)
                            }
                            .padding()
                        }

                        if !appData.activeUser.xboxUserName.isEmpty {
                            HStack {
                                Image("xbox")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                Text(appData.activeUser.xboxUserName)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 10)
                            }
                            .padding()
                        }
                    }
                    
                    HStack {
                        if isEditing {
                            Button("Save") {
                                if appData.activeUser.bio.isEmpty {
                                    appData.activeUser.bio = "Hello!"
                                }
                                appData.saveData()
                                isEditing.toggle()
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        } else {
                            Button("Edit") {
                                isEditing.toggle()
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }

                        NavigationLink(destination: EmptyView()) {
                            Text("Edit Schedule")
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }

                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .foregroundColor(.white)
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .navigationBarTitle("Profile", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Add log out functionality here
                        authManager.logout()
                    }) {
                        Text("Log Out")
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.red)
                            .clipShape(Capsule())
                    }
                    
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

