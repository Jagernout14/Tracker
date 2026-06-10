//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Роман Пичугин on 08.06.2026.
//

import CoreData

final class TrackerRecordStore {
    
    // MARK: - Private Properties
    private let context: NSManagedObjectContext
    private let trackerStore: TrackerStore
    
    // MARK: - Initializers
    init(context: NSManagedObjectContext = CoreDataStack.shared.context, trackerStore: TrackerStore = TrackerStore()) {
        self.context = context
        self.trackerStore = trackerStore
    }
    
    // MARK: - Public Methods
    func addRecord(_ record: TrackerRecord) throws {
        guard let tracker = try trackerStore.fetchTrackerCoreData(by: record.trackerId) else { return }
        
        let recordCoreData = TrackerRecordCoreData(context: context)
        recordCoreData.date = record.date
        recordCoreData.tracker = tracker
        
        try CoreDataStack.shared.saveContext()
    }
    
    func fetchRecords() throws -> [TrackerRecord] {
        let request = TrackerRecordCoreData.fetchRequest()
        let result = try context.fetch(request)
        
        return result.compactMap(makeRecord)
    }
    
    func deleteRecord(_ record: TrackerRecord) throws {
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "tracker.id == %@ AND date == %@", record.trackerId as CVarArg, record.date as CVarArg)
        
        let objects = try context.fetch(request)
        objects.forEach { context.delete($0) }
        
        try CoreDataStack.shared.saveContext()
    }
    
    // MARK: - Private Methods
    private func makeRecord(from coreData: TrackerRecordCoreData) -> TrackerRecord? {
        guard
            let date = coreData.date,
            let trackerId = coreData.tracker?.id
        else {
            return nil
        }
        
        return TrackerRecord(
            trackerId: trackerId,
            date: date
        )
    }
}
