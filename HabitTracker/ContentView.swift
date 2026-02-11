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
    
    /*
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Habit.title, ascending: true)],
        predicate: NSPredicate(format: "category == %@", "Goals"),
        animation: .default
    )
    private var goalHabits: FetchedResults<Habit>
    */
    
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
    
    @State private var showWobble = false
    
    
    @State private var completedCount: Int = 0
    @State private var totalHabits: Int = 0 // Update this when habits are added/deleted

    var progressAmount: CGFloat {
        guard totalHabits > 0 else { return 0 }
        return CGFloat(completedCount) / CGFloat(totalHabits)
    }
    
    @State private var selectedDate = Date()
   

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
                    
                    //MARK: goals
                    /*
                    if !goalHabits.isEmpty {
                        Text("Goals")
                            .font(.title3)
                            .kerning(0.5)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .listRowSeparator(.hidden)
                        
                        ForEach(goalHabits) { i in
                            HabitRow(completedCount: $completedCount, habit: i)
                               
                            
                            
                            //this keeps the list background drag same shape as whats being dragged. matched it to my cornerRadius of my shape thats being dragged as well.
                            
                        }
                    }
                    */
                    
                    // compute all daily habits
                    let dailyHabits = timesOfDay.flatMap { time in
                        habits.filter { $0.time == time }
                    }
                    
                    // show "Daily" only if there’s at least one
                    if !dailyHabits.isEmpty {
                        HStack{
                            Text("Daily")
                                .font(.title3)
                                .kerning(0.5)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                                .padding(.top, 12)
                                
                        }.listRowSeparator(.hidden)
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
                                HabitRow(completedCount: $completedCount, habit: i)
                                  
                                
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
                        //MARK: this is what puts it right on keyboard when keyboard is open
                        
                        Button {
                            showHabitCreation = true
                            isAddEntryFocused = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .frame(width: 40, height: 40)
                                
                            
                        }
                    
                        
                        .buttonStyle(.glass)
                        
                    }
                }
                    
                if showHabitCreation {
                            VStack{
                                //MARK: last step to push view right onto top of keyboard is this Spacer and not one at the bottom
                                
                            
                                
                                HabitCreationView(showHabitCreation: $showHabitCreation,
                                                    isAddEntryFocused: $isAddEntryFocused)
                                
                                //.frame(height: 450)
                                .glassEffect(in: .rect(cornerRadius: 16.0))
                                .cornerRadius(16)
                                .padding(.horizontal, 5)
                            
                                //animate new entry bouncing in
                                .scaleEffect(x: showWobble ? 1.0 : 0.97, y: showWobble ? 1.0 : 1.03) // minimal squish
                                        .offset(y: showWobble ? 0 : 350) // slide in from bottom
                                        .opacity(showWobble ? 1 : 0)
                                        .onAppear {
                                            withAnimation(.interpolatingSpring(mass: 1.0, stiffness: 180, damping: 16, initialVelocity: 3)) {
                                                showWobble = true
                                            }
                                        }
                                        .onDisappear {
                                            showWobble = false
                                        }
                                        
                                        
                            }
                            .ignoresSafeArea(.keyboard)

                                    
                                    
                        }
            
                
            }
            .onAppear {
                updateTally()
            }
            // Also watch for database changes to keep totalHabits accurate
            .onChange(of: habits.count) {
                updateTally()
            }
            .toolbar{
                     
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        
                            //MARK: progress and date

                                HStack{
                                    
                                    VStack{
                                        ZStack {
                                            Circle()
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 3) // background
                                                .frame(width: 20, height: 20)
                                            
                                            Circle()
                                                .trim(from: 0, to: progressAmount)
                                                .stroke(Color.green, lineWidth: 3)
                                                .rotationEffect(.degrees(-90))
                                                .frame(width: 20, height: 20)
                                                
                                        }
                                        .overlay{ //MARK: Place the DatePicker in the overlay extension
                                            DatePicker(
                                              "",
                                              selection: $selectedDate,
                                              displayedComponents: [.date]
                                            )
                                            .colorMultiply(.clear)
                                            .blendMode(.destinationOver)
                                        }
                                    }.padding(.leading)
                                              
                                                //Text(dateFormatter.string(from: selectedDate))
                                                   // .font(.headline)
                                                  //  .foregroundColor(.primary)
                                    // Date button
                                   // Image(systemName: "calendar")
                                    Text(selectedDate, formatter: dateFormatter)
                                        .frame(width: 100, height: 44)
                                        .font(.subheadline)
                                        .padding(.trailing)
                                        .overlay{ //MARK: Place the DatePicker in the overlay extension
                                            DatePicker(
                                              "",
                                              selection: $selectedDate,
                                              displayedComponents: [.date]
                                            )
                                            .colorMultiply(.clear)
                                            .blendMode(.destinationOver)
                                        }
                                        
                                    
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
        }.preferredColorScheme(.dark)
               
        
        
       
    }
    
    func updateTally() {
        totalHabits = habits.count
        completedCount = habits.filter { $0.isCompleted }.count
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
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium  // e.g., Feb 10, 2026
        formatter.timeStyle = .none
        return formatter
    }

}

/*
#Preview {
    let dataController = DataController()

    ContentView()
        .environment(\.managedObjectContext, dataController.container.viewContext)
}
*/
