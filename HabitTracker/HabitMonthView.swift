//
//  HabitMonthView.swift
//  HabitTracker
//
//  Created by Adam Heidmann on 2/16/26.
//

import SwiftUI

// Monthly squares view for a single month
struct HabitMonthView: View {
    let habit: Habit
    let forMonth: Date
    
    private let calendar = Calendar.current
    
    // All days in the month
    private var daysInMonth: [Date] {
        let year = calendar.component(.year, from: forMonth)
        let month = calendar.component(.month, from: forMonth)
        let range = calendar.range(of: .day, in: .month, for: forMonth)!
        return range.compactMap { day in
            calendar.date(from: DateComponents(year: year, month: month, day: day))
        }
    }
    
    // Check if habit is completed on a given day
    private func isCompleted(on date: Date) -> Bool {
        guard let completions = habit.completions as? Set<HabitCompletion> else { return false }
        return completions.contains { completion in
            completion.isCompleted && calendar.isDate(completion.date ?? .distantPast, inSameDayAs: date)
        }
    }
    
    //private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    
    private let columns = Array(
        repeating: GridItem(.fixed(40), spacing: 5),
        count: 7
    )
     
    
    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(daysInMonth, id: \.self) { day in
                Rectangle()
                    .fill(isCompleted(on: day) ? Color.green : Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .cornerRadius(6)
                    
                    .overlay(
                        Text("\(calendar.component(.day, from: day))")
                            .font(.caption)
                            .foregroundColor(.primary)
                    )
                     
            }
        }.environment(\.layoutDirection, .leftToRight)
    }
}

