//
//  HabitRow.swift
//  HabitTracker
//
//  Created by Adam Heidmann on 2/10/26.
//

import CoreData
import SwiftUI

struct HabitRow: View {
    
    @Binding var completedCount: Int
    @ObservedObject var habit: Habit
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) private var moc

    var body: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation{
                    habit.isCompleted.toggle()
                    
                    if habit.isCompleted {
                        completedCount += 1
                    } else {
                        completedCount -= 1
                    }
                }
                
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


#Preview {
    // 1. Create context
    let context = DataController(inMemory: true).container.viewContext

    // 2. Setup dummy data
    let previewHabit = Habit(context: context)
    previewHabit.title = "Go for a walk"
    previewHabit.isCompleted = false

    // 3. YOU NEED 'return' HERE
    return HabitRow(completedCount: .constant(0), habit: previewHabit)
        .environment(\.managedObjectContext, context)
        .padding()
}
