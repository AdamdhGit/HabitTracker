//
//  HabitDetailView.swift
//  HabitTracker
//
//  Created by Adam Heidmann on 2/16/26.
//

import CoreData
import SwiftUI

struct HabitDetailView: View {
    
    @Environment(\.managedObjectContext) var moc
    
    @State var habit: Habit
    @State var titleText: String = ""
    @FocusState var editTextIsFocused: Bool
    @State var originalTitleOnOpen: String = ""
    
    var body: some View {
        
        ZStack {
            // Invisible background to catch taps
            Color.clear
                .contentShape(Rectangle()) // makes entire area tappable
                .onTapGesture {
                    editTextIsFocused = false
                    
                    if titleText.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                        titleText = originalTitleOnOpen
                    } else {
                        habit.title = titleText
                        try? moc.save()
                    }
                }
                .onAppear{
                    originalTitleOnOpen = habit.title ?? ""
                }
            ScrollView{
                HStack{
                    
                    if editTextIsFocused {
                        Button{
                            editTextIsFocused.toggle()
                            
                            habit.title = titleText
                            try? moc.save()
                        }label:{
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                        }.frame(width: 44, height: 44)       // minimum touch target
                            .contentShape(Rectangle())       // ensures the entire frame is tappable
                            .disabled(titleText.trimmingCharacters(in: .whitespacesAndNewlines) == "")
                    } else {
                        Button{
                            editTextIsFocused.toggle()
                        }label:{
                            Image(systemName: "pencil")
                                .font(.system(size: 20))
                        }.frame(width: 44, height: 44)       // minimum touch target
                            .contentShape(Rectangle())       // ensures the entire frame is tappable
                    }
                   
                    
                    TextField("Task", text: $titleText)
                        .focused($editTextIsFocused)
                        .onAppear {
                            titleText = habit.title ?? ""
                        }
                        .font(.title3)
                        .padding(.horizontal)
                    
                   
                  
                    
                    Spacer()
                }
                //graphs
                HabitMonthCarouselView(habit: habit)
                
                //edits
                HabitEditView(habit: habit)
                
                Spacer()
            }.padding()
        }
          
    }
}

/*
#Preview {
    HabitDetailView(habitName: Habit)
}
*/
