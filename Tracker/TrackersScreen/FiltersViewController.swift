//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Роман Пичугин on 01.07.2026.
//

import UIKit

final class FiltersViewController: UIViewController {
    
    // MARK: - Public Properties
    var onFilterSelected: ((TrackerFilter) -> Void)?
    var currentFilter: TrackerFilter = .all
    
    // MARK: - Private Properties
    private let filters: [(title: String, filter: TrackerFilter)] = [
        (NSLocalizedString("All Trackers", comment: ""), .all),
        (NSLocalizedString("Trackers for Today", comment: ""), .today),
        (NSLocalizedString("Completed", comment: ""), .completed),
        (NSLocalizedString("Uncompleted", comment: ""), .uncompleted)
    ]
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
}

//MARK: - Setup UI
extension FiltersViewController {
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = NSLocalizedString("Filters", comment: "")
        
        setupTableView()
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FilterCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
}

//MARK: - UITableViewDataSource
extension FiltersViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
        let item = filters[indexPath.row]
        
        cell.textLabel?.text = item.title
        cell.accessoryType = .none
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension FiltersViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filter = filters[indexPath.row].filter
        onFilterSelected?(filter)
        
        dismiss(animated: true)
    }
}
