//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Роман Пичугин on 08.06.2026.
//

import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func storeDidUpdate()
}

final class TrackerRecordStore: NSObject {
    // MARK: - Public Properties
    weak var delegate: TrackerRecordStoreDelegate?
    
    // MARK: - Private Properties
    private let context: NSManagedObjectContext
    private let trackerStore: TrackerStore
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>?
    
    // MARK: - Initializers
    init(context: NSManagedObjectContext = CoreDataStack.shared.context, trackerStore: TrackerStore = TrackerStore()) {
        self.context = context
        self.trackerStore = trackerStore
        super.init()
        setupFetchedResultsController()
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
    
    func completedTrackersCount() throws -> Int {
        let request = TrackerRecordCoreData.fetchRequest()
        return try context.count(for: request)
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
        
        return TrackerRecord(trackerId: trackerId, date: date)
    }
    
    private func setupFetchedResultsController() {
        let request = TrackerRecordCoreData.fetchRequest()
        
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        
        try? fetchedResultsController?.performFetch()
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidUpdate()
    }
}
