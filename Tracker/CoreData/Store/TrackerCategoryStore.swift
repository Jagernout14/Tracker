//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Роман Пичугин on 08.06.2026.
//

import CoreData
import UIKit

protocol TrackerCategoryStoreDelegate: AnyObject {
    func storeDidUpdate()
}

final class TrackerCategoryStore: NSObject {
    
    // MARK: - Public Properties
    weak var delegate: TrackerCategoryStoreDelegate?
    
    var sectionAmount: Int {
        fetchedResultsController?.sections?.count ?? 0
    }
    
    // MARK: - Private Properties
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
    
    // MARK: - Initializers
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
        super.init()
        
        setupFetchedResultsController()
    }
    
    // MARK: - Public Methods
    func category(named title: String) -> TrackerCategoryCoreData? {
        fetchedResultsController?.fetchedObjects?.first {
            $0.title == title
        }
    }
    
    func addCategory(name: String) throws {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", name)
        request.fetchLimit = 1
        
        let existing = try context.fetch(request)
        
        guard existing.isEmpty else { return }
        
        let category = TrackerCategoryCoreData(context: context)
        category.title = name
        
        try context.save()
    }
    
    func fetchCategoriesFromFetchResultController() -> [TrackerCategory] {
        guard let objects = fetchedResultsController?.fetchedObjects else {
            return []
        }
        return objects.compactMap(makeCategory)
    }
    
    func numberOfItems(in section: Int) -> Int {
        fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    func category( at indexPath: IndexPath) -> TrackerCategoryCoreData? {
        guard let object = fetchedResultsController?.object(at: indexPath) else {
            assertionFailure("Обьектов по IndexPath нету")
            return nil
        }
        return object
    }
    
    func deleteCategory(named title: String) throws {
        let request = TrackerCategoryCoreData.fetchRequest()
        
        request.predicate = NSPredicate(format: "title == %@", title)
        
        guard let category = try context.fetch(request).first else { return }
        context.delete(category)
        
        try context.save()
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
    
    private func setupFetchedResultsController() {
        let request = TrackerCategoryCoreData.fetchRequest()
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
        
        try? fetchedResultsController?.performFetch()
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidUpdate()
    }
}
