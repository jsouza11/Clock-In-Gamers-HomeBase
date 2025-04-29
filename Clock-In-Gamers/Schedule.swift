//
//  Schedule.swift
//  Clock-In-Gamers
//
//  Created by Jake Souza on 4/24/25.
//

import SwiftUI
import EventKit

struct Event: Identifiable {
    let id = UUID()
    let date: Date
    let title: String
}

struct Schedule: View {
    @State private var selectedDate: Date?
    @State private var selectedTime: Date = Date()
    @State private var currentMonth: Date = Date()
    @State private var showingEventEditor = false
    @State private var newEventTitle = ""
    @State private var scheduledEvents: [Event] = []

    private let calendar = Calendar.current
    private let eventStore = EKEventStore()

    private var daysInMonth: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else { return [] }
        var dates: [Date] = []
        var date = monthInterval.start
        while date < monthInterval.end {
            dates.append(date)
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        return dates
    }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }

    var body: some View {
        VStack {
            // Month navigation
            HStack {
                Button("<") { currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth)! }
                Spacer()
                Text(monthTitle)
                    .font(.largeTitle)
                Spacer()
                Button(">") { currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth)! }
            }
            .padding()

            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                    Text(day)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                ForEach(daysInMonth, id: \.self) { date in
                    Text("\(calendar.component(.day, from: date))")
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .padding(8)
                        .background(selectedDate == date ? Color.blue.opacity(0.7) : Color.gray.opacity(0.2))
                        .cornerRadius(5)
                        .onTapGesture {
                            selectedDate = date
                            selectedTime = Date() // Reset to current time
                            showingEventEditor = true
                        }
                }
            }
            .padding()

            // List of saved events
            List {
                Section(header: Text("Scheduled Events")) {
                    ForEach(scheduledEvents) { event in
                        VStack(alignment: .leading) {
                            Text(event.title)
                                .font(.headline)
                            Text(event.date, style: .date)
                                .font(.subheadline)
                            Text(event.date, style: .time)
                                .font(.subheadline)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
        .sheet(isPresented: $showingEventEditor) {
            VStack(spacing: 20) {
                Text("New Event")
                    .font(.headline)

                TextField("Event Title", text: $newEventTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                // 🕒 Time Picker
                DatePicker("Select Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(height: 100)

                Button("Save in App") {
                    if var date = selectedDate {
                        date = combineDateAndTime(date: date, time: selectedTime)
                        scheduledEvents.append(Event(date: date, title: newEventTitle))
                    }
                    showingEventEditor = false
                }
                .padding()

                Button("Add to Apple Calendar") {
                    if var date = selectedDate {
                        date = combineDateAndTime(date: date, time: selectedTime)
                        requestCalendarAccess { granted in
                            if granted {
                                addEvent(title: newEventTitle, date: date)
                            }
                        }
                    }
                    showingEventEditor = false
                }
                .padding()

                Button("Export as .ICS File") {
                    if var date = selectedDate {
                        date = combineDateAndTime(date: date, time: selectedTime)
                        exportICS(title: newEventTitle, date: date)
                    }
                    showingEventEditor = false
                }
                .padding()

                Button("Cancel") {
                    showingEventEditor = false
                }
                .padding()
            }
            .padding()
        }
    }

    // Combine selected day + selected time
    func combineDateAndTime(date: Date, time: Date) -> Date {
        let calendar = Calendar.current
        let dayComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)

        var finalComponents = DateComponents()
        finalComponents.year = dayComponents.year
        finalComponents.month = dayComponents.month
        finalComponents.day = dayComponents.day
        finalComponents.hour = timeComponents.hour
        finalComponents.minute = timeComponents.minute

        return calendar.date(from: finalComponents) ?? date
    }

    func requestCalendarAccess(completion: @escaping (Bool) -> Void) {
        eventStore.requestFullAccessToEvents { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func addEvent(title: String, date: Date) {
        let event = EKEvent(eventStore: eventStore)
        event.title = title.isEmpty ? "Scheduled Event" : title
        event.startDate = date
        event.endDate = Calendar.current.date(byAdding: .hour, value: 1, to: date) ?? date.addingTimeInterval(3600)
        event.calendar = eventStore.defaultCalendarForNewEvents

        do {
            try eventStore.save(event, span: .thisEvent)
            print("Event added to calendar!")
        } catch {
            print("Failed to save event: \(error.localizedDescription)")
        }
    }

    func exportICS(title: String, date: Date) {
        let eventString = """
        BEGIN:VCALENDAR
        VERSION:2.0
        BEGIN:VEVENT
        DTSTART:\(icsDateString(from: date))
        DTEND:\(icsDateString(from: date.addingTimeInterval(3600)))
        SUMMARY:\(title.isEmpty ? "Scheduled Event" : title)
        DESCRIPTION:Scheduled via the app
        END:VEVENT
        END:VCALENDAR
        """

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("event.ics")

        do {
            try eventString.write(to: tempURL, atomically: true, encoding: .utf8)
            share(url: tempURL)
        } catch {
            print("Failed to write .ics file: \(error)")
        }
    }

    func icsDateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: date)
    }

    func share(url: URL) {
#if canImport(UIKit)
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true, completion: nil)
        }
#endif
    }
}

struct Schedule_Previews: PreviewProvider {
    static var previews: some View {
        Schedule()
    }
}
