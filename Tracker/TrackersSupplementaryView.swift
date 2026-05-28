import UIKit

final class TrackersSupplementaryView: UICollectionReusableView {
    
    static let identifier = Identifiers.TrackersSupplementaryView.headerReuseIdentifier
    
    private let headerLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHeader()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Ошибка инициализации TrackersSupplementaryView")
    }
    
    func configure(with title: String) {
        headerLabel.text = title
    }
    
    private func setupHeader() {
        addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.font = .systemFont(ofSize: 19, weight: .bold)
        headerLabel.textColor = UIColor(resource: .trackerBlack)
        headerLabel.numberOfLines = 0
        
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -28),
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
}
