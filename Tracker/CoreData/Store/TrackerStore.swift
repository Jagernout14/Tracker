//
//  TrackerStore.swift
//  Tracker
//
//  Created by Роман Пичугин on 08.06.2026.
//

import CoreData
import UIKit

final class TrackerStore {
    
    // MARK: - Private Properties
    private let context: NSManagedObjectContext
    
    // MARK: - Initializers
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    // MARK: - Public Methods
    func addTracker(_ tracker: Tracker, categoryTitle: String) throws {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", categoryTitle)
        
        guard let category = try context.fetch(request).first else { return }
        
        let object = TrackerCoreData(context: context)
        
        object.id = tracker.id
        object.name = tracker.name
        object.icon = tracker.icon
        object.color = tracker.color
        object.schedule = tracker.schedule as NSArray
        object.category = category
        
        try CoreDataStack.shared.saveContext()
    }
    
    func fetchTrackers() throws -> [Tracker] {
        let request = TrackerCoreData.fetchRequest()
        let result = try context.fetch(request)
        
        return result.compactMap(makeTracker)
    }
    
    func fetchTrackerCoreData(by id: UUID) throws -> TrackerCoreData? {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        return try context.fetch(request).first
    }
    
    func deleteTracker(id: UUID) throws {
        guard let tracker = try fetchTrackerCoreData(by: id) else { return }
        context.delete(tracker)
        
        try CoreDataStack.shared.saveContext()
    }
    
    // MARK: - Private Methods
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
        return Tracker( id: id, name: name, color: color, icon: icon, schedule: schedule)
    }
}
