//
//  Schedule.swift
//  Clock-In-Gamers
//
//  Created by Jake Souza on 4/24/25.
//

import SwiftUI

struct AvailabilityDetail: View {
    let day: String
    let time: String

    var body: some View {
        VStack {
            Text("You have set your availability for a \(time) shift on \(day)!")
                .font(.headline)
                .padding()
        }
        .modifier(MainBackground())
    }
}

struct Schedule: View {
    let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    let timeBlocks = ["9:00 am", "12:00 pm", "3:00 pm", "6:00 pm", "9:00 pm", "12:00 am"]

    @State private var selectedTimes: [String: String] = [:]
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack {
                    Text("Availability")
                        .font(.title)
                        .foregroundColor(.white)
                    List {
                        // Generate a DisclosureGroup for each day
                        ForEach(daysOfWeek, id: \.self) { day in
                            DisclosureGroup(content: {
                                ForEach(timeBlocks, id: \.self) { time in
                                    //Button(action: {
                                    //    selectedTimes[day] = time
                                    //}) {
                                        NavigationLink(destination: AvailabilityDetail(day: day, time: time)) {
                                            Text(time)
                                        }
                                    }
                                //}
                            }) {
                                Text(day)
                                    .font(.headline)
                            }
                            .listRowBackground(Color.black)
                            .foregroundColor(.white)
                        }
                    }
                    .background(.black)
                    .foregroundColor(.white)
                    .scrollContentBackground(.hidden)
                    
                }
                .background(.black)
//                .modifier(MainBackground())
            }
        }
    }
//    func createDisclosureGroup(for day: String) -> some View {
//            DisclosureGroup(content: {
//                ForEach(timeBlocks, id: \.self) { time in
//                    //Button(action: {
//                    //    selectedTimes[day] = time
//                    //}) {
//                        NavigationLink(destination: AvailabilityDetail(day: day, time: time)) {
//                            Text(time)
//                        }
//                    }
//                //}
//            }) {
//                Text(day)
//                    .font(.headline)
//            }
//        }
}

#Preview {
    Schedule()
}

