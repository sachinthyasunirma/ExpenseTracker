//
//  CoreDataService.swift
//  ExpenseTracker
//
//  Created by sachinthya sunirma rathnavibushana on 2025-04-22.
//

import Foundation
import CoreData

final class CoreDataService {
    static let shared = CoreDataService()

    let container: NSPersistentContainer
    var context: NSManagedObjectContext {
        container.viewContext
    }

    private init() {
        container = NSPersistentContainer(name: "ExpenseTrackerModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }

    func saveContext() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}
