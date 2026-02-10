//
//  HabitCreationView.swift
//  HabitTracker
//
//  Created by Adam Heidmann on 2/8/26.
//

import CoreData
import SwiftUI

struct HabitCreationView: View {
    
    @Binding var showHabitCreation:Bool
    
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.colorScheme) var colorScheme
    
    var timesOfDay : [String] = ["Morning", "Afternoon", "Evening"]
    
    var categories : [String] = ["Daily", "Goals"]
    
    @State private var newHabitText = ""
    @State private var newHabitTime = "Morning"
    @State private var newHabitCategory = "Daily"
    
    @State private var dailySelected = true
    @FocusState.Binding var isAddEntryFocused: Bool
    
    //
    let days = ["M", "T", "W", "T", "F", "S", "S"]
    @State private var selectedDays: Set<Int> = Set(0...6) // default: every day
    
    @State private var notificationsEnabled = false
    @State private var notificationOffset = "At time"
    
    @State private var hasSpecificTime = false
    @State private var specificTime = Date()
    
    let notificationOptions = [
        "At time",
        "5 min before",
        "15 min before",
        "30 min before"
    ]
    
    
    var body: some View {
      
        ZStack{
            
            ScrollView{
                //category
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
                    
                }.padding()
                
                //MARK: daily/goals picker
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
                
                HStack {
                    TextField("\(newHabitCategory == "Daily" ? "ex: Workout" : "ex: Travel Abroad")", text: $newHabitText)
                        .tint(colorScheme == .dark ? .white : .black)
                        .focused($isAddEntryFocused)
                        .padding()
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.1))
                        )
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                    
                    if newHabitCategory == "Daily" {
                        
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
                    
                    
                    
                    
                    
                    
                    
                    
                }.padding(.horizontal).padding(.bottom, 15)
                
                if newHabitCategory == "Daily" {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Time")
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Toggle("Add time", isOn: $hasSpecificTime)
                                .labelsHidden()
                        }.padding(.bottom, 10)
                        
                        if hasSpecificTime {
                            DatePicker(
                                "Visual Reminder Time",
                                selection: $specificTime,
                                displayedComponents: .hourAndMinute
                            )
                            .datePickerStyle(.compact)
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
                
                //select days of week
                if newHabitCategory == "Daily" {
                    HStack(spacing: 8) {
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
                    }
                    .padding()
                }
                
                if newHabitCategory == "Daily" {
                    HStack {
                        Toggle("Notifications", isOn: $notificationsEnabled)
                            .toggleStyle(.switch)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    if notificationsEnabled {
                        Picker("Notify", selection: $notificationOffset) {
                            ForEach(notificationOptions, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(colorScheme == .dark ? .white : .black)
                        .padding(.horizontal)
                    }
                }
                
               
                
                
                Spacer().frame(height: 75)
            }.preferredColorScheme(.dark)
        }
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

    }
    
    func createHabit() {
        
        let newItem = Habit(context: moc)
            newItem.title = newHabitText
            newItem.time = newHabitCategory == "Daily" ? newHabitTime : "" // or nil
            newItem.isCompleted = false
            newItem.id = UUID()
            newItem.category = newHabitCategory
        print (newItem.isCompleted)
        try? moc.save()

        print (newItem.isCompleted)
        newHabitText = ""
    }
    
    
}

#Preview {
    
    let dataController = DataController()
    
    // Pass its context into ContentView
    HabitCreationView(showHabitCreation: .constant(false), isAddEntryFocused: FocusState<Bool>().projectedValue).environment(\.managedObjectContext, dataController.container.viewContext)
}

