//
//  AddTrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Роман Пичугин on 01.06.2026.
//

import UIKit

final class AddTrackerEmojiCollectionViewCell:UICollectionViewCell {
    
    static let reuseIdentifier = Identifiers.AddTrackerEmojiCollectionViewCell.cellReuseIdentifier
    private let emojiLabel = UILabel()
    
    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected ? UIColor(resource: .trackerLightGrey) : .clear
            contentView.layer.cornerRadius = 16
            contentView.layer.masksToBounds = true
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupEmojiLabel()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    func configure(with emoji: String) {
        emojiLabel.text = emoji
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

