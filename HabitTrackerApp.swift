//
//  HabitTrackerApp.swift
//  HabitTracker
//
//  Created by Adam Heidmann on 2/8/26.
//

import CoreData
import SwiftUI

@main
struct HabitTrackerApp: App {
    
    private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.managedObjectContext, dataController.container.viewContext)
                
        }
    }
}
