//
//  LoadCoreData.swift
//  HabitTracker
//
//  Created by Adam Heidmann on 2/8/26.
//

import CoreData
import Foundation

class DataController  {
    
    let container = NSPersistentContainer(name: "HabitTracker")

    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
}
