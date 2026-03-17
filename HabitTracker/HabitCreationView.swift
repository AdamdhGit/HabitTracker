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
    
    @Environment(\.dismiss) var dismiss
    @Binding var showHabitCreation:Bool
    
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.colorScheme) var colorScheme
    
    var timesOfDay : [String] = ["Morning", "Afternoon", "Evening"]
    
    //var categories : [String] = ["Daily", "Goals"]
    
    @State private var newHabitText = ""
    @State private var newHabitTime = "Morning"
    //@State private var newHabitCategory = "Daily"
    
    @FocusState var isAddEntryFocused: Bool
    
    //
    let days = ["M", "T", "W", "T", "F", "S", "S"]
    @State private var selectedDays: Set<Int> = Set(0...6) // default: every day
    
    @State private var notificationsEnabled = false
    
    @State private var hasSpecificTime = false
    @State private var specificTime = Date()
    
    @State private var repeatingEnabled = true
    
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
            
            Color.clear
                .contentShape(Rectangle())
            
            VStack{
                
                Spacer().frame(height: 50)
                
                //X and Save
                xAndSaveButtons.padding()
                
                HStack {
                    newHabitTextField
                    
                    timeOfDayPicker
                    
                }.padding(.horizontal).padding(.bottom, 15)
                
                //MARK: repeating toggle
                VStack(alignment: .leading, spacing: 8) {
                    repeatingText
                        
                    displayRepeatingDays
                        
                    
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
                Spacer()
            }
        }
        .background(.ultraThinMaterial).ignoresSafeArea()
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
                dismiss()
            }label:{
                Image(systemName: "xmark")
                    .font(.system(size: 16))
                
            }
            .tint(colorScheme == .dark ? .white : .black)
            .padding(16) //increases tappable area
            .contentShape(Rectangle()) //tells SwiftUI the hit shape
            .frame(width: 44, height: 44)
            /*
            .background(
                Circle()
                    .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.1))
            )
             */
            Spacer()
            
            Button {
                
                createHabit()
                dismiss()
            } label: {
                Text("Save")
                    .foregroundStyle(
                        newHabitText.trimmingCharacters(in: .whitespaces).isEmpty
                        ? .gray
                        : .green
                    )
                
            }
            .buttonStyle(.plain)
            .disabled(selectedDays.isEmpty)
            .disabled(newHabitText.trimmingCharacters(in: .whitespaces).isEmpty)
            .padding(16) //increases tappable area
            .contentShape(RoundedRectangle(cornerRadius: 12)) //tells SwiftUI the hit shape
            .frame(width: 70, height: 44)
            /*
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorScheme == .dark
                          ? Color.black.opacity(0.3)
                          : Color.gray.opacity(0.1))
            )
             */
            
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
            .onAppear{
                isAddEntryFocused.toggle()
            }
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
    
    var repeatingText: some View {
        HStack {
            Text("Repeating")
                .foregroundStyle(.primary)
            
            Spacer()
            
            //Toggle("Repeating Toggle", isOn: $repeatingEnabled)
               // .labelsHidden()
        }.padding(.bottom, 10)
    }
    
    var displayRepeatingDays: some View {
        HStack(spacing: 8) {
            Spacer()
            ForEach(days.indices, id: \.self) { index in
                Button {
                    if selectedDays.contains(index) {
                        selectedDays.remove(index)
                        
                        // ✅ If that was the last one, select all
                               if selectedDays.isEmpty {
                                   selectedDays = Set(days.indices)
                               }
                        
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
            newItem.title = newHabitText //done
            newItem.time = newHabitTime //done
            newItem.id = UUID() //done (not needed)
            newItem.dateCreated = Date()
        
        if hasSpecificTime { //done
            newItem.visualTime = specificTime //done
        } else {
            newItem.visualTime = nil
        }
        
        if notificationsEnabled { //done
            newItem.notificationsEnabled = true //done
            newItem.notificationTime = specificTime //done
            newItem.notificationOffset = Int16(notificationOffset) //done
        } else {
            newItem.notificationsEnabled = false
            newItem.notificationTime = nil
        }
        
            //the set just takes into account the index which matches the value of the days. its not looking at the day value, but by matching the index its the equivalent of matching the day value. and assigning whether each day is true in the actual object below.
               
               // Save weekday booleans
               newItem.onMonday = selectedDays.contains(0)
               newItem.onTuesday = selectedDays.contains(1)
               newItem.onWednesday = selectedDays.contains(2)
               newItem.onThursday = selectedDays.contains(3)
               newItem.onFriday = selectedDays.contains(4)
               newItem.onSaturday = selectedDays.contains(5)
               newItem.onSunday = selectedDays.contains(6)

        
        // Create the nested completion entity at start to get calendars showing
        /*
          let completion = HabitCompletion(context: moc)
          completion.id = UUID()
          completion.isCompleted = false
          completion.habit = newItem // link it
        */
        
        try? moc.save()
        
        if newItem.notificationsEnabled {
            
      
                scheduleRepeatingNotification(for: newItem)
           
            
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
        let center = UNUserNotificationCenter.current()
        guard let baseId = habit.id?.uuidString else {
            print("❌ Notification Error: Habit has no ID")
            return
        }

        // 1. CLEAR: Remove all 7 potential weekday slots + the base ID
        let identifiersToRemove = (1...7).map { "\(baseId)-\($0)" } + [baseId]
        center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)

        // 2. CHECK: Only proceed if enabled and time exists
        guard habit.notificationsEnabled, let time = habit.notificationTime else {
            print("ℹ️ Notifications disabled or no time set for: \(habit.title ?? "")")
            return
        }

        let calendar = Calendar.current
        let offsetMinutes = Int(habit.notificationOffset)

        // 3. MAPPING: Match your Core Data booleans to iOS Weekdays (Sun=1, Sat=7)
        var selectedWeekdays: [Int] = []
        if habit.onSunday { selectedWeekdays.append(1) }
        if habit.onMonday { selectedWeekdays.append(2) }
        if habit.onTuesday { selectedWeekdays.append(3) }
        if habit.onWednesday { selectedWeekdays.append(4) }
        if habit.onThursday { selectedWeekdays.append(5) }
        if habit.onFriday { selectedWeekdays.append(6) }
        if habit.onSaturday { selectedWeekdays.append(7) }

        guard !selectedWeekdays.isEmpty else {
            print("⚠️ No days selected for: \(habit.title ?? "")")
            return
        }

        // 4. CONTENT
        let content = UNMutableNotificationContent()
        content.title = habit.title ?? "Habit Reminder"
        if offsetMinutes > 0 {
            let unit = offsetMinutes == 60 ? "hour" : "minutes"
            let value = offsetMinutes == 60 ? 1 : offsetMinutes
            content.body = "Reminder: \(habit.title ?? "Habit") in \(value) \(unit)"
        } else {
            content.body = "Time for: \(habit.title ?? "your habit")!"
        }
        content.sound = .default

        // 5. SCHEDULE PER DAY
        for weekday in selectedWeekdays {
            // Calculate the adjusted time based on the offset
            let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
            
            // Use a dummy date to safely subtract the offset minutes
            if let dummyDate = calendar.date(from: timeComponents),
               let adjustedDate = calendar.date(byAdding: .minute, value: -offsetMinutes, to: dummyDate) {
                
                var finalTriggerComponents = DateComponents()
                finalTriggerComponents.weekday = weekday
                finalTriggerComponents.hour = calendar.component(.hour, from: adjustedDate)
                finalTriggerComponents.minute = calendar.component(.minute, from: adjustedDate)

                let trigger = UNCalendarNotificationTrigger(dateMatching: finalTriggerComponents, repeats: true)
                let request = UNNotificationRequest(
                    identifier: "\(baseId)-\(weekday)",
                    content: content,
                    trigger: trigger
                )

                center.add(request) { error in
                    if let error = error {
                        print("❌ Error scheduling weekday \(weekday): \(error.localizedDescription)")
                    } else {
                        print("✅ Scheduled: \(habit.title ?? "") for weekday \(weekday) at \(finalTriggerComponents.hour!):\(finalTriggerComponents.minute!)")
                    }
                }
            }
        }
    }
    
    
}

