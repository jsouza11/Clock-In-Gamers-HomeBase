  // TopWidgetView.swift
  // Clock-In-Gamers
  // Created by Jake Souza on 4/24/25.


import SwiftUI

struct TopWidgetView: View {
    var isClockedIn: Bool
      var clockIn: () -> Void
      var clockOut: () -> Void
      var fullName: String
      var onClockStatusChanged: () -> Void
      @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
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

                    HStack {
                        Button(action: {
                            Task {
                                await viewModel.updateClockStatus(isClockedIn: !isClockedIn)
                                onClockStatusChanged()
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
                    }
                    .padding(.top, 10)
                }

                Spacer()

                Image("kirby") // Or replace with your app icon
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
