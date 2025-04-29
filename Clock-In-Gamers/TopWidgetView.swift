//
//  TopWidgetView.swift
//  Clock-In-Gamers
//
//  Created by Jake Souza on 4/24/25.
//

import SwiftUI

struct TopWidgetView: View {
    @Binding var isClockedIn: Bool
    var clockIn: () -> Void
    var clockOut: () -> Void

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Today's Stats")
                        .font(.headline)
                    // an example on what this could look like
                    Text("Points Earned: 0")
                        .foregroundColor(Color.black)
                    Text("Lifetime Points: 1400")
                        .foregroundColor(Color.black)
                    Text("Status: \(isClockedIn ? "Clocked In" : "Clocked Out")")
                        .font(.subheadline)
                        .foregroundColor(isClockedIn ? .green : .red)
                    
                    HStack {
                        if isClockedIn {
                            Button(action: clockOut) {
                                Text("Clock Out")
                                    .fontWeight(.bold)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        } else {
                            Button(action: clockIn) {
                                Text("Clock In")
                                    .fontWeight(.bold)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.top, 10)
                }
                Spacer()
                Image("kirby") // Use custom image here
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

