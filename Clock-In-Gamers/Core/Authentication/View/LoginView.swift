//
//  LoginView.swift
//  Clock-In-Gamers
//
//  Created by Jake Souza on 4/28/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                // Logo
                Image("logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 100)
                    .padding(.vertical, 32)
                
                // Form Fields
                VStack(spacing: 24) {
                    InputView(
                        text: $email,
                        title: "Email Address",
                        placeholder: "name@example.com",
                        textContentType: .emailAddress,
                        keyboardType: .emailAddress
                    )
                    
                    InputView(
                        text: $password,
                        title: "Password",
                        placeholder: "Enter your password",
                        isSecureField: true,
                        textContentType: .password
                    )
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                // Sign In Button
                Button {
                    Task {
                        do {
                            try await viewModel.signIn(withEmail: email, password: password)
                        } catch {
                            print("Sign-in error: \(error.localizedDescription)")
                        }
                    }
                } label: {
                    HStack {
                        Text("SIGN IN")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                }
                .background(Color(.systemBlue))
                .disabled(!formisValid)
                .cornerRadius(10)
                .opacity(formisValid ? 1.0 : 0.5)
                .padding(.top, 24)
                
                Spacer()
                
                // Sign Up Navigation
                NavigationLink {
                    RegistrationView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    HStack(spacing: 3) {
                        Text("Don't have an account?")
                        Text("Sign up")
                            .fontWeight(.bold)
                    }
                    .font(.system(size: 14))
                }
            }
        }
    }
}

//MARK: AuthenticationFormProtocal

extension LoginView: AuthenticationFormProtocol {
    var formisValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
