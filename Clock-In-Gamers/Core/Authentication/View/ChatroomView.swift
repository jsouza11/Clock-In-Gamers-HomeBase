//
//  ChatroomView.swift
//  Clock-In-Gamers
//
//  Created by Jake Souza on [Date].
//

import SwiftUI

struct ChatroomView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {
                Spacer()
                Text("Chatroom is empty.")
                    .foregroundColor(.gray)
                    .font(.headline)
                Spacer()
            }
        }
    }
}

#Preview {
    ChatroomView()
}
