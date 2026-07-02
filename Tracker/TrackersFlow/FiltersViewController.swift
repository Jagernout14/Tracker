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
    var selectedFilter: TrackerFilter = .all
    
    // MARK: - Private Properties
    private lazy var headerLabel = UILabel()
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    private let filters: [TrackerFilter] = [
        .all,
        .today,
        .completed,
        .notCompleted
    ]
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(resource: .trackerWhite)
        
        setupHeader()
        setupTableView()
    }
}

// MARK: - UI Setup
extension FiltersViewController {
    private func setupHeader() {
        headerLabel.text = NSLocalizedString("filters", comment: "")
        headerLabel.font = .systemFont(ofSize: 16, weight: .medium)
        headerLabel.textColor = UIColor(resource: .trackerBlack)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(headerLabel)
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = 75
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .singleLine
        tableView.isScrollEnabled = false
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
}

// MARK: - UITableViewDataSource
extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let filter = filters[indexPath.row]
        
        cell.textLabel?.text = filter.title
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.selectionStyle = .none
        
        let shouldShowCheckmark: Bool = {
            switch filter {
            case .all:
                return false
            case .completed, .notCompleted, .today:
                return filter == selectedFilter
            }
        }()
        
        cell.accessoryType = shouldShowCheckmark ? .checkmark : .none
        cell.tintColor = UIColor(resource: .trackerBlue)
        
        let background = UIView()
        background.backgroundColor = UIColor(resource: .trackerGrayWithOpacity)
        background.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 75)
        
        if indexPath.row == 0 {
            background.layer.cornerRadius = 16
            background.layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner
            ]
            background.layer.masksToBounds = true
        }
        
        if indexPath.row == filters.count - 1 {
            background.layer.cornerRadius = 16
            background.layer.maskedCorners = [
                .layerMinXMaxYCorner,
                .layerMaxXMaxYCorner
            ]
            background.layer.masksToBounds = true
            
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        
        cell.backgroundView = background
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FiltersViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFilter = filters[indexPath.row]
        onFilterSelected?(selectedFilter)
        
        dismiss(animated: true)
    }
}
