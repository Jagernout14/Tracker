import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Private Properties
    private lazy var emptyScreenImage = UIImageView()
    private lazy var emptyScreenLabel = UILabel()
    private lazy var filtersButton = UIButton()
    
    private var completedTrackers: Set<TrackerRecord> = []
    private var currentDate = Date()
    
    private var visibleCategories: [TrackerCategory] = []
    
    private let categoryStore = TrackerCategoryStore()
    private let trackerStore = TrackerStore()
    private let recordStore = TrackerRecordStore()
    
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    // MARK: - Initializers
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupCollectionView()
        setupPlaceholder()
        
        categoryStore.delegate = self
        
        loadCompletedTrackers()
        loadCategories()
        
        updatePlaceholder()
        
    }
    
    // MARK: - Private Methods
    private func applyFiltering() {
        let calendarWeekday = Calendar.current.component(.weekday, from: currentDate)
        
        guard let weekDay = WeekDays.from(calendarWeekday: calendarWeekday) else {
            return
        }
        
        let allCategories = categoryStore.fetchCategoriesFromFetchResultController()
        
        visibleCategories = allCategories.compactMap { category in
            let filtered = category.trackers.filter {
                $0.schedule.contains(weekDay)
            }
            
            guard !filtered.isEmpty else { return nil }
            
            return TrackerCategory(title: category.title, trackers: filtered)
        }
    }
    
    private func completeTracker(id: UUID, date: Date) -> Bool {
        let record = TrackerRecord(trackerId: id, date: date)
        return completedTrackers.contains(record)
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
        let record = TrackerRecord(trackerId: id, date: date)
        
        do {
            if completedTrackers.contains(record) {
                try recordStore.deleteRecord(record)
            } else {
                try recordStore.addRecord(record)
                completedTrackers.insert(record)
            }
        } catch {
            assertionFailure("Ошибка изменения записи: \(error)")
        }
    }
    
    private func loadCategories() {
        visibleCategories = categoryStore.fetchCategoriesFromFetchResultController()
        applyFiltering()
        collectionView.reloadData()
        updatePlaceholder()
    }
    
    private func loadCompletedTrackers() {
        do {
            let records = try recordStore.fetchRecords()
            completedTrackers = Set(records)
        } catch {
            assertionFailure("Не получилось загрузить записи: \(error)")
        }
    }
    
    @objc private func didTapAddTrackerButton() {
        let viewController = AddTrackerViewController()
        viewController.modalPresentationStyle = .pageSheet
        
        viewController.onCreateTracker = { [weak self] tracker, categoryName in
            guard let self else { return }

            guard let category = self.categoryStore.category(named: categoryName) else {
                print("Категория не найдена")
                return
            }

            do {
                try self.trackerStore.addTracker(tracker, category: category)

                self.loadCategories()
                self.collectionView.reloadData()
                self.updatePlaceholder()

            } catch {
                print("Ошибка сохранения трекера:", error)
            }
        }
        
        present(viewController, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        applyFiltering()
        collectionView.reloadData()
        updatePlaceholder()
    }
    
    @objc private func didTapFiltersButton() {
        
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
        collectionView.register(TrackersSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Identifiers.TrackersSupplementaryView.headerReuseIdentifier)
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
        emptyScreenLabel.textAlignment = .center
        emptyScreenLabel.numberOfLines = 0
        emptyScreenLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyScreenLabel)
        
        NSLayoutConstraint.activate([
            emptyScreenLabel.topAnchor.constraint(equalTo: emptyScreenImage.bottomAnchor, constant: 8),
            emptyScreenLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            emptyScreenLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupFilterButton() {
        filtersButton.setTitle("Фильтры", for: .normal)
        filtersButton.setTitleColor(UIColor(resource: .trackerWhite), for: .normal)
        filtersButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        filtersButton.backgroundColor = UIColor(resource: .trackerBlue)
        filtersButton.layer.cornerRadius = 16
        filtersButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filtersButton)
        view.bringSubviewToFront(filtersButton)
        
        filtersButton.addTarget(self, action: #selector(didTapFiltersButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            filtersButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filtersButton.heightAnchor.constraint(equalToConstant: 50),
            filtersButton.widthAnchor.constraint(equalToConstant: 114)
        ])
    }
    
    private func setupUI() {
        setupNavigationBar()
        setupNavigationBarAppearance()
    }
    
    private func setupPlaceholder() {
        setupEmptyScreenImage()
        setupEmptyScreenLabel()
    }
    
    private func updatePlaceholder() {
        let isEmpty = visibleCategories.isEmpty
        
        emptyScreenImage.isHidden = !isEmpty
        emptyScreenLabel.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }
}

//MARK: - CollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.TrackersCollectionViewCell.cellReuseIdentifier, for: indexPath) as? TrackersCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        
        let isTrackerCompleted = isCompleted(trackerId: tracker.id, date: currentDate)
        let completedDaysCount = completedDays(for: tracker.id)
        
        cell.configure(with: tracker, completedDays: completedDaysCount, isCompleted: isTrackerCompleted)
        cell.onToggle = { [weak self, weak cell] in
            guard let self,
                  let cell,
                  let indexPath = self.collectionView.indexPath(for: cell)
            else { return }
            
            let calendar = Calendar.current
            if self.currentDate > Date() && !calendar.isDate(self.currentDate, inSameDayAs: Date()) {
                return
            }
            
            self.toggleTracker(id: tracker.id, date: self.currentDate)
            self.collectionView.reloadItems(at: [indexPath])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Identifiers.TrackersSupplementaryView.headerReuseIdentifier, for: indexPath) as? TrackersSupplementaryView else {
            return UICollectionReusableView()
        }
        let category = visibleCategories[indexPath.section]
        header.configure(with: category.title)
        return header
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 50)
    }
}

//MARK: - TrackerCategoryStoreDelegate
extension TrackersViewController: TrackerCategoryStoreDelegate {
    func storeDidUpdate() {
        loadCategories()
    }
}
