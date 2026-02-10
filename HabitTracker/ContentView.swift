//
//  ContentView.swift
//  HabitTracker
//
//  Created by Adam Heidmann on 2/8/26.
//

import Combine
import CoreData
import SwiftUI

struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var moc
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Habit.title, ascending: true)],
        predicate: NSPredicate(format: "category == %@", "Goals"),
        animation: .default
    )
    private var goalHabits: FetchedResults<Habit>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Habit.title, ascending: true)],
        animation: .default
    ) private var habits: FetchedResults<Habit>
    
    @Environment(\.colorScheme) var colorScheme
    //use enus for type safety repeating strings throughout.
   
    var timesOfDay : [String] = ["Morning", "Afternoon", "Evening"]
    
    @State private var showHabitCreation = false
    @AppStorage("ShowReminders") private var showReminders = false
    @AppStorage("ReminderText") private var reminderText = ""
    
    @FocusState private var isReminderFocused: Bool
    
    @FocusState var isAddEntryFocused: Bool
    
    var body: some View {

        NavigationStack{
            ZStack(alignment: .top){
                
                //list habits
                
                List{
                    
                    //reminders
                    
                    if showReminders {
                        VStack(alignment: .leading) {
                            HStack{
                                Text("Reminders")
                                    .font(.title3)
                                    .kerning(0.5)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                                    .padding(.top, 12)
                                Spacer()
                                /*
                                if isReminderFocused {
                                    Text("\(reminderText.count)/250")
                                }
                                 */
                                
                            }
                            
                            ZStack(alignment: .topLeading) {
                                // Placeholder
                                if reminderText.isEmpty {
                                    Text("Write a note...")
                                        .foregroundStyle(.secondary.opacity(1))
                                        .padding(8)
                                        .padding(.top, 5)
                                        .padding(.leading, 5)
                                }
                                
                                TextEditor(text: $reminderText)
                                    .focused($isReminderFocused)
                                    .scrollContentBackground(.hidden)
                                    .tint(colorScheme == .dark ? .white : .black)
                                    .frame(height: 120) // reasonable size
                                    .padding(4)
                                /*
                                    .onChange(of: reminderText) { oldValue, newValue in
                                        // enforce character limit
                                        if newValue.count > 250 {
                                            reminderText = String(newValue.prefix(250))
                                        }
                                    }
                                 */
                                /*
                                    .toolbar {
                                        ToolbarItemGroup(placement: .keyboard) {
                                            Spacer()
                                            Button {
                                                isReminderFocused = false
                                            } label: {
                                                Image(systemName: "keyboard.chevron.compact.down")
                                                    .font(.title3)
                                            }
                                        }
                                    }
                                 */
                                
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(colorScheme == .dark
                                          ? Color.white.opacity(0.05)   // Apple dark-mode card feel
                                          : Color.black.opacity(0.05)    // Light-mode card feel
                            ))
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    
                    //goals
                    
                    if !goalHabits.isEmpty {
                        Text("Goals")
                            .font(.title3)
                            .kerning(0.5)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .listRowSeparator(.hidden)
                        
                        ForEach(goalHabits) { i in
                            HabitRow(habit: i)
                               
                            
                            
                            //this keeps the list background drag same shape as whats being dragged. matched it to my cornerRadius of my shape thats being dragged as well.
                            
                        }
                    }
                    
                    // compute all daily habits
                    let dailyHabits = timesOfDay.flatMap { time in
                        habits.filter { $0.time == time }
                    }
                    
                    // show "Daily" only if there’s at least one
                    if !dailyHabits.isEmpty {
                        Text("Daily")
                            .font(.title3)
                            .kerning(0.5)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .padding(.top, 12)
                            .listRowSeparator(.hidden)
                    }
                    
                    
                    ForEach(timesOfDay, id: \.self) { time in
                        let items = habits.filter { $0.time == time }
                        
                        //first goes through morning and draws habits that match the timesOfDay reference to it's own time value, then afernoon, then evening.
                        
                        
                        if !items.isEmpty {
                            
                            // Title
                            Text(time)
                                .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary.opacity(0.85))
                                    .kerning(0.5)
                            
                            
                            //habits
                            
                            ForEach(items) { i in
                                HabitRow(habit: i)
                                  
                                
                            }
                            //end habits
                        }
                        //end items
                        
                    }
                    
                }
                .listStyle(.plain)
                .scrollIndicators(.hidden)
                .onTapGesture {
                    isReminderFocused = false
                    
                }
                
      
                
                if !showHabitCreation{
                    // Floating bottom-center button
                    VStack {
                        Spacer() // push to bottom
                        
                        Button {
                            showHabitCreation = true
                            isAddEntryFocused = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                            
                        }
                        .buttonStyle(.glass)
                        
                    }
                }
                
                // Show InputView above keyboard
                           if showHabitCreation {
                               VStack{
                                   Spacer()
                                   HabitCreationView(showHabitCreation: $showHabitCreation,
                                                     isAddEntryFocused: $isAddEntryFocused)
                                   
                                   .frame(height: 140)
                                   .glassEffect(in: .rect(cornerRadius: 16.0))
                                   .cornerRadius(16)
                                   .padding(.horizontal, 5)
                                   
                                   .transition(.move(edge: .bottom).combined(with: .opacity))
                                   .animation(.easeInOut, value: showHabitCreation)
                               }
                           }
                
                

                
                
               
                
            }

            .toolbar{
                     
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button{
                        
                    }label:{
                        Text("02/08/2026").font(.subheadline).padding()
                    }
                 
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    
                    Menu {
                        Toggle("Show Reminders", isOn: $showReminders)
                    } label: {
                        Image(systemName: "slider.horizontal.2.square")
                            .font(.system(size: 16))
                         
                          
                            .contentShape(Circle()) //tells SwiftUI the hit shape
                            .frame(height: 40)
                           
                    }.buttonStyle(.plain)
                    
               
                }

            }
        }
               
        
        
       
    }
    
    func returnRowColor(habit: Habit) -> Color {
        if colorScheme == .dark {
            if habit.isCompleted {
                return Color.green.opacity(0.1)
            } else {
                return Color.white.opacity(0.1)
            }
        } else {
            if habit.isCompleted {
                return Color.green.opacity(0.1)
            } else {
                return Color.black.opacity(0.1)
            }
        }
    }

    
    
}

