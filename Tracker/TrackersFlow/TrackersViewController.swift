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
    
    private var searchText = ""
    private var selectedFilter = UserDefaultsService.shared.selectedFilter
    private var isFilteringResultEmpty: Bool = false
    private var hasTrackersForSelectedDate = false
    
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
        view.backgroundColor = UIColor(resource: .trackerWhite)
        
        setupUI()
        setupCollectionView()
        setupPlaceholder()
        
        print(Bundle.main.localizations)
        print(Locale.preferredLanguages)
        
        view.bringSubviewToFront(filtersButton)
        categoryStore.delegate = self
        
        loadCompletedTrackers()
        loadCategories()
        
        updatePlaceholder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.shared.report(event: "open", screen: "TrackersViewController")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.shared.report(event: "close", screen: "TrackersViewController")
    }
    
    // MARK: - Private Methods
    private func applyFiltering() {
        let effectiveDate: Date = {
            selectedFilter == .today ? Date() : currentDate
        }()
        
        let calendarWeekday = Calendar.current.component(.weekday, from: effectiveDate)
        
        guard let weekDay = WeekDays.from(calendarWeekday: calendarWeekday) else { return }
        
        let allCategories = categoryStore.fetchCategoriesFromFetchResultController()
        
        hasTrackersForSelectedDate = allCategories.contains { category in
            category.trackers.contains { tracker in
                tracker.schedule.contains(weekDay)
            }
        }
        
        visibleCategories = allCategories.compactMap { category in
            
            let filteredTrackers = category.trackers.filter { tracker in
                let matchesWeekday = tracker.schedule.contains(weekDay)
                let matchesSearch = searchText.isEmpty || tracker.name.localizedCaseInsensitiveContains(searchText)
                let matchesFilter = matchesSelectedFilter(for: tracker)
                
                return matchesWeekday &&
                matchesSearch &&
                matchesFilter
            }
            
            guard !filteredTrackers.isEmpty else { return nil }
            
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        updatePlaceholder()
        collectionView.reloadData()
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
    
    private func matchesSelectedFilter(for tracker: Tracker) -> Bool {
        switch selectedFilter {
            
        case .all:
            return true
        case .today:
            return true
        case .completed:
            return isCompleted(trackerId: tracker.id, date: currentDate)
        case .notCompleted:
            return !isCompleted(trackerId: tracker.id, date: currentDate)
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
                completedTrackers.remove(record)
            } else {
                try recordStore.addRecord(record)
                completedTrackers.insert(record)
            }
        } catch {
            assertionFailure("Ошибка изменения записи: \(error)")
        }
    }
    
    private func loadCategories() {
        applyFiltering()
    }
    
    private func loadCompletedTrackers() {
        do {
            let records = try recordStore.fetchRecords()
            completedTrackers = Set(records)
        } catch {
            assertionFailure("Не получилось загрузить записи: \(error)")
        }
    }
    
    private func editTracker(_ tracker: Tracker) {
        do {
            guard
                let trackerCoreData = try trackerStore.fetchTrackerCoreData(by: tracker.id),
                let categoryTitle = trackerCoreData.category?.title
            else { return }
            
            let viewController = AddTrackerViewController()
            let completedDays = completedDays(for: tracker.id)
            
            viewController.configure(with: tracker, category: categoryTitle, completedDays: completedDays)
            viewController.onUpdateTracker = { [weak self] tracker, categoryName in
                guard let self else { return }
                do {
                    guard let category = self.categoryStore.category(named: categoryName) else { return }
                    
                    try self.trackerStore.updateTracker(tracker, category: category)
                    self.loadCategories()
                    
                } catch {
                    assertionFailure("Ошибка обновления трекера: \(error)")
                }
            }
            
            present(viewController, animated: true)
            
        } catch {
            assertionFailure("Ошибка загрузки трекера: \(error)")
        }
    }
    
    private func deleteTracker(_ tracker: Tracker) {
        let alert = UIAlertController(
            title: NSLocalizedString("areYouSureYouWantToDeleteTracker", comment: ""),
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(
            title: NSLocalizedString("delete", comment: ""),
            style: .destructive
        ) { [weak self] _ in
            guard let self else { return }
            
            do {
                try self.trackerStore.deleteTracker(id: tracker.id)
                self.loadCategories()
            } catch {
                print(error)
            }
        }
        
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("cancel", comment: ""),
            style: .cancel
        )
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    @objc private func didTapAddTrackerButton() {
        AnalyticsService.shared.report(event: "click", screen: "TrackersViewController", item: "addTrackerButton")
        
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
        AnalyticsService.shared.report(event: "click", screen: "TrackersViewController", item: "filtersButton")
        
        let controller = FiltersViewController()
        
        controller.selectedFilter = selectedFilter
        controller.modalPresentationStyle = .pageSheet
        controller.onFilterSelected = { [weak self] filter in
            guard let self else { return }
            
            self.selectedFilter = filter
            UserDefaultsService.shared.selectedFilter = filter
            
            if filter == .today {
                self.currentDate = Date()
                
                if let datePicker = self.navigationItem.rightBarButtonItem?.customView as? UIDatePicker {
                    datePicker.setDate(Date(), animated: true)
                }
            }
            self.applyFiltering()
        }
        present(controller, animated: true)
    }
}


//MARK: - Setup UI
extension TrackersViewController {
    
    private func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("search", comment: "")
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupNavigationBar() {
        title = NSLocalizedString("trackers", comment: "")
        
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
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(resource: .trackerWhite)
        appearance.shadowColor = .clear
        
        appearance.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 34, weight: .bold),
            .foregroundColor: UIColor(resource: .trackerBlack)
        ]
    }
    
    private func setupCollectionView() {
        collectionView.backgroundColor = UIColor(resource: .trackerWhite)
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
        
        collectionView.contentInset.bottom = 82
        collectionView.scrollIndicatorInsets.bottom = 82
        collectionView.alwaysBounceVertical = true
        
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
        emptyScreenLabel.text = NSLocalizedString("whatShallWeTrack", comment: "")
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
        filtersButton.setTitle(NSLocalizedString("filters", comment: ""), for: .normal)
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
        setupFilterButton()
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
        
        if !isEmpty {
            filtersButton.isHidden = false
            return
        }
        
        if hasTrackersForSelectedDate {
            emptyScreenLabel.text = NSLocalizedString("nothingFound", comment: "")
            filtersButton.isHidden = false
        } else {
            emptyScreenLabel.text = NSLocalizedString("whatShallWeTrack", comment: "")
            filtersButton.isHidden = true
        }
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
            
            AnalyticsService.shared.report(event: "click", screen: "TrackersViewController", item: "trackerCard")
            
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

//MARK: - CollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(
                title: NSLocalizedString("edit", comment: ""),
                image: UIImage(systemName: "pencil")
            ) { [weak self] _ in
                
                AnalyticsService.shared.report(event: "click", screen: "TrackersViewController", item: "editTracker")
                
                self?.editTracker(tracker)
            }
            
            let deleteAction = UIAction(
                title: NSLocalizedString("delete", comment: ""),
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { [weak self] _ in
                
                AnalyticsService.shared.report(event: "click", screen: "TrackersViewController", item: "deleteTracker")

                self?.deleteTracker(tracker)
            }
            
            return UIMenu(children: [editAction, deleteAction])
        }
    }
}

//MARK: - TrackerCategoryStoreDelegate
extension TrackersViewController: TrackerCategoryStoreDelegate {
    func storeDidUpdate() {
        loadCategories()
    }
}

//MARK: - UISearchResultUpdating
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchText = searchController.searchBar.text ?? ""
        applyFiltering()
    }
}
