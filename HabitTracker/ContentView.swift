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
    
    @State var refreshStateAfterEdit:Bool = false
    
    @Environment(\.scenePhase) var scenePhase
    
    let isIPad = UIDevice.current.userInterfaceIdiom == .pad
    
    @Environment(\.managedObjectContext) private var moc
    
    @FetchRequest(
        sortDescriptors: [
            // Use 'order: .forward' instead of 'ascending: true'
            SortDescriptor(\Habit.position, order: .forward),
            SortDescriptor(\Habit.title, order: .forward)
        ],
        animation: .default
    ) private var habits: FetchedResults<Habit>
    
    @Environment(\.colorScheme) var colorScheme
    //use enus for type safety repeating strings throughout.
    
    var timesOfDay : [String] = ["Morning", "Afternoon", "Evening"]
    
    @State private var showHabitCreation = false
    
    //@FocusState var isAddEntryFocused: Bool
    
    @State private var showWobble = false
    
    
    @State private var completedCount: Int = 0
    @State private var totalHabits: Int = 0 // Update this when habits are added/deleted
    
    var progressAmount: CGFloat {
        guard totalHabits > 0 else { return 0 }
        return CGFloat(completedCount) / CGFloat(totalHabits)
    }
    
    @State private var selectedDate = Date()
    @State private var showPicker = false
    
    @State private var editMode: EditMode = .inactive
    
    @State private var selectedHabitForDetail: Habit?
    
    var body: some View {
        
        
            ZStack(alignment: .top){
                
                VStack{
                    if showHabitCreation {
                        Spacer().frame(height: 44)
                        //fills top bar button space when habit creation is opened and top bar buttons are hidden
                    }
                    Spacer()
                }
                VStack{
                    Spacer().frame(height: 5)
                    //spacer keeps list in safe area
                    
                    //list habits
                    List{
                        
                        Spacer().frame(height: 20).listRowSeparator(.hidden)
                        //pushes list down
                        
                        // filters habits by morning/afternoon/evening
                        /*
                         let dailyHabits = timesOfDay.flatMap { time in
                         habitsForSelectedDate.filter { $0.time == time }
                         }
                         */
                        
                        // show "Daily" only if there’s at least one
                        //before: if !dailyhabits.isEmpty
                        if !habitsForSelectedDate.isEmpty {
                            HStack{
                                dayTitle
                                //today, yesterday, date, etc.
                                
                                
                                Spacer()
                                Button {
                                    withAnimation {
                                        // Toggles between active and inactive states
                                        editMode = (editMode == .active) ? .inactive : .active
                                    }
                                } label: {
                                    // Switch the icon based on the current state
                                    Image(systemName: editMode == .active ? "checkmark.circle.fill" : "arrow.up.arrow.down")
                                        .font(.system(size: 20))
                                        .foregroundStyle(.secondary)
                                        .padding(12)
                                    //adds to tap radius
                                        .contentShape(Rectangle())
                                    //contentShape treats hitbox like a "block of wood", everything tappable in it; otherwise have to hit exact pixels drawn
                                }
                                .padding(.top, 12)
                                .tint(colorScheme == .dark ? .white : .black)
                                .buttonStyle(.borderless) // Essential for tapping inside List rows
                                .listRowSeparator(.hidden)
                                //buttonStyle borderless to inherit taps and ignore tapGesture blocking it on list
                            }.listRowSeparator(.hidden)
                            
                        }
                        
                        if habitsForSelectedDate.isEmpty {
                            
                            ContentUnavailableView(
                                "No Tasks",
                                systemImage: "checkmark.circle",
                                description: Text("Tap the + button to add your first task")
                            ).listRowSeparator(.hidden)
                            
                        } else {
                            ForEach(timesOfDay, id: \.self) { time in
                                
                                let items = habitsForSelectedDate.filter { $0.time == time }
                                    .sorted { h1, h2 in
                                        // 1. Sort by visualTime (nils stay at the bottom)
                                        let t1 = h1.visualTime ?? .distantFuture
                                        let t2 = h2.visualTime ?? .distantFuture
                                        if t1 != t2 { return t1 < t2 }
                                        
                                        // 2. For items with the same time (or both nil), use position
                                        if h1.position != h2.position {
                                            return h1.position < h2.position
                                        }
                                        
                                        // 3. Fallback to title
                                        return (h1.title ?? "") < (h2.title ?? "")
                                    }
                                /*
                                 .sorted {
                                 // Visual-time items always first; nil treated as distantFuture
                                 ($0.visualTime ?? .distantFuture) < ($1.visualTime ?? .distantFuture)
                                 }
                                 */
                                //preceeding items displayed before following items based on time
                                //to handle nils, we use .distantFuture as a placeholder date for ascending sort order.
                                
                                //first goes through morning and draws habits that match the timesOfDay reference to it's own time value, then afernoon, then evening.
                                
                                if !items.isEmpty {
                                    
                                    // Title
                                    Text(time)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.secondary.opacity(0.85))
                                        .kerning(0.5)
                                    
                                    
                                    //habits listed
                                    ForEach(items) { i in

                                            HabitRow(completedCount: $completedCount, habit: i, selectedDate: $selectedDate)
                                                .moveDisabled(i.visualTime != nil)
                                                .contentShape(.dragPreview, Rectangle())
                                                .onTapGesture {
                                                        selectedHabitForDetail = i
                                                    }
                                                .listRowInsets(EdgeInsets(top: 2, leading: 10, bottom: 2, trailing: 10))
                                                .listRowBackground(Color.clear)
                                                .listRowSeparator(.hidden)
                                                

                                        //just as fast, just edit icon is hidden briefly rather than showing. either way theres a delay to handle the entire screens views being redrawn on a change. normal SwiftUI behavior.
                                        
                                    }.onMove { indices, newOffset in
                                        moveHabit(from: indices, to: newOffset, within: items)
                                    }
                                    
                                    //end habits
                                }
                                //end items
                            }
                        }
                        
                        
                    }
                    .id(refreshStateAfterEdit)
                    .environment(\.defaultMinListRowHeight, 1)
                    .listStyle(.plain)
                    .environment(\.editMode, $editMode)
                    .scrollIndicators(.hidden)
                }
            
                    // Floating bottom-center button
                if !showHabitCreation {
                    createHabitPlusButton
                }
                
               
                    //MARK: menu button
                    VStack{
                        HStack{
                            Spacer()
                            
                            Menu {
                               //add buttons
                            } label: {
                                Image(systemName: "slider.horizontal.2.square")
                                    .font(.system(size: 16))
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                    .padding()
                                    .clipShape(Circle())
                                    .glassEffect()
                                
                            }
                            .contentShape(Circle())
                            
                            
                        }.frame(height: 44).padding(.trailing)
                        Spacer()
                    }
                
                
                //MARK: date picker background tap off
                if showPicker {
                    Color.black.opacity(0.001) // Invisible but intercepts taps
                        .ignoresSafeArea()
                        .onTapGesture {
                            
                            showPicker = false
                            
                        }
                    
                }
                
                
                //MARK: date picker
                
                HStack{
                    DatePicker(
                        "Select Date",
                        selection: $selectedDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .frame(width: 320, height: 320)
                    .padding(.horizontal)
                    .labelsHidden()
                    //.transition(.opacity) // Add transition animation [11]
                    .glassEffect(in: .rect(cornerRadius: 16.0))
                    if isIPad{
                        Spacer()
                    }
                }
                
                
                .padding(.top, 60)
                .opacity(showPicker ? 1 : 0)
                .allowsHitTesting(showPicker)
                
                
                
              
                    //MARK: date picker button and progress circles
                    VStack{
                        HStack{
                            
                            // Button to show/hide the picker
                            Button{
                                withAnimation {
                                    showPicker.toggle()
                                }
                            }label:{
                                HStack{
                                    
                                    dailyProgressCircle
                                        .padding(.leading)
                                    
                                    
                                    // Date button
                                    Text(selectedDate, formatter: dateFormatter)
                                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                                        .frame(width: 90, height: 44)
                                        .font(.subheadline)
                                        .padding(.trailing)
                                    
                                }
                                .glassEffect()
                            }
                            
                            Spacer()
                        }.frame(height: 44).padding(.leading)
                        
                        
                        
                        
                        
                        Spacer()
                    }
                
                
              /*
               //habit creation old
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
                    
                */
                
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .active {
                    // Reset the picker to the current day whenever the app comes to the foreground
                    showPicker = false
                    selectedDate = Date()
                }
                
            }
            .onAppear {
                updateHabitCount()
            }
            // Also watch for database changes to keep totalHabits accurate
            .onChange(of: habits.count) {
                updateHabitCount()
            }
            .onChange(of: selectedDate, {
                updateHabitCount()
            })
        /*
            .sheet(item: $selectedHabitForDetail) { habit in
                HabitDetailView(habit: habit, refreshStateAfterEdit: $refreshStateAfterEdit)
            }
         */
            .fullScreenCover(item: $selectedHabitForDetail) { habit in
                HabitDetailView(habit: habit)
                    .presentationBackground(.clear)
                .onDisappear {
                    // Force whatever refresh logic you need
                    refreshStateAfterEdit.toggle()
                }
            }
            .fullScreenCover(isPresented: $showHabitCreation) {
             
                    //MARK: last step to push view right onto top of keyboard is this Spacer and not one at the bottom
                    HabitCreationView(showHabitCreation: $showHabitCreation)
                    .presentationBackground(.clear)
                /*
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
                    
                    */
              
            }
            
        
        
    }
    
    var dayTitle: some View {
        HStack{
            Text(displayDate(selectedDate))
                .font(.title3)
                .kerning(0.5)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.top, 12)
            
        }.listRowSeparator(.hidden)
    }
    
    func displayDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            return formatter.string(from: date)
        }
    }
    
    var createHabitPlusButton: some View {
        VStack {
            
            Spacer() // push to bottom
            //MARK: this is what puts it right on keyboard when keyboard is open
            
            
            Button {
                
                showHabitCreation = true
                //isAddEntryFocused = true
                
                
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 20))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .frame(width: 60, height: 60)
                //.background(Color(red: 0, green: 0, blue: 0.5))
                    .glassEffect()
                    .clipShape(Circle())
                
            }
            //.buttonStyle(.glass)
            .contentShape(Circle()) // now exactly matches background
            
            
        }
    }
    
    
    var dailyProgressCircle: some View {
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
    }
    
    func updateHabitCount() {
        totalHabits = habitsForSelectedDate.count
        
        completedCount = habitsForSelectedDate.filter { habit in
            habit.completions?
                .compactMap { $0 as? HabitCompletion }
                .contains { completion in
                    if let date = completion.date {
                        return Calendar.current.isDate(date, inSameDayAs: selectedDate) && completion.isCompleted
                    }
                    return false
                } ?? false
        }.count
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium  // e.g., Feb 10, 2026
        formatter.timeStyle = .none
        return formatter
    }
    
    var habitsForSelectedDate: [Habit] {
        
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: selectedDate)
        
        return habits.filter { habit in
                
                switch weekday {
                case 1: return habit.onSunday
                case 2: return habit.onMonday
                case 3: return habit.onTuesday
                case 4: return habit.onWednesday
                case 5: return habit.onThursday
                case 6: return habit.onFriday
                case 7: return habit.onSaturday
                default: return false
                }
                
             
        }
    }
    
    private func moveHabit(from source: IndexSet, to destination: Int, within currentItems: [Habit]) {
        var revisedItems = currentItems
        revisedItems.move(fromOffsets: source, toOffset: destination)
        
        // Update the position integers
        for index in 0..<revisedItems.count {
            revisedItems[index].position = Int16(index)
        }
        
        try? moc.save()
    }
    
    
    
    
}

/*
 #Preview {
 let dataController = DataController()
 
 ContentView()
 .environment(\.managedObjectContext, dataController.container.viewContext)
 }
 */

//MARK: goals

/*
 @FetchRequest(
 sortDescriptors: [NSSortDescriptor(keyPath: \Habit.title, ascending: true)],
 predicate: NSPredicate(format: "category == %@", "Goals"),
 animation: .default
 )
 private var goalHabits: FetchedResults<Habit>
 */

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


