//
//  Calendarview.swift
//  Clock-In-Gamers
//
//  Created by Jake Souza on 4/24/25.
//

import SwiftUI
import EventKit

struct CalendarView: View {
    @State private var selectedDate: Date?
    @State private var currentMonth: Date = Date()
    @State private var showingEventEditor = false
    @State private var newEventTitle = ""
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
            HStack {
                Button("<") { currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth)! }
                Spacer()
                Text(monthTitle)
                    .font(.largeTitle)
                Spacer()
                Button(">") { currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth)! }
            }
            .padding()

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(calendar.shortWeekdaySymbols, id: \..self) { day in
                    Text(day)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }

                ForEach(daysInMonth, id: \..self) { date in
                    Text("\(calendar.component(.day, from: date))")
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .padding(8)
                        .background(selectedDate == date ? Color.blue.opacity(0.7) : Color.gray.opacity(0.2))
                        .cornerRadius(5)
                        .onTapGesture {
                            selectedDate = date
                            showingEventEditor = true
                        }
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingEventEditor) {
            VStack(spacing: 20) {
                Text("New Event")
                    .font(.headline)
                TextField("Event Title", text: $newEventTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button("Add to Apple Calendar") {
                    if let date = selectedDate {
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
                    if let date = selectedDate {
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

    func requestCalendarAccess(completion: @escaping (Bool) -> Void) {
        eventStore.requestAccess(to: .event) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    func addEvent(title: String, date: Date) {
        let event = EKEvent(eventStore: eventStore)
        event.title = title.isEmpty ? "Scheduled Event" : title
        event.startDate = date
        event.endDate = calendar.date(byAdding: .hour, value: 1, to: date) ?? date.addingTimeInterval(3600)
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

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}