#Preview {
    
    let dataController = DataController()
        
       ContentView().environment(\.managedObjectContext, dataController.container.viewContext)
    
}

struct HabitRow: View {
    @ObservedObject var habit: Habit
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) private var moc

    var body: some View {
        HStack(spacing: 12) {
            Button {
                print("tapped button")
                habit.isCompleted.toggle()
                do {
                    try moc.save()
                } catch {
                    print("Save error:", error)
                }
            } label: {
                Image(systemName: habit.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .background(
                        // Transparent, hit-testable area that does NOT affect layout of parent
                           Color.clear
                           .frame(width: 60, height: 60)    // target size
                           .contentShape(Circle())
                    )
                    .foregroundStyle(returnRowColor(habit: habit))
                
            }
            
            .buttonStyle(.plain)
            
           
            
            Text(habit.title ?? "Unknown")
                .strikethrough(habit.isCompleted)
                .foregroundStyle(habit.isCompleted ? .secondary : .primary)
            
            Spacer()
        }
        .padding(7)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(habit.isCompleted
                      ? Color.green.opacity(0.12)
                      : (colorScheme == .dark
                         ? Color.white.opacity(0.1)
                         : Color.black.opacity(0.08)))
        )
        .animation(.easeInOut(duration: 0.2), value: habit.isCompleted)
        //.padding
       
        .clipShape(RoundedRectangle(cornerRadius: 14))
    
    // 2. The "Mask" - This clips the red box to your card shape
    
    
    // 3. The Row Background - Makes the area behind your card invisible
        .listRowBackground(Color.clear)
    
    // 4. Insets - This controls the spacing between the rows
        .listRowInsets(EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10))
    
        .listRowSeparator(.hidden)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                
                moc.delete(habit)
                try? moc.save()
                
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    func returnRowColor(habit: Habit) -> Color {
        if colorScheme == .dark {
            if habit.isCompleted {
                return Color.green.opacity(0.1)
            } else {
                return Color.white.opacity(0.1)
            }
        } else {
            if habit.isCompleted {
                return Color.green.opacity(0.1)
            } else {
                return Color.black.opacity(0.1)
            }
        }
    }
}

