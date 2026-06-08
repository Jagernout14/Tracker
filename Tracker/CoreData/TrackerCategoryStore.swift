//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Роман Пичугин on 08.06.2026.
//

import CoreData

final class TrackerCategoryStore {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    func addCategory(name: String) throws {
        let category = TrackerCategoryCoreData(context: context)
        category.title = name
        
        try context.save()
    }
    
    func fetchCategories() throws -> [TrackerCategoryCoreData] {
        let request = TrackerCategoryCoreData.fetchRequest()
        return try context.fetch(request)
    }
}
