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
    
    @Binding var selectedDate: Date

    var body: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation{
                    toggleCompletion()
                }
            } label: {
                Image(systemName: isCompletedOnSelectedDate() ? "checkmark.circle.fill" : "circle")
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
                .strikethrough(isCompletedOnSelectedDate())
                .foregroundStyle(isCompletedOnSelectedDate() ? .secondary : .primary)
            
            Spacer()
            
            if let time = habit.visualTime {
                Text(time, format: .dateTime.hour().minute())
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .padding(.trailing)
            }
            
        }
        .padding(7)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isCompletedOnSelectedDate()
                      ? Color.green.opacity(0.15)
                      : (colorScheme == .dark
                         ? Color.white.opacity(0.1)
                         : Color.black.opacity(0.1)))
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    
        
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
        let completed = isCompletedOnSelectedDate()
        
        if colorScheme == .dark {
            return completed ? Color.green.opacity(0.1) : Color.white.opacity(0.1)
        } else {
            return completed ? Color.green.opacity(0.1) : Color.black.opacity(0.1)
        }
    }
    
    func isCompletedOnSelectedDate() -> Bool {
        let calendar = Calendar.current
        
        return habit.completions?
            .compactMap { $0 as? HabitCompletion }
            .contains { completion in
                if let date = completion.date {
                    return calendar.isDate(date, inSameDayAs: selectedDate) && completion.isCompleted
                }
                return false
            } ?? false
    }

    func toggleCompletion() {
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: selectedDate)
        
        // 1. Check if a completion exists for the selected date
        if let existing = habit.completions?
            .compactMap({ $0 as? HabitCompletion })
            .first(where: { completion in
                if let date = completion.date {
                    //return calendar.isDate(date, inSameDayAs: selectedDate)
                    return calendar.isDate(date, inSameDayAs: targetDate)
                }
                return false
            }) {
            
            // Toggle isCompleted
            existing.isCompleted.toggle()
            
            if existing.isCompleted {
                completedCount += 1
            } else {
                completedCount -= 1
            }
            
        } else {
            // 2. If no completion exists, create one
            let newCompletion = HabitCompletion(context: moc)
            newCompletion.id = UUID()
            newCompletion.date = calendar.startOfDay(for: selectedDate)
            newCompletion.isCompleted = true
            newCompletion.habit = habit
            
            completedCount += 1
        }
        
        // 3. Save context
        do {
            try moc.save()
        } catch {
            print("Save error:", error)
        }
    }



    
}

/*
#Preview {
    // 1. Create context
    let context = DataController(inMemory: true).container.viewContext

    // 2. Setup dummy data
    let previewHabit = Habit(context: context)
    previewHabit.title = "Go for a walk"
    previewHabit.isCompleted = false

    // 3. YOU NEED 'return' HERE
    return HabitRow(completedCount: .constant(0), habit: previewHabit, selectedDate: .constant(Date()))
        .environment(\.managedObjectContext, context)
        .padding()
}
*/
