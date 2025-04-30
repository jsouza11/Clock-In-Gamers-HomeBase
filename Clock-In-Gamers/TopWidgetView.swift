  // TopWidgetView.swift
  // Clock-In-Gamers
  // Created by Jake Souza on 4/24/25.


import SwiftUI

struct TopWidgetView: View {
    var isClockedIn: Bool
    var fullName: String
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        let isClockedIn = viewModel.currentUser?.isClockedIn ?? false

        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Welcome, \(fullName)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)

                    Text("Points Earned: 0")
                        .foregroundColor(.black)
                    Text("Lifetime Points: 1400")
                        .foregroundColor(.black)
                    Text("Status: \(isClockedIn ? "Clocked In" : "Clocked Out")")
                        .font(.subheadline)
                        .foregroundColor(isClockedIn ? .green : .red)

                    Button(action: {
                        Task {
                            await viewModel.updateClockStatus(isClockedIn: !isClockedIn)
                        }
                    }) {
                        Text(isClockedIn ? "Clock Out" : "Clock In")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isClockedIn ? Color.red : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)
                }

                Spacer()

                Image("kirby") // Replace with your custom image if needed
                    .resizable()
                    .frame(width: 60, height: 60)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
        }
        .padding(.horizontal)
    }
}
