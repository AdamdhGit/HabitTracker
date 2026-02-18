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
                        VStack{
                            
                            Spacer().frame(height: 50)
                            
                           
                            
                            //title/edit title
                            HStack{
                                
                                if editTextIsFocused {
                                    Button{
                                        withAnimation{
                                            editTextIsFocused = false
                                        }
                                        habit.title = titleText
                                        try? moc.save()
                                    }label:{
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 20))
                                            .frame(width: 50, height: 50) // Apple minimum hit target
                                            .contentShape(Rectangle())    // entire 44x44 is tappable
                                    }
                                    .disabled(titleText.trimmingCharacters(in: .whitespacesAndNewlines) == "")
                                    .tint(colorScheme == .dark ? .white : .black)
                                } else {
                                    Button{
                                        withAnimation{
                                            editTextIsFocused = true
                                        }
                                    }label:{
                                        Image(systemName: "pencil")
                                            .font(.system(size: 20))
                                            .frame(width: 50, height: 50) // Apple minimum hit target
                                            .contentShape(Rectangle())    // entire 44x44 is tappable
                                    }
                                    .disabled(titleText.trimmingCharacters(in: .whitespacesAndNewlines) == "")
                                    .tint(colorScheme == .dark ? .white : .black)
                                }
                                
                                HStack{
                                    TextField("Task", text: $titleText)
                                    .focused($editTextIsFocused)
                                    //.lineLimit(1)
                                    //.truncationMode(.tail)
                                    .frame(width: 220)
                                    .submitLabel(.done)
                                    .onAppear {
                                        titleText = habit.title ?? ""
                                    }
                                    .onChange(of: titleText) { _, newValue in
                                        // CAP the text to 35 characters to keep the UI clean
                                        if newValue.count > 25 {
                                            titleText = String(newValue.prefix(25))
                                        }
                                    }
                                    .font(.title3)
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
                            }
                                
                                if editTextIsFocused {
                                    Text("(\(titleText.count) / 25)").foregroundStyle(.gray).font(.caption).padding(.trailing)
                                }
                                
                            }.frame(height:50).padding(.horizontal)
                            
                            //graphs
                            HabitMonthCarouselView(habit: habit).padding(.top, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.1))
                                        
                                ).padding(.horizontal).padding(.horizontal)
                                .padding(.bottom, 20)
                            
                            //edits
                            HabitEditView(habit: habit).padding(.horizontal)
                            
                            Button(role: .destructive) {
                                
                                //clear notifications of object
                                if let baseId = habit.id?.uuidString {
                                    let center = UNUserNotificationCenter.current()
                                    let identifiersToRemove = (1...7).map { "\(baseId)-\($0)" } + [baseId]
                                    center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
                                }
                            
                                //delete object
                                moc.delete(habit)
                                try? moc.save()
                                
                                dismiss()
                                
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }.padding(.top, 30)
                            
                            Spacer().frame(height: 120)
                        }
                        
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                }.mask(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            // Top: Clear until the toolbar ends (approx 12%)
                            .init(color: .clear, location: 0),
                            .init(color: .black, location: 0.1), // Fades in content below bar
                            
                            // Bottom: Solid until the home indicator area (approx 92%)
                            .init(color: .black, location: 0.85), // Fades out before bottom edge
                            .init(color: .clear, location: 1.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    ).ignoresSafeArea(edges: .bottom)
                )
            
            VStack{
                HStack{
                    Spacer()
                    Button{
                        dismiss()
                    }label:{
                        Image(systemName: "xmark")
                            .font(.system(size: 18))
                            .frame(width: 50, height: 50) // Apple minimum hit target
                            .contentShape(Rectangle())    // entire 50x50 is tappable
                    }
                    .disabled(titleText.trimmingCharacters(in: .whitespacesAndNewlines) == "")
                    .padding(.trailing)
                    .tint(colorScheme == .dark ? .white : .black)
                }
                
               
                
                Spacer()
            }.padding(.trailing)
            
        }.background(.ultraThinMaterial)
          
          
    }
}

