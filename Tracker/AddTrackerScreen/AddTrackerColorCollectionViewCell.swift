//
//  AddTrackerColorCollectionViewCell.swift
//  Tracker
//
//  Created by Роман Пичугин on 01.06.2026.
//

import UIKit

final class AddTrackerColorCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = Identifiers.AddTrackerColorCollectionViewCell.cellReuseIdentifier
    private let colorView = UIView()
    
    override var isSelected: Bool {
        didSet {
            updateCellUI()        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupColorView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    func configure(color: UIColor) {
        colorView.backgroundColor = color
    }
    
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
