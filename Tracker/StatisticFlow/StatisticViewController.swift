//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Роман Пичугин on 02.07.2026.
//

import UIKit

final class StatisticViewController: UIViewController, TrackerRecordStoreDelegate {
    
    // MARK: - Private Properties
    private lazy var emptyScreenImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .emptyStatisticIcon)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var emptyScreenLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(resource: .trackerBlack)
        label.text = NSLocalizedString("nothing", comment: "")
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var statisticCardView = StatisticCardView()
    
    private var completedTrackers = 0 {
        didSet {
            updateUI()
        }
    }
    
    private let trackerRecordStore = TrackerRecordStore()
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        trackerRecordStore.delegate = self
        
        setupNavigationBar()
        setupUI()
        updateUI()
        loadStatistic()
    }
    
    // MARK: - Public Methods
    func storeDidUpdate() {
        loadStatistic()
    }
    
    // MARK: - Private Methods
    private func updateUI() {
        let isEmpty = completedTrackers == 0
        
        emptyScreenImage.isHidden = !isEmpty
        emptyScreenLabel.isHidden = !isEmpty
        
        statisticCardView.isHidden = isEmpty
        
        if !isEmpty {
            statisticCardView.configure(
                value: completedTrackers,
                title: NSLocalizedString("completed", comment: "")
            )
        }
    }
    
    private func loadStatistic() {
        do {
            completedTrackers = try trackerRecordStore.completedTrackersCount()
        } catch {
            print(error)
        }
    }
}

//MARK: - UI Setup
extension StatisticViewController {
    private func setupEmptyScreen() {
        view.addSubview(emptyScreenImage)
        view.addSubview(emptyScreenLabel)
        
        NSLayoutConstraint.activate([
            emptyScreenImage.widthAnchor.constraint(equalToConstant: 80),
            emptyScreenImage.heightAnchor.constraint(equalToConstant: 80),
            emptyScreenImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyScreenImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyScreenLabel.topAnchor.constraint(equalTo: emptyScreenImage.bottomAnchor, constant: 8),
            emptyScreenLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyScreenLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupStatisticCard() {
        view.addSubview(statisticCardView)
        statisticCardView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            statisticCardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            statisticCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -16),
            statisticCardView.heightAnchor.constraint(equalToConstant: 90)
        ])
        statisticCardView.configure(value: completedTrackers, title: NSLocalizedString("completed", comment: ""))
    }
    
    private func setupNavigationBar() {
        title = NSLocalizedString("statistics", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        
        appearance.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 34, weight: .bold),
            .foregroundColor: UIColor(resource: .trackerBlack)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func setupUI() {
        setupEmptyScreen()
        setupStatisticCard()
    }
}
