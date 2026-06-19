//
//  CategoriesViewController.swift
//  Tracker
//
//  Created by Роман Пичугин on 18.06.2026.
//

import Foundation

//MARK: - CategoryListViewModelProtocol
protocol CategoryListViewModelProtocol {
    
    var onCategoriesChanged: (() -> Void)? { get set }
    var numberOfRows: Int { get }
    
    func titleForCell(at index: Int) -> String
    func didSelectRow(at index: Int)
    func isSelected( at index: Int) -> Bool
    func categoryTitle(at index: Int) -> String
    func setSelectedCategory(_ title: String?)
    func deleteCategory(at index: Int)
}

final class CategoryListViewModel: CategoryListViewModelProtocol {
    
    // MARK: - Public Properties
    var onCategoriesChanged: (() -> Void)?
    var numberOfRows: Int {
        categories.count
    }
    
    // MARK: - Private Properties
    private let store: TrackerCategoryStore
    private var categories: [TrackerCategory] = []
    
    private var selectedCategoryTitle: String?
    
    // MARK: - Initializers
    init(store: TrackerCategoryStore = TrackerCategoryStore()) {
        self.store = store
        store.delegate = self
        fetchCategories()
    }
    
    // MARK: - Public Methods
    func titleForCell(at index: Int) -> String {
        categories[index].title
    }
    
    func didSelectRow(at index: Int) {
        selectedCategoryTitle = categories[index].title
        onCategoriesChanged?()
    }
    
    func isSelected(at index: Int) -> Bool {
        categories[index].title == selectedCategoryTitle
    }
    
    func categoryTitle(at index: Int) -> String {
        categories[index].title
    }
    
    func setSelectedCategory(_ title: String?) {
        selectedCategoryTitle = title
    }
    
    func deleteCategory(at index: Int) {
        let category = categories[index]
        do {
            try store.deleteCategory(named: category.title)
        } catch {
            print("Ошибка удаления категории:", error)
        }
    }
    
    // MARK: - Private Methods
    private func fetchCategories() {
        categories = store.fetchCategoriesFromFetchResultController()
        onCategoriesChanged?()
    }
}

//MARK: - TrackerCategoryStoreDelegate
extension CategoryListViewModel: TrackerCategoryStoreDelegate {
    func storeDidUpdate() {
        fetchCategories()
    }
}
