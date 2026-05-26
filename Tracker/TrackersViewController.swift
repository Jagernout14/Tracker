import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Private Properties
    private lazy var emptyScreenImage = UIImageView()
    private lazy var emptyScreenLabel = UILabel()
    
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var selectedDate = Date()
    
    private var visibleTrackers: [Tracker] {
        categories.flatMap { $0.trackers }
    }
    
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    // MARK: - Initializers
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        showPlaceholder()
        setupCollectionView()
        
        let tracker = Tracker(
            id: UUID(),
            name: "Покормить кота",
            color: .systemBlue,
            icon: "🐱"
        )
        
        let category = TrackerCategory(
            title: "Дом",
            trackers: [tracker]
        )
        
        categories = [category]
    }
    
    // MARK: - Private Methods
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
    
    private func isCompleted(trackerId: UUID, date: Date) -> Bool {
        completedTrackers.contains {
            $0.trackerId == trackerId && Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }
    
    private func completedDays(for trackerId: UUID) -> Int {
        completedTrackers.filter {
            $0.trackerId == trackerId
        }.count
    }
    
    private func toggleTracker(id: UUID, date: Date) {
        guard date <= Date() else { return }
        if let index = completedTrackers.firstIndex(where: {
            $0.trackerId == id && Calendar.current.isDate($0.date, inSameDayAs: date)
        }) {
            completedTrackers.remove(at: index)
        } else {
            completedTrackers.append(TrackerRecord(trackerId: id, date: date))
        }
    }
    
    @objc private func didTapAddTrackerButton() {
        //TODO: написать реализацию добавления трекера
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
        collectionView.reloadData()
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
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        navigationItem.leftBarButtonItem = addTrackerButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        setupSearchController()
    }
    
    private func setupNavigationBarAppearance() {
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.largeTitleTextAttributes = [.font: UIFont.systemFont(ofSize: 34, weight: .bold), .foregroundColor: UIColor(resource: .trackerBlack)]
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier: Identifiers.TrackersCollectionViewCell.cellReuseIdentifier)
    }
    
    private func setupEmptyScreenImage() {
        emptyScreenImage.image = UIImage(resource: .emptyScreenIcon)
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

//MARK: - CollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleTrackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.TrackersCollectionViewCell.cellReuseIdentifier, for: indexPath) as? TrackersCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let tracker = visibleTrackers[indexPath.item]
        
        let isTrackerCompleted = isCompleted(trackerId: tracker.id, date: selectedDate)
        let completedDaysCount = completedDays(for: tracker.id)
        
        cell.configure(with: tracker, completedDays: completedDaysCount, isCompleted: isTrackerCompleted)
        cell.onToggle = { [weak self] in
            guard let self else { return }
            
            self.toggleTracker(id: tracker.id, date: self.selectedDate)
            self.collectionView.reloadItems(at: [indexPath])
        }
        return cell
    }
}

//MARK: - CollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalInsets: CGFloat = 16
        let spacingBetweenCells: CGFloat = 9
        let totalWidth = collectionView.bounds.width
        
        let availableWidth = totalWidth - horizontalInsets * 2 - spacingBetweenCells
        let cellWidth = availableWidth / 2
        
        return CGSize(width: cellWidth, height: 148)
    }
}
