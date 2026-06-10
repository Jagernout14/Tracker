//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Роман Пичугин on 08.06.2026.
//

import CoreData
import UIKit

final class TrackerCategoryStore {
    
    // MARK: - Private Properties
    private let context: NSManagedObjectContext
    
    // MARK: - Initializers
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    // MARK: - Public Methods
    func addCategory(name: String) throws {
        let category = TrackerCategoryCoreData(context: context)
        category.title = name
        
        try CoreDataStack.shared.saveContext()
    }
    
    func fetchCategories() throws -> [TrackerCategory] {
        let request = TrackerCategoryCoreData.fetchRequest()
        let categories = try context.fetch(request)
        
        return categories.compactMap(makeCategory)
    }
    
    // MARK: - Private Methods
    private func makeCategory(from coreData: TrackerCategoryCoreData) -> TrackerCategory? {
        guard let title = coreData.title else {
            return nil
        }
        let trackers = (coreData.trackers as? Set<TrackerCoreData>)?.compactMap(makeTracker) ?? []
        
        return TrackerCategory(title: title, trackers: trackers)
    }
    
    private func makeTracker(from coreData: TrackerCoreData) -> Tracker? {
        guard
            let id = coreData.id,
            let name = coreData.name,
            let icon = coreData.icon,
            let color = coreData.color as? UIColor,
            let schedule = coreData.schedule as? [WeekDays]
        else {
            return nil
        }
        return Tracker(id: id, name: name, color: color, icon: icon, schedule: schedule)
    }
}
