//
//  HabitDetailView.swift
//  HabitTracker
//
//  Created by Adam Heidmann on 2/16/26.
//

import CoreData
import SwiftUI

struct HabitDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) var moc
    @State var originalText: String = ""
    
    @State var habit: Habit
    @State var titleText: String = ""
    @FocusState var editTextIsFocused: Bool
    
    var body: some View {
        
        ZStack {
            // Invisible background to catch taps
            Color.clear
                .contentShape(Rectangle()) // makes entire area tappable
                
            ScrollView{
                VStack{
                    
                    Spacer().frame(height: 50)
                    
                    //title/edit title
                    HStack{
                        
                        if editTextIsFocused {
                            Button{
                                editTextIsFocused.toggle()
                                
                                habit.title = titleText
                                try? moc.save()
                            }label:{
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .frame(width: 50, height: 50) // Apple minimum hit target
                                    .contentShape(Rectangle())    // entire 44x44 is tappable
                            }
                            .disabled(titleText.trimmingCharacters(in: .whitespacesAndNewlines) == "")
                            .padding(.leading)
                            .tint(colorScheme == .dark ? .white : .black)
                        } else {
                            Button{
                                editTextIsFocused.toggle()
                            }label:{
                                Image(systemName: "pencil")
                                    .font(.system(size: 20))
                                    .frame(width: 50, height: 50) // Apple minimum hit target
                                    .contentShape(Rectangle())    // entire 44x44 is tappable
                            }
                            .disabled(titleText.trimmingCharacters(in: .whitespacesAndNewlines) == "")
                            .padding(.leading)
                            .tint(colorScheme == .dark ? .white : .black)
                        }
                        
                        
                        TextField("Task", text: $titleText)
                            .focused($editTextIsFocused)
                            .onAppear {
                                titleText = habit.title ?? ""
                            }
                            .frame(width: 255)
                            .font(.title3)
                            .padding(.horizontal)
                            .onSubmit {
                                
                                if titleText.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                                    editTextIsFocused.toggle()
                                    
                                    habit.title = titleText
                                    try? moc.save()
                                } else {
                                    titleText = originalText
                                }
                            }
                            .onAppear{
                                originalText = habit.title ?? ""
                            }
                        
                        
                        
                        
                        Spacer()
                        
                        Button{
                            dismiss()
                        }label:{
                            Image(systemName: "xmark")
                                .font(.system(size: 18))
                                .frame(width: 50, height: 50) // Apple minimum hit target
                                .contentShape(Rectangle())    // entire 44x44 is tappable
                        }
                        .disabled(titleText.trimmingCharacters(in: .whitespacesAndNewlines) == "")
                        .padding(.trailing)
                        .tint(colorScheme == .dark ? .white : .black)
                    }
                    
                    //graphs
                    HabitMonthCarouselView(habit: habit).padding(.top, 20)
                    
                    //edits
                    HabitEditView(habit: habit).padding(.horizontal)
                    
                    
                    Spacer().frame(height: 150)
                }
                Spacer()
            }
        }.background(.ultraThinMaterial).ignoresSafeArea()
          
    }
}

