//
//  HabitMonthCarousel.swift
//  HabitTracker
//
//  Created by Adam Heidmann on 2/16/26.
//

import SwiftUI

struct HabitMonthCarouselView: View {
    let habit: Habit
    private let calendar = Calendar.current
    
    @State private var currentDate = Date()
    
    // Generate only previous months where at least one completion exists
    private var previousMonthsWithCompletions: [Date] {
        guard let completions = habit.completions as? Set<HabitCompletion>, !completions.isEmpty else {
            return []
        }
        //get completions

        let earliest = completions.compactMap { $0.date }.min() ?? Date()
        let earliestMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: earliest))!
        
        let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
        
        var months: [Date] = []
        var month = currentMonthStart
        
        // Walk backwards to earliest month
        while month >= earliestMonthStart {
            // Only include month if at least one completion exists in that month
            if completions.contains(where: { completion in
                guard let date = completion.date else { return false }
                return calendar.isDate(date, equalTo: month, toGranularity: .month)
            }) {
                months.append(month)
            }
            //feb, jan, december
            month = calendar.date(byAdding: .month, value: -1, to: month)!
        }
        
        return months
    }

    // Months to show: oldest previous month ... current month
    private var monthsToShow: [Date] {
        previousMonthsWithCompletions
    }


    
    var body: some View {
        TabView {
            ForEach(monthsToShow, id: \.self) { month in
                VStack {
                    Text(monthTitle(for: month))
                        .font(.headline)
                        .padding(.bottom, 4)
                    
                    HabitMonthView(habit: habit, forMonth: month)
                        .padding()
                    Spacer()
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .environment(\.layoutDirection, .rightToLeft)
        .frame(height: 350)
    }
    
    private func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}
