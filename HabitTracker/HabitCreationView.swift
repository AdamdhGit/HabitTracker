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
    
    
    var body: some View {
      
        VStack{
                //category
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
                Button{
                    newHabitText = ""
                    showHabitCreation = false
                }label:{
                    Image(systemName: "x.circle")
                        .font(.system(size: 24, weight: .bold))
                       
                }
                .tint(colorScheme == .dark ? .white : .black)
                .padding(16) //increases tappable area
                .contentShape(Circle()) //tells SwiftUI the hit shape
                .frame(height: 44)
                .background(
                    Circle()
                        .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.1))
                )
            }.padding()
            
            HStack {
                TextField("\(newHabitCategory == "Daily" ? "ex: Walk" : "ex: Travel Abroad")", text: $newHabitText)
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
                
              
                
                Button {
                    createHabit()
                    showHabitCreation = false
                } label: {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(newHabitText.trimmingCharacters(in: .whitespaces).isEmpty ? .gray : .green)
                }
                .disabled(newHabitText.trimmingCharacters(in: .whitespaces).isEmpty)
                .padding(16) //increases tappable area
                .contentShape(Circle()) //tells SwiftUI the hit shape
                .frame(height: 44)
                .background(
                    Circle()
                        .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.1))
                )
                
                
                
            }.padding(.horizontal).padding(.bottom, 15)
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
