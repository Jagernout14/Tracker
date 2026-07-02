//
//  StatisticCardView.swift
//  Tracker
//
//  Created by Роман Пичугин on 02.07.2026.
//

import UIKit

final class StatisticCardView: UIView {
    
    // MARK: - Private Properties
    private let gradientLayer = CAGradientLayer()
    
    private lazy var contentView = UIView()
    private lazy var countLabel = UILabel()
    private lazy var titleLabel = UILabel()
    
    func configure(value: Int, title: String) {
        countLabel.text = "\(value)"
        titleLabel.text = title
    }
    
    // MARK: - Overrides Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = bounds
    }
}

// MARK: - UI Setup
extension StatisticCardView {
    private func setupUI() {
        setupGradient()
        setupContentView()
        setupLabels()
    }
    
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor.red.cgColor,
            UIColor.green.cgColor,
            UIColor.blue.cgColor
        ]
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = 16
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setupContentView() {
        contentView.backgroundColor = UIColor(resource: .trackerWhite)
        contentView.layer.cornerRadius = 15
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: 1),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 1),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1)
        ])
    }
    
    func setupLabels() {
        countLabel.font = .systemFont(ofSize: 34, weight: .bold)
        countLabel.textColor = UIColor(resource: .trackerBlack)
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = UIColor(resource: .trackerBlack)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(countLabel)
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            countLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            countLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
}
