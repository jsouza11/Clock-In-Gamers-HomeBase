//
//  ProfView.swift
//  Clock-In-Gamers
//
//  Created by Jake Souza on 4/29/25.
//

import SwiftUI
import FirebaseStorage
import FirebaseFirestore

struct ProfView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var showingImagePicker = false
    @State private var selectedUIImage: UIImage?
    @State private var profileImageURL: URL?

    var body: some View {
        if let user = viewModel.currentUser {
            ScrollView {
                VStack(spacing: 32) {

                    // Profile Image & Info
                    VStack(spacing: 12) {
                        ZStack {
                            if let url = profileImageURL ?? URL(string: user.profileImageUrl ?? "") {
                                AsyncImage(url: url) { phase in
                                    if let image = phase.image {
                                        image.resizable().scaledToFill()
                                    } else if phase.error != nil {
                                        placeholderInitials(for: user)
                                    } else {
                                        ProgressView()
                                    }
                                }
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                            } else {
                                placeholderInitials(for: user)
                            }
                        }
                        .onTapGesture {
                            showingImagePicker = true
                        }

                        Text(user.fullName)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)

                        VStack(spacing: 2) {
                            Text(user.username)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6).opacity(0.1))
                    .cornerRadius(16)

                    // Settings Sections
                    VStack(spacing: 20) {
                        settingsSection(title: "General") {
                            settingsRow(
                                icon: "gear",
                                title: "Version",
                                value: "1.0.0",
                                tintColor: .gray
                            )
                        }

                        settingsSection(title: "Account") {
                            Button {
                                viewModel.signOut()
                            } label: {
                                settingsRow(
                                    icon: "arrow.left.circle.fill",
                                    title: "Sign Out",
                                    tintColor: .red
                                )
                            }

                            Button {
                                print("Delete Account...")
                            } label: {
                                settingsRow(
                                    icon: "trash.circle.fill",
                                    title: "Delete Account",
                                    tintColor: .red
                                )
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedUIImage)
                    .onDisappear {
                        if let image = selectedUIImage {
                            Task {
                                await uploadProfileImage(image)
                            }
                        }
                    }
            }
            .onAppear {
                if let urlStr = user.profileImageUrl, let url = URL(string: urlStr) {
                    profileImageURL = url
                }
            }
        } else {
            ProgressView("Loading...")
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
        }
    }

    // MARK: - Reusable Views

    func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                content()
            }
            .background(Color(.systemGray6).opacity(0.15))
            .cornerRadius(12)
        }
    }

    func settingsRow(icon: String, title: String, value: String? = nil, tintColor: Color) -> some View {
        HStack {
            Label {
                Text(title)
                    .foregroundColor(.white)
            } icon: {
                Image(systemName: icon)
                    .foregroundColor(tintColor)
            }

            Spacer()

            if let value = value {
                Text(value)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
    }

    func placeholderInitials(for user: UserData) -> some View {
        Text(user.initials)
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(width: 100, height: 100)
            .background(Color(.systemGray3))
            .clipShape(Circle())
    }

    // MARK: - Upload Profile Image

    func uploadProfileImage(_ image: UIImage) async {
        guard let uid = viewModel.userSession?.uid,
              let imageData = image.jpegData(compressionQuality: 0.4) else { return }

        let ref = Storage.storage().reference().child("profile_images/\(uid).jpg")

        do {
            _ = try await ref.putDataAsync(imageData, metadata: nil)
            let url = try await ref.downloadURL()

            try await Firestore.firestore().collection("users").document(uid).updateData([
                "profileImageUrl": url.absoluteString
            ])

            profileImageURL = url
            await viewModel.fetchUser()
        } catch {
            print("Failed to upload image: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ProfView()
        .environmentObject(AuthViewModel.preview)
}
