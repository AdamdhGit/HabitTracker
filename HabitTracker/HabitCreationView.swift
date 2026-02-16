//
//  HabitCreationView.swift
//  HabitTracker
//
//  Created by Adam Heidmann on 2/8/26.
//

import CoreData
import SwiftUI
import UserNotifications

struct HabitCreationView: View {
    
    @Binding var showHabitCreation:Bool
    
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.colorScheme) var colorScheme
    
    var timesOfDay : [String] = ["Morning", "Afternoon", "Evening"]
    
    //var categories : [String] = ["Daily", "Goals"]
    
    @State private var newHabitText = ""
    @State private var newHabitTime = "Morning"
    //@State private var newHabitCategory = "Daily"
    
    @FocusState.Binding var isAddEntryFocused: Bool
    
    //
    let days = ["M", "T", "W", "T", "F", "S", "S"]
    @State private var selectedDays: Set<Int> = Set(0...6) // default: every day
    
    @State private var notificationsEnabled = false
    
    @State private var hasSpecificTime = false
    @State private var specificTime = Date()
    
    @State private var repeatingEnabled = true
    @State private var selectedDate = Date()
    
    @State private var notificationOffset = 0
    let notificationOptions = [
        "At time",
        "5 minutes before",
        "15 minutes before",
        "30 minutes before",
        "1 hour before"
    ]
    let offsetValues = [0, 5, 15, 30, 60]
    
    
    var body: some View {
        
        ZStack{
            
            ScrollView{
                //X and Save
                xAndSaveButtons.padding()
                
                HStack {
                    newHabitTextField
                    
                    timeOfDayPicker
                    
                }.padding(.horizontal).padding(.bottom, 15)
                
                //MARK: repeating toggle
                VStack(alignment: .leading, spacing: 8) {
                    repeatingToggle
                    
                    if repeatingEnabled {
                        
                        displayRepeatingDays
                        
                    } else {
                        
                        selectSpecificDatePicker
                        
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colorScheme == .dark
                              ? Color.black.opacity(0.3)
                              : Color.gray.opacity(0.1))
                )
                .padding(.horizontal)
                
                //MARK: time toggle
                VStack(alignment: .leading, spacing: 8) {
                    timeToggle
                    
                    if hasSpecificTime {
                        
                        visualReminderTimePicker
                        
                        Divider().padding(.vertical)
                        
                        notificationsToggle
                        
                        if notificationsEnabled {
                            notificationChoicesPicker
                        }
                        
                    } else {
                        Text("No specific time")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colorScheme == .dark
                              ? Color.black.opacity(0.3)
                              : Color.gray.opacity(0.1))
                )
                .padding(.horizontal)
                
            }
        }
        .onChange(of: selectedDays) { oldValue, newValue in
            if repeatingEnabled && newValue.isEmpty {
                repeatingEnabled = false
            }
        }
        .onChange(of: repeatingEnabled, { oldValue, newValue in
            if newValue {
                selectedDays = Set(0...6)
            }
        })
        .onChange(of: notificationsEnabled) { _, _ in
            withAnimation{
                isAddEntryFocused = false
            }
        }
        .onChange(of: notificationOffset) { _, _ in
            isAddEntryFocused = false
        }
        .onChange(of: hasSpecificTime) { _, _ in
            isAddEntryFocused = false
        }
        .onChange(of: specificTime) { _, _ in
            isAddEntryFocused = false
        }
        .onChange(of: selectedDays) { _, _ in
            isAddEntryFocused = false
        }
        .onChange(of: notificationsEnabled) { oldValue, newValue in
            if newValue {
                requestNotificationPermission()
            }
        }

    }
    
    var xAndSaveButtons: some View {
        HStack{
            Button{
                newHabitText = ""
                showHabitCreation = false
            }label:{
                Image(systemName: "x.circle")
                    .font(.system(size: 24))
                
            }
            .tint(colorScheme == .dark ? .white : .black)
            .padding(16) //increases tappable area
            .contentShape(Circle()) //tells SwiftUI the hit shape
            .frame(width: 44, height: 44)
            .background(
                Circle()
                    .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.1))
            )
            Spacer()
            
            Button {
                
                createHabit()
                showHabitCreation = false
            } label: {
                Text("Save")
                    .foregroundStyle(
                        newHabitText.trimmingCharacters(in: .whitespaces).isEmpty
                        ? .gray
                        : .green
                    )
                
            }
            .buttonStyle(.plain)
            .disabled(repeatingEnabled && selectedDays.isEmpty)
            .disabled(newHabitText.trimmingCharacters(in: .whitespaces).isEmpty)
            .padding(16) //increases tappable area
            .contentShape(RoundedRectangle(cornerRadius: 12)) //tells SwiftUI the hit shape
            .frame(width: 70, height: 44)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorScheme == .dark
                          ? Color.black.opacity(0.3)
                          : Color.gray.opacity(0.1))
            )
            
        }
    }
    
    var newHabitTextField: some View {
        TextField("ex: Workout", text: $newHabitText)
            .tint(colorScheme == .dark ? .white : .black)
            .focused($isAddEntryFocused)
            .padding()
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.1))
            )
            .foregroundStyle(colorScheme == .dark ? .white : .black)
    }
    
    var timeOfDayPicker: some View {
        Picker(selection: $newHabitTime) {
            ForEach(timesOfDay, id: \.self) { time in
                Text(time)                  // this is each option
            }
        } label: {
            Text("Time of Day")            // the visible label for the picker
                .foregroundStyle(colorScheme == .dark ? .white : .black)
            
        }
        .pickerStyle(.menu)
        .tint(colorScheme == .dark ? .white : .black)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.1))
                .frame(height: 44)
        )
    }
    
    var repeatingToggle: some View {
        HStack {
            Text("Repeating")
                .foregroundStyle(.primary)
            
            Spacer()
            
            Toggle("Repeating Toggle", isOn: $repeatingEnabled)
                .labelsHidden()
        }.padding(.bottom, 10)
    }
    
    var displayRepeatingDays: some View {
        HStack(spacing: 8) {
            Spacer()
            ForEach(days.indices, id: \.self) { index in
                Button {
                    if selectedDays.contains(index) {
                        selectedDays.remove(index)
                    } else {
                        selectedDays.insert(index)
                    }
                } label: {
                    Text(days[index])
                        .font(.subheadline.weight(.semibold))
                        .frame(width: 32, height: 32)
                        .foregroundStyle(
                            selectedDays.contains(index)
                            ? .white
                            : .secondary
                        )
                        .background(
                            Circle()
                                .fill(
                                    selectedDays.contains(index)
                                    ? Color.green
                                    : Color.gray.opacity(0.2)
                                )
                        )
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
    }
    
    var selectSpecificDatePicker: some View {
        DatePicker(
            selection: $selectedDate,
            displayedComponents: .date
        ) {
            Text("Select Date")
                .foregroundStyle(colorScheme == .dark ? .white : .black)
        }
        .datePickerStyle(.compact) // closest to menu-style UX
        .tint(colorScheme == .dark ? .white : .black)
    }
    
    var timeToggle: some View {
        HStack {
            Text("Time")
                .foregroundStyle(.primary)
            
            Spacer()
            
            Toggle("Visual Reminder Time Toggle", isOn: $hasSpecificTime)
                .labelsHidden().onChange(of: hasSpecificTime) { oldValue, newValue in
                    if !newValue {
                        notificationsEnabled = false
                    }
                }
        }.padding(.bottom, 10)
    }
    
    var visualReminderTimePicker: some View {
        DatePicker(
            "Visual Reminder Time",
            selection: $specificTime,
            displayedComponents: .hourAndMinute
        )
        .datePickerStyle(.compact)
    }
    
    var notificationsToggle: some View {
        HStack {
            Text("Notifications")
                .foregroundStyle(.primary)
            
            Spacer()
            
            Toggle("Notifications Toggle", isOn: $notificationsEnabled)
                .labelsHidden()
        }
    }
    
    var notificationChoicesPicker: some View {
        HStack{
            Spacer()
            Picker("Notification Choices", selection: $notificationOffset) {
                ForEach(notificationOptions.indices, id: \.self) { i in
                    Text(notificationOptions[i])
                        .tag(offsetValues[i])
                    //tag stores the value of the offset value's index when an option is chosen. essentially mapping. 1 line of code. otherwise would map with a switch or if statements when save each entry.
                }
            }
            .labelsHidden()
            .pickerStyle(.menu)
            .tint(colorScheme == .dark ? .white : .black)
            Spacer()
        }
    }
    
    func createHabit() {
        
        let newItem = Habit(context: moc)
            newItem.title = newHabitText
            newItem.time = newHabitTime
            newItem.isCompleted = false
            newItem.id = UUID()
        
        newItem.isRepeating = repeatingEnabled
        
        if hasSpecificTime {
            newItem.visualTime = specificTime
        } else {
            newItem.visualTime = nil
        }
        
        if notificationsEnabled {
            newItem.notificationsEnabled = true
            newItem.notificationTime = specificTime
            newItem.notificationOffset = Int16(notificationOffset)
        } else {
            newItem.notificationsEnabled = false
            newItem.notificationTime = nil
        }
        
        if repeatingEnabled {
            //the set just takes into account the index which matches the value of the days. its not looking at the day value, but by matching the index its the equivalent of matching the day value. and assigning whether each day is true in the actual object below.
               
               // Save weekday booleans
               newItem.onMonday = selectedDays.contains(0)
               newItem.onTuesday = selectedDays.contains(1)
               newItem.onWednesday = selectedDays.contains(2)
               newItem.onThursday = selectedDays.contains(3)
               newItem.onFriday = selectedDays.contains(4)
               newItem.onSaturday = selectedDays.contains(5)
               newItem.onSunday = selectedDays.contains(6)
               
               newItem.specificDate = nil
               
           } else {
               
               // Save specific date
               newItem.specificDate = Calendar.current.startOfDay(for: selectedDate)
               
               // Turn off all weekday flags
               newItem.onMonday = false
               newItem.onTuesday = false
               newItem.onWednesday = false
               newItem.onThursday = false
               newItem.onFriday = false
               newItem.onSaturday = false
               newItem.onSunday = false
           }
            //newItem.category = newHabitCategory
        
        print (newItem.isCompleted)
        
        // Create the nested completion entity
          let completion = HabitCompletion(context: moc)
          completion.id = UUID()
          completion.isCompleted = false
          completion.date = Calendar.current.startOfDay(for: selectedDate)
          completion.habit = newItem // link it
        
        try? moc.save()

        print (newItem.isCompleted)
        
        if newItem.notificationsEnabled {
            
            if let id = newItem.id?.uuidString {
                   UNUserNotificationCenter.current()
                       .removePendingNotificationRequests(withIdentifiers: [id])
               }
            //prevents duplicate notifications
            
            if newItem.isRepeating {
                scheduleRepeatingNotification(for: newItem)
            } else {
                scheduleSingleDayNotification(for: newItem)
            }
            
            print("notification scheduled")
        }
        
        newHabitText = ""
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notifications: \(error)")
            } else {
                print("Notifications permission granted: \(granted)")
            }
        }
    }
    
    func scheduleRepeatingNotification(for habit: Habit) {
        guard habit.notificationsEnabled else { return }
        guard let time = habit.notificationTime else { return }

        let calendar = Calendar.current

        // Extract hour + minute from stored time
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)

        // Build a temporary full date using today
        var todayComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        todayComponents.hour = timeComponents.hour
        todayComponents.minute = timeComponents.minute

        guard let todayDate = calendar.date(from: todayComponents) else { return }

        // Apply offset
        let offsetMinutes = Int(habit.notificationOffset)
        let adjustedDate = calendar.date(byAdding: .minute,
                                         value: -offsetMinutes,
                                         to: todayDate) ?? todayDate

        // Extract final hour/minute
        let finalComponents = calendar.dateComponents([.hour, .minute], from: adjustedDate)

        let content = UNMutableNotificationContent()
        content.title = habit.title ?? "Habit Reminder"
        if offsetMinutes > 0 {
            content.body = "In \(offsetMinutes == 60 ? 1 : offsetMinutes) \(offsetMinutes == 60 ? "Hour" : "Minutes")"
        }
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: finalComponents,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: habit.id?.uuidString ?? UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }


    
    func scheduleSingleDayNotification(for habit: Habit) {
        guard habit.notificationsEnabled else { return }
        guard let time = habit.notificationTime else { return }
        guard let specificDate = habit.specificDate else { return }

        let calendar = Calendar.current

        // 1️⃣ Extract hour + minute from stored time
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)

        // 2️⃣ Combine specific date with selected time
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: specificDate)
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute

        guard let fullDate = calendar.date(from: dateComponents) else { return }

        // 3️⃣ Apply offset
        let offsetMinutes = Int(habit.notificationOffset)
        let finalDate = calendar.date(byAdding: .minute,
                                       value: -offsetMinutes,
                                       to: fullDate) ?? fullDate

        // 4️⃣ Prevent scheduling past notifications
        guard finalDate > Date() else { return }

        // 5️⃣ Create content
        let content = UNMutableNotificationContent()
        content.title = habit.title ?? "Habit Reminder"
        if offsetMinutes > 0 {
            content.body = "In \(offsetMinutes == 60 ? 1 : offsetMinutes) \(offsetMinutes == 60 ? "Hour" : "Minutes")"
        }
        content.sound = .default

        // 6️⃣ Create trigger (single fire)
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: calendar.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: finalDate
            ),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: habit.id?.uuidString ?? UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    
    
}

#Preview {
    
    let dataController = DataController()
    
    // Pass its context into ContentView
    HabitCreationView(showHabitCreation: .constant(false), isAddEntryFocused: FocusState<Bool>().projectedValue).environment(\.managedObjectContext, dataController.container.viewContext)
}

//MARK: daily/goals picker
/*
HStack{
    Picker(selection: $newHabitCategory) {
        ForEach(categories, id: \.self) { category in
            Text(category)                  // this is each option
        }
    } label: {
        Text("Category")            // the visible label for the picker
            .foregroundStyle(colorScheme == .dark ? .white : .black)
        
    }
    .pickerStyle(.menu)
    .tint(colorScheme == .dark ? .white : .black)
    .background(
        RoundedRectangle(cornerRadius: 12)
            .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.1))
            .frame(height: 44)
    )
    
    Spacer()
}.padding(.horizontal).padding(.bottom, 10)
*/

