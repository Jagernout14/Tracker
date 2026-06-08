//
//  TrackerStore.swift
//  Tracker
//
//  Created by Роман Пичугин on 08.06.2026.
//

import CoreData
import UIKit

final class TrackerStore {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    func addTracker(_ tracker: Tracker) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.icon = tracker.icon
        
        trackerCoreData.color = tracker.color
        trackerCoreData.schedule = NSArray(array: tracker.schedule)
        
        try context.save()
    }
    
    func fetchTrackers() throws -> [Tracker] {
        let request = TrackerCoreData.fetchRequest()
        let result = try context.fetch(request)
        
        return result.compactMap { coreData in
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
}
