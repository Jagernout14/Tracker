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
    private lazy var colorView = UIView()
    
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
        
        contentView.layer.borderWidth = isSelected ? 3 : 0
        contentView.layer.borderColor = isSelected ? color.withAlphaComponent(0.3).cgColor : nil
    }
    
    // MARK: - Private Methods
    private func updateCellUI() {
        colorView.layer.borderWidth = isSelected ? 3 : 0
        colorView.layer.borderColor = isSelected ? colorView.backgroundColor?.withAlphaComponent(0.3).cgColor : nil
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
