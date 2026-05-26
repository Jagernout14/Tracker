import UIKit

final class TrackersCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    var onToggle: (() -> Void)?
    
    // MARK: - Private Properties
    private let cardView = UIView()
    private let emojiBackgroundView = UIView()
    
    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    
    private let daysCountLabel = UILabel()
    private let trackerButton = UIButton(type: .system)
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupConstraints()
        
        trackerButton.addTarget(self, action: #selector(didTapTrackerButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Ошибка инициализации TrackerCollectionViewCell")
    }
    
    // MARK: - Public Methods
    private func setupViews() {
        contentView.addSubview(cardView)
        cardView.addSubview(emojiBackgroundView)
        emojiBackgroundView.addSubview(emojiLabel)
        cardView.addSubview(titleLabel)
        contentView.addSubview(daysCountLabel)
        contentView.addSubview(trackerButton)
        
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        
        emojiBackgroundView.layer.cornerRadius = 12
        emojiBackgroundView.clipsToBounds = true
        emojiBackgroundView.backgroundColor = UIColor(resource: .trackerWhite).withAlphaComponent(0.3)
        
       // emojiLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        trackerButton.tintColor = UIColor(resource: .trackerWhite)
        
    }
    
    private func setupConstraints() {
        cardView.translatesAutoresizingMaskIntoConstraints = false
        emojiBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        daysCountLabel.translatesAutoresizingMaskIntoConstraints = false
        trackerButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            emojiBackgroundView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: emojiBackgroundView.bottomAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            trackerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            trackerButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            trackerButton.widthAnchor.constraint(equalToConstant: 34),
            trackerButton.heightAnchor.constraint(equalToConstant: 34),
            
            daysCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysCountLabel.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 16),
            daysCountLabel.widthAnchor.constraint(equalToConstant: 100),
            daysCountLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    func configure(with tracker: Tracker, completedDays: Int, isCompleted: Bool) {
        cardView.backgroundColor = tracker.color
        trackerButton.backgroundColor = tracker.color
        emojiLabel.text = tracker.icon
        titleLabel.text = tracker.name
        daysCountLabel.text = "\(completedDays) дней"
        
        let buttonIcon = isCompleted ? "checkmark" : "plus"
        trackerButton.setImage(UIImage(systemName: buttonIcon), for: .normal)
    }
    
    @objc private func didTapTrackerButton() {
        onToggle?()
    }
}
