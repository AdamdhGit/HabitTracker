//
//  LoadCoreData.swift
//  HabitTracker
//
//  Created by Adam Heidmann on 2/8/26.
//

import CoreData
import Foundation

class DataController {

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "HabitTracker")

        if inMemory {
            container.persistentStoreDescriptions.first?.url =
                URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error)")
            }
        }
    }
}
