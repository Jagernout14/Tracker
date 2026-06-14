//
//  CoreDataStack.swift
//  Tracker
//
//  Created by Роман Пичугин on 08.06.2026.
//

import CoreData

final class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tracker")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Ошибка persistent Container: \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() throws {
        let context = persistentContainer.viewContext
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            throw error
        }
    }
}
