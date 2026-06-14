//
//  AddTrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Роман Пичугин on 01.06.2026.
//

import UIKit

final class AddTrackerEmojiCollectionViewCell:UICollectionViewCell {
    
    // MARK: - Public Properties
    static let reuseIdentifier = Identifiers.AddTrackerEmojiCollectionViewCell.cellReuseIdentifier
    
    // MARK: - Private Properties
    private let emojiLabel = UILabel()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupEmojiLabel()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Overrides Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.backgroundColor = .clear
    }
    
    // MARK: - Public Methods
    func configure(with emoji: String, isSelected: Bool) {
        emojiLabel.text = emoji
        
        contentView.backgroundColor = isSelected ? UIColor(resource: .trackerLightGrey) : .clear
        contentView.layer.cornerRadius = 16
    }
    
    //MARK: - Setup UI
    private func setupEmojiLabel() {
        contentView.addSubview(emojiLabel)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.font = .systemFont(ofSize: 32, weight: .bold)
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
