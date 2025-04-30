//
//  Schedule.swift
//  Clock-In-Gamers
//
//  Created by Jake Souza on 4/24/25.

import SwiftUI
import EventKit
import FirebaseFirestore
import FirebaseAuth

struct Event: Identifiable, Codable {
    @DocumentID var id: String?
    var sessionID: String
    var userID: String
    var username: String
    var date: Date
    var title: String
    var isPublic: Bool
}

struct Schedule: View {
    @State private var selectedDate: Date?
    @State private var selectedTime: Date = Date()
    @State private var currentMonth: Date = Date()
    @State private var showingEventEditor = false
    @State private var newEventTitle = ""
    @State private var scheduledEvents: [Event] = []
    
    @State private var showSuccessAlert = false
    @State private var showSettingsAlert = false
    @State private var editingEvent: Event?
    @State private var editingTitle: String = ""
    @State private var editingTime: Date = Date()
    @State private var showingEditSheet = false
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    
    private let calendar = Calendar.current
    private let eventStore = EKEventStore()
    
    private var visibleDates: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else { return [] }
        var dates: [Date?] = []
        
        let firstDayOfMonth = monthInterval.start
        let weekday = calendar.component(.weekday, from: firstDayOfMonth)
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
        NavigationStack {
            VStack {
                monthNavigationHeader
                calendarGrid
                scheduledEventsList
            }
            .background(Color.black)
            .navigationTitle("Schedule")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .task {
            await fetchEvents()
        }
        .sheet(isPresented: $showingEventEditor) { eventCreationSheet }
        .sheet(isPresented: $showingEditSheet) { eventEditSheet }
        .alert("Event Added!", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your event was successfully added to your Calendar.")
        }
        .alert("Calendar Access Needed", isPresented: $showSettingsAlert) {
            Button("Open Settings") { openAppSettings() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please allow Calendar access in Settings to add events.")
        }
    }
    
    // Month navigation buttons and title
    private var monthNavigationHeader: some View {
        HStack {
            Button("<") {
                currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth)!
            }
            .foregroundColor(.white)
            Spacer()
            Text(monthTitle)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Spacer()
            Button(">") {
                currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth)!
            }
            .foregroundColor(.white)
        }
        .padding()
    }
    
    // Calendar date grid
    private var calendarGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
            ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                Text(day)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
            }
            
            ForEach(visibleDates.indices, id: \.self) { index in
                if let date = visibleDates[index] {
                    Text("\(calendar.component(.day, from: date))")
                        .foregroundColor(.white)
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
                    Text("")
                        .frame(maxWidth: .infinity, minHeight: 40)
                }
            }
        }
        .padding()
    }
    
    // Event list section
    private var scheduledEventsList: some View {
        List {
            Section(header: Text("Scheduled Events").foregroundColor(.white)) {
                ForEach(scheduledEvents) { event in
                    VStack(alignment: .leading) {
                        Text(event.username)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(event.title)
                            .font(.headline)
                            .foregroundColor(.black)
                        Text(event.date, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.black)
                        Text(event.date, style: .time)
                            .font(.subheadline)
                            .foregroundColor(.black)
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
        .scrollContentBackground(.hidden)
        .background(Color.black)
    }
    
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
    private var eventCreationSheet: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("New Event")
                    .font(.headline)
                    .foregroundColor(.white)

                TextField("Event Title", text: $newEventTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                DatePicker("Select Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(height: 100)

                Button("Save in App") {
                    Task {
                        guard let uid = Auth.auth().currentUser?.uid,
                              let user = viewModel.currentUser,
                              var date = selectedDate else { return }

                        date = combineDateAndTime(date: date, time: selectedTime)
                        let sessionID = UUID().uuidString

                        let newEvent = Event(
                            sessionID: sessionID,
                            userID: uid,
                            username: user.username,
                            date: date,
                            title: newEventTitle.isEmpty ? "Untitled Session" : newEventTitle,
                            isPublic: false
                        )

                        do {
                            try await Firestore.firestore().collection("sessions").document(sessionID).setData(
                                try Firestore.Encoder().encode(newEvent)
                            )
                            scheduledEvents.append(newEvent)
                            showingEventEditor = false
                        } catch {
                            print("Error saving session: \(error)")
                        }
                    }
                }
                .foregroundColor(.blue)
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
                .foregroundColor(.blue)
                .padding()

                Button("Cancel") {
                    showingEventEditor = false
                }
                .foregroundColor(.blue)
                .padding()
            }
            .padding()
        }
        .preferredColorScheme(.dark)
    }

    private var eventEditSheet: some View {
        VStack(spacing: 20) {
            Text("Edit Event")
                .font(.headline)
                .foregroundColor(.white)

            TextField("Edit Title", text: $editingTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            DatePicker("Select Time", selection: $editingTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(height: 100)
                .colorScheme(.dark)

            Button("Save Changes") {
                if let editingEvent = editingEvent,
                   let index = scheduledEvents.firstIndex(where: { $0.id == editingEvent.id }) {
                    scheduledEvents[index] = Event(
                        sessionID: editingEvent.sessionID,
                        userID: editingEvent.userID,
                        username: editingEvent.username,
                        date: editingTime,
                        title: editingTitle,
                        isPublic: editingEvent.isPublic
                    )
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
        .background(Color.black)
    }

    
    func fetchEvents() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        // Include own UID + friends' UIDs
        let allUserIDs = [uid] + (viewModel.currentUser?.friends ?? [])
        
        do {
            // Query all events by users in list
            let snapshot = try await db.collection("sessions")
                .whereField("userID", in: allUserIDs)
                .getDocuments()
            
            var events = try snapshot.documents.compactMap { doc in
                try doc.data(as: Event.self)
            }
            
            // Show only own or public events
            events = events.filter { $0.isPublic || $0.userID == uid }
            
            // Sort by event date
            events.sort { $0.date < $1.date }
            
            // Update UI on main thread
            DispatchQueue.main.async {
                self.scheduledEvents = events
            }
            
        } catch {
            print("Error fetching events: \(error.localizedDescription)")
        }
    }
}
struct Schedule_Previews: PreviewProvider {
    static var previews: some View {
        Schedule()
    }
}


