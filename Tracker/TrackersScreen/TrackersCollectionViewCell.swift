import UIKit

final class TrackersCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    var onToggle: (() -> Void)?
    
    // MARK: - Private Properties
    private lazy var cardView = UIView()
    private lazy var emojiBackgroundView = UIView()
    private lazy var emojiLabel = UILabel()
    private lazy var titleLabel = UILabel()
    
    private lazy var daysCountLabel = UILabel()
    private lazy var trackerButton = UIButton(type: .system)
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCell()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Public Methods
    func configure(with tracker: Tracker, completedDays: Int, isCompleted: Bool) {
        cardView.backgroundColor = tracker.color
        trackerButton.backgroundColor = tracker.color
        emojiLabel.text = tracker.icon
        titleLabel.text = tracker.name
        daysCountLabel.text = String.localizedStringWithFormat(NSLocalizedString("days_count", comment: ""), completedDays)
        
        let buttonIcon = TrackerButtonIcons.icon(for: isCompleted).rawValue
        
        trackerButton.setImage(UIImage(systemName: buttonIcon), for: .normal)
        trackerButton.alpha = isCompleted ? 0.3 : 1.0
    }
    
    // MARK: - Private Methods
    private func setupCell() {
        setupCardView()
        setupEmoji()
        setupTitleLabel()
        setupDaysCountLabel()
        setupTrackerButton()
    }
    
    private func setupCardView() {
        contentView.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    private func setupEmoji() {
        cardView.addSubview(emojiBackgroundView)
        emojiBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        emojiBackgroundView.layer.cornerRadius = 12
        emojiBackgroundView.clipsToBounds = true
        emojiBackgroundView.backgroundColor = UIColor(resource: .trackerWhite).withAlphaComponent(0.3)
        
        emojiBackgroundView.addSubview(emojiLabel)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        NSLayoutConstraint.activate([
            emojiBackgroundView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor)
        ])
    }
    
    private func setupTitleLabel() {
        cardView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor(resource: .trackerWhite)
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 2
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -6),
            titleLabel.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    private func setupDaysCountLabel() {
        contentView.addSubview(daysCountLabel)
        daysCountLabel.translatesAutoresizingMaskIntoConstraints = false
        daysCountLabel.textColor = UIColor(resource: .trackerBlack)
        daysCountLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        NSLayoutConstraint.activate([
            daysCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysCountLabel.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 16),
            daysCountLabel.widthAnchor.constraint(equalToConstant: 100),
            daysCountLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    private func setupTrackerButton() {
        contentView.addSubview(trackerButton)
        trackerButton.translatesAutoresizingMaskIntoConstraints = false
        trackerButton.layer.cornerRadius = 17
        trackerButton.clipsToBounds = true
        trackerButton.tintColor = UIColor(resource: .trackerWhite)
        trackerButton.backgroundColor = cardView.backgroundColor
        
        trackerButton.addTarget(self, action: #selector(didTapTrackerButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            trackerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            trackerButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            trackerButton.widthAnchor.constraint(equalToConstant: 34),
            trackerButton.heightAnchor.constraint(equalToConstant: 34),
        ])
    }
    
    @objc private func didTapTrackerButton() {
        onToggle?()
    }
}
