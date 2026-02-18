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
    
    // Generate previous months since habit creation date.
    
    private var previousMonthsWithCompletions: [Date] {
        // 1. Get the starting point (Creation Date) or fallback to Now
        let earliest = habit.dateCreated ?? Date()
        
        let earliestMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: earliest))!
        let currentMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
        
        var months: [Date] = []
        var month = currentMonthStart
        
        // 2. Loop backwards from "Now" to "Creation"
        while month >= earliestMonthStart {
            months.append(month) // Always add the month in this range
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
                    HStack{
                        Spacer() //inverted since rightToLeft
                        Text(monthTitle(for: month))
                            //.font(.headline)
                            .padding(.bottom, 4)
                            .padding(.trailing) //inverted since rightToLeft
                           
                    }
                    
                    HabitMonthView(habit: habit, forMonth: month)
                        .padding()
                       
                    Spacer()
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .environment(\.layoutDirection, .rightToLeft)
        .frame(height: 340)
        
    }
    
    private func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}
