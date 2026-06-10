//
//  AddTrackerSupplementaryView.swift
//  Tracker
//
//  Created by Роман Пичугин on 01.06.2026.
//

import UIKit

final class AddTrackerSupplementaryView: UICollectionReusableView {
    
    // MARK: - Public Properties
    static let identifier = Identifiers.AddTrackerSupplementaryView.headerReuseIdentifier
    
    // MARK: - Private Properties
    lazy private var headerLabel = UILabel()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHeader()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Public Methods
    func configure(with title: String) {
        headerLabel.text = title
    }
    
    //MARK: - Setup UI
    private func setupHeader() {
        addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.font = .systemFont(ofSize: 19, weight: .bold)
        headerLabel.textColor = UIColor(resource: .trackerBlack)
        headerLabel.numberOfLines = 0
        
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            headerLabel.topAnchor.constraint(equalTo: topAnchor),
            headerLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
}
