//
//  Schedule.swift
//  Clock-In-Gamers
//
//  Created by Jake Souza on 4/24/25.
//

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

    // New for alerts
    @State private var showSuccessAlert = false
    @State private var showSettingsAlert = false

    // New for editing
    @State private var editingEvent: Event?
    @State private var editingTitle: String = ""
    @State private var editingTime: Date = Date()
    @State private var showingEditSheet = false

    private let calendar = Calendar.current
    private let eventStore = EKEventStore()

    private var visibleDates: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else { return [] }
        var dates: [Date?] = []

        let firstDayOfMonth = monthInterval.start
        let weekday = calendar.component(.weekday, from: firstDayOfMonth) // 1 = Sunday, 2 = Monday...

        // Add padding (weekday-1) because calendar starts with Sunday
        let padding = weekday - calendar.firstWeekday
        let blankDays = padding < 0 ? padding + 7 : padding
        dates.append(contentsOf: Array(repeating: nil, count: blankDays))

        var date = firstDayOfMonth
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
                    .fontWeight(.bold)
                Spacer()
                Button(">") { currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth)! }
            }
            .padding()

            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                // Weekday headers
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                    Text(day)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }

                // Dates of the month
                ForEach(visibleDates.indices, id: \.self) { index in
                    if let date = visibleDates[index] {
                        Text("\(calendar.component(.day, from: date))")
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .padding(8)
                            .background(isSameDay(selectedDate, date) ? Color.blue.opacity(0.7) : Color.gray.opacity(0.2))
                            .cornerRadius(5)
                            .onTapGesture {
                                selectedDate = calendar.startOfDay(for: date)
                                selectedTime = Date()
                                showingEventEditor = true
                            }
                    } else {
                        // Blank cell for padding
                        Text("")
                            .frame(maxWidth: .infinity, minHeight: 40)
                    }
                }
            }
            .padding()

            // Scheduled events
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
                        .contentShape(Rectangle())
                        .onTapGesture {
                            editingEvent = event
                            editingTitle = event.title
                            editingTime = event.date
                            showingEditSheet = true
                        }
                    }
                    .onDelete(perform: deleteEvent)
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

                DatePicker("Select Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(height: 100)

                Button("Save in App") {
                    if var date = selectedDate {
                        date = combineDateAndTime(date: date, time: selectedTime)
                        let newEvent = Event(date: date, title: newEventTitle)
                        scheduledEvents.append(newEvent)
                        NotificationCenterStorage.shared.addEvent(newEvent)
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
                                showSuccessAlert = true
                            } else {
                                showSettingsAlert = true
                            }
                            showingEventEditor = false
                        }
                    }
                }
                .padding()

                Button("Cancel") {
                    showingEventEditor = false
                }
                .padding()
            }
            .padding()
        }
        .sheet(isPresented: $showingEditSheet) {
            VStack(spacing: 20) {
                Text("Edit Event")
                    .font(.headline)

                TextField("Edit Title", text: $editingTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                DatePicker("Edit Time", selection: $editingTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(height: 100)

                Button("Save Changes") {
                    if let editingEvent = editingEvent {
                        if let index = scheduledEvents.firstIndex(where: { $0.id == editingEvent.id }) {
                            scheduledEvents[index] = Event(date: editingTime, title: editingTitle)
                        }
                    }
                    showingEditSheet = false
                }
                .padding()

                Button("Cancel") {
                    showingEditSheet = false
                }
                .padding()
            }
            .padding()
        }
        .alert("Event Added!", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your event was successfully added to your Calendar.")
        }
        .alert("Calendar Access Needed", isPresented: $showSettingsAlert) {
            Button("Open Settings") {
                openAppSettings()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please allow Calendar access in Settings to add events.")
        }
    }

    // Helpers

    func isSameDay(_ date1: Date?, _ date2: Date?) -> Bool {
        guard let date1 = date1, let date2 = date2 else { return false }
        return Calendar.current.isDate(date1, inSameDayAs: date2)
    }

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

    func deleteEvent(at offsets: IndexSet) {
        scheduledEvents.remove(atOffsets: offsets)
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
            openAppleCalendarApp()
        } catch {
            print("Failed to save event: \(error.localizedDescription)")
        }
    }

    func openAppleCalendarApp() {
        if let url = URL(string: "calshow://") {
#if canImport(UIKit)
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
#endif
        }
    }

    func openAppSettings() {
#if canImport(UIKit)
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
#endif
    }
}

struct Schedule_Previews: PreviewProvider {
    static var previews: some View {
        Schedule()
    }
}
