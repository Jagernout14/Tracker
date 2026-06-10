//
//  AddTrackerColorCollectionViewCell.swift
//  Tracker
//
//  Created by Роман Пичугин on 01.06.2026.
//

import UIKit

final class AddTrackerColorCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    static let reuseIdentifier = Identifiers.AddTrackerColorCollectionViewCell.cellReuseIdentifier
    
    // MARK: - Private Properties
    private let colorView = UIView()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupColorView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Overrides Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        colorView.layer.borderWidth = 0
        colorView.layer.borderColor = nil
    }
    
    // MARK: - Public Methods
    func configure(color: UIColor, isSelected: Bool) {
        colorView.backgroundColor = color
        contentView.layer.cornerRadius = 12
        
        if isSelected {
            contentView.layer.borderWidth = 3
            contentView.layer.borderColor =
            color.withAlphaComponent(0.3).cgColor
        } else {
            contentView.layer.borderWidth = 0
            contentView.layer.borderColor = nil
        }
    }
    
    // MARK: - Private Methods
    private func updateCellUI() {
        if isSelected {
            colorView.layer.borderWidth = 3
            colorView.layer.borderColor = colorView.backgroundColor?.withAlphaComponent(0.3).cgColor
        } else {
            colorView.layer.borderWidth = 0
            colorView.layer.borderColor = nil
        }
    }
    
    //MARK: - Setup UI
    private func setupColorView() {
        contentView.addSubview(colorView)
        colorView.translatesAutoresizingMaskIntoConstraints = false
        colorView.layer.cornerRadius = 8
        colorView.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40),
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
