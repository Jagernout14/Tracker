import UIKit

final class TrackersViewController: UIViewController {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var emptyScreenImage = UIImageView()
    private lazy var emptyScreenLabel = UILabel()
    
    private var categories: [TrackerCategory]
    private var completedTrackers: [TrackerRecord]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        showPlaceholder()
    }
    
    @objc
    private func didTapAddTrackerButton() {
        
    }
    
    private func completeTracker(id: UUID, date: Date) {
        let record = TrackerRecord(trackerId: id, date: date)
        completedTrackers.append(record)
    }
    
    private func uncompleteTracker(id: UUID, date: Date) {
        //TODO: написать реализацию удаления трекера из массива выполненых
    }
    
    private func addTracker(_ tracker: Tracker, to categoryTitle: String) {
        let updatedCategories = categories.map { category in
            if category.title == categoryTitle {
                let updatedTrackers = category.trackers + [tracker]
                
                return TrackerCategory(title: category.title, trackers: updatedTrackers)
            }
            
            return category
        }
        categories = updatedCategories
    }
    
    private func addCategory(_ category: TrackerCategory) {
        categories = categories + [category]
    }
    
}

//MARK: - Setup UI
extension TrackersViewController {
    
    private func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        searchController.searchBar.searchBarStyle = .minimal
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupNavigationBar() {
        title = "Трекеры"
        
        let addTrackerButton = UIBarButtonItem(image: UIImage(resource: .addTrackerIcon), style: .plain, target: self, action: #selector(didTapAddTrackerButton))
        addTrackerButton.tintColor = UIColor(resource: .trackerBlack)
        
        navigationItem.leftBarButtonItem = addTrackerButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: createDateLabel())
        
        setupSearchController()
    }
    
    private func setupNavigationBarAppearance() {
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.largeTitleTextAttributes = [.font: UIFont.systemFont(ofSize: 34, weight: .bold), .foregroundColor: UIColor(resource: .trackerBlack)]
    }
    
    private func createDateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor(resource: .trackerBlack)
        label.backgroundColor = UIColor(resource: .trackerGray)
        label.textAlignment = .center
        label.text = currentDateString()
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.widthAnchor.constraint(equalToConstant: 77).isActive = true
        label.heightAnchor.constraint(equalToConstant: 34).isActive = true
        return label
    }
    
    private func currentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter.string(from: Date())
    }
    
    private func setupEmptyScreenImage() {
        emptyScreenImage.image = UIImage(resource: .emtyScreenIcon)
        emptyScreenImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyScreenImage)
        
        emptyScreenImage.widthAnchor.constraint(equalToConstant: 80).isActive = true
        emptyScreenImage.heightAnchor.constraint(equalToConstant: 80).isActive = true
        emptyScreenImage.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        emptyScreenImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func setupEmptyScreenLabel() {
        emptyScreenLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        emptyScreenLabel.textColor = UIColor(resource: .trackerBlack)
        emptyScreenLabel.text = "Что будем отслеживать?"
        emptyScreenLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyScreenLabel)
        
        emptyScreenLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emptyScreenLabel.topAnchor.constraint(equalTo: emptyScreenImage.bottomAnchor, constant: 8).isActive = true
    }
    
    private func setupUI() {
        setupNavigationBar()
        setupNavigationBarAppearance()
    }
    
    private func showPlaceholder() {
        setupEmptyScreenImage()
        setupEmptyScreenLabel()
    }
    
    
}
