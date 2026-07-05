import UIKit

final class AddTrackerViewController: UIViewController {
    
    // MARK: - Public Properties
    var onCreateTracker: ((Tracker, String) -> Void)?
    var onUpdateTracker: ((Tracker, String) -> Void)?
    
    // MARK: - Private Properties
    private lazy var headerLabel = UILabel()
    private lazy var searchField = UITextField()
    private lazy var cancelButton = UIButton()
    private lazy var createButton = UIButton()
    private lazy var completedDaysLabel = UILabel()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    private var editingTracker: Tracker?
    
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    private let options = [
        NSLocalizedString("categoryName", comment: ""),
        NSLocalizedString("categoryName", comment: "")
    ]
    
    private var selectedSchedule: Set<WeekDays> = []
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private var scheduleText: String?
    
    private var selectedEmojiIndexPath: IndexPath?
    private var selectedColorIndexPath: IndexPath?
    private var selectedCategory: String?
    
    private enum Section: Int, CaseIterable {
        case emoji
        case color
    }
    
    private var completedDays = 0
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        if let tracker = editingTracker {
            editTracker(with: tracker)
        }
        view.backgroundColor = UIColor(resource: .trackerWhite)
        
        searchField.delegate = self
        searchField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        updateCreateButtonState()
    }
    
    // MARK: - Public Methods
    func configure(with tracker: Tracker, category: String, completedDays: Int) {
        editingTracker = tracker
        selectedCategory = category
        selectedSchedule = Set(tracker.schedule)
        selectedEmoji = tracker.icon
        selectedColor = tracker.color
        
        self.completedDays = completedDays
        
        scheduleText = tracker.schedule
            .sorted { $0.rawValue < $1.rawValue }
            .map(\.shortName)
            .joined(separator: ", ")
    }
    
    // MARK: - Private Methods
    private func updateCreateButtonState() {
        let text = searchField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let isValid = !text.isEmpty &&
        selectedCategory != nil &&
        !selectedSchedule.isEmpty &&
        selectedEmoji != nil &&
        selectedColor != nil
        
        createButton.isEnabled = isValid
        createButton.backgroundColor = isValid ? UIColor(resource: .trackerBlack) : UIColor(resource: .trackerDarkGray)
    }
    
    private func editTracker(with tracker: Tracker) {
        headerLabel.text = NSLocalizedString("editHabit", comment: "")
        createButton.setTitle(NSLocalizedString("save", comment: ""), for: .normal)
        
        completedDaysLabel.text = String.localizedStringWithFormat(NSLocalizedString("days_count", comment: ""), completedDays)
        completedDaysLabel.isHidden = false
        searchField.text = tracker.name
        
        tableView.reloadData()
        
        if let emojiIndex = MockData.emojiSymbols.firstIndex(of: tracker.icon) {
            selectedEmojiIndexPath = IndexPath(item: emojiIndex, section: Section.emoji.rawValue)
        }
        
        if let colorIndex = MockData.colors.firstIndex(where: { $0.isEqual(tracker.color) }) {
            selectedColorIndexPath = IndexPath(item: colorIndex, section: Section.color.rawValue)
        }
        
        collectionView.reloadData()
        
        updateCreateButtonState()
    }
    
    @objc private func textFieldDidChange() {
        updateCreateButtonState()
    }
    
    @objc private func didTapCancelButton() {
        dismiss(animated: true)
    }
    
    @objc private func didTapCreateButton() {
        guard let text = searchField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty,
              let categoryName = selectedCategory,
              let emoji = selectedEmoji,
              let color = selectedColor
        else { return }
        
        let tracker = Tracker(id: editingTracker?.id ?? UUID(), name: text, color: color, icon: emoji, schedule: selectedSchedule.sorted { $0.rawValue < $1.rawValue })
        
        if editingTracker == nil {
            onCreateTracker?(tracker, categoryName)
        } else {
            onUpdateTracker?(tracker, categoryName)
        }
        
        dismiss(animated: true)
    }
    
    //MARK: - UI Setup
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }
    
    private func setupHeader() {
        headerLabel.text = NSLocalizedString("newHabit", comment: "")
        headerLabel.font = .systemFont(ofSize: 16, weight: .medium)
        headerLabel.textColor = .trackerBlack
        headerLabel.textAlignment = .center
        
        completedDaysLabel.font = .systemFont(ofSize: 32, weight: .bold)
        completedDaysLabel.textColor = .trackerBlack
        completedDaysLabel.textAlignment = .center
        completedDaysLabel.isHidden = true
        
        contentView.addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(completedDaysLabel)
        completedDaysLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            completedDaysLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 24),
            completedDaysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            completedDaysLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    private func setupSearchField() {
        searchField.placeholder = NSLocalizedString("enterTrackerName", comment: "")
        searchField.backgroundColor = UIColor(resource: .trackerGrayWithOpacity)
        searchField.layer.cornerRadius = 16
        searchField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        searchField.leftViewMode = .always
        searchField.isUserInteractionEnabled = true
        
        contentView.addSubview(searchField)
        searchField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: completedDaysLabel.bottomAnchor, constant: 24),
            searchField.heightAnchor.constraint(equalToConstant: 75),
            searchField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = 75
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = false
        
        contentView.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.heightAnchor.constraint(equalToConstant: 150),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 24)
        ])
    }
    
    private func setupCollectionView() {
        configureCollectionViewLayout()
        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.isScrollEnabled = false
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(AddTrackerEmojiCollectionViewCell.self, forCellWithReuseIdentifier: Identifiers.AddTrackerEmojiCollectionViewCell.cellReuseIdentifier)
        collectionView.register(AddTrackerColorCollectionViewCell.self, forCellWithReuseIdentifier: Identifiers.AddTrackerColorCollectionViewCell.cellReuseIdentifier)
        collectionView.register(AddTrackerSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Identifiers.AddTrackerSupplementaryView.headerReuseIdentifier)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 24),
            collectionView.heightAnchor.constraint(equalToConstant: 400),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
    
    private func setupCancelButton() {
        cancelButton.setTitle(NSLocalizedString("cancel", comment: ""), for: .normal)
        cancelButton.setTitleColor(UIColor(resource: .trackerRed), for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor(resource: .trackerRed).cgColor
        cancelButton.layer.cornerRadius = 16
        
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupCreateButton() {
        createButton.setTitle(NSLocalizedString("create", comment: ""), for: .normal)
        createButton.setTitleColor(UIColor(resource: .trackerWhite), for: .normal)
        createButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        createButton.isEnabled = false
        createButton.backgroundColor = UIColor(resource: .trackerDarkGray)
        createButton.layer.cornerRadius = 16
        
        createButton.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
        
        view.addSubview(createButton)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),
            createButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupUI() {
        setupScrollView()
        
        setupHeader()
        setupSearchField()
        setupTableView()
        setupCollectionView()
        
        setupCancelButton()
        setupCreateButton()
    }
    
    private func configureCollectionViewLayout() {
        let layout = UICollectionViewFlowLayout()
        
        layout.itemSize = CGSize(width: 52, height: 52)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 0
        
        collectionView.collectionViewLayout = layout
    }
}

//MARK: - TableViewDataSource
extension AddTrackerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        
        cell.textLabel?.text = options[indexPath.row]
        if indexPath.row == 0 {
            cell.detailTextLabel?.text = selectedCategory
            cell.detailTextLabel?.textColor = UIColor(resource: .trackerDarkGray)
        }
        
        if indexPath.row == 1 {
            cell.detailTextLabel?.text = scheduleText
            cell.detailTextLabel?.textColor = UIColor(resource: .trackerDarkGray)
        }
        
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .clear
        
        let background = UIView()
        background.backgroundColor = UIColor(resource: .trackerGrayWithOpacity)
        background.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 75)
        
        if indexPath.row == options.count - 1 {
            background.layer.cornerRadius = 16
            background.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            background.layer.masksToBounds = true
        }
        
        if indexPath.row == options.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        cell.backgroundView = background
        
        return cell
    }
}

//MARK: - TableViewDelegate
extension AddTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            let viewModel = CategoryListViewModel()
            viewModel.setSelectedCategory(selectedCategory)
            let viewController = CategoryListViewController(viewModel: viewModel)
            
            viewController.onCategorySelected = { [weak self] categoryName in
                self?.selectedCategory = categoryName
                self?.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                self?.updateCreateButtonState()
            }
            
            present(viewController, animated: true)
            
        case 1:
            let viewController = ScheduleViewController()
            viewController.modalPresentationStyle = .pageSheet
            
            viewController.onScheduleSelected = {[weak self] days in
                self?.selectedSchedule = days
                let sortedDays = days.sorted { $0.rawValue < $1.rawValue }
                self?.scheduleText = sortedDays
                    .map { $0.shortName }
                    .joined(separator: ", ")
                
                self?.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
            }
            
            present(viewController, animated: true)
        default:
            break
        }
    }
}

//MARK: - TextFieldDelegate
extension AddTrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - CollectionViewDataSource
extension AddTrackerViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {
            return 0
        }
        
        switch section {
        case .emoji:
            return MockData.emojiSymbols.count
        case .color:
            return 18
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            return UICollectionViewCell()
        }
        
        switch section {
        case .emoji:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.AddTrackerEmojiCollectionViewCell.cellReuseIdentifier, for: indexPath) as? AddTrackerEmojiCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: MockData.emojiSymbols[indexPath.item], isSelected: indexPath == selectedEmojiIndexPath)
            cell.isSelected = indexPath == selectedEmojiIndexPath
            return cell
        case .color:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.AddTrackerColorCollectionViewCell.cellReuseIdentifier, for: indexPath) as? AddTrackerColorCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(color: MockData.colors[indexPath.item], isSelected: indexPath == selectedColorIndexPath)
            cell.isSelected = indexPath == selectedColorIndexPath
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let section = Section(rawValue: indexPath.section),
              let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Identifiers.AddTrackerSupplementaryView.headerReuseIdentifier, for: indexPath) as? AddTrackerSupplementaryView else {
            return UICollectionReusableView()
        }
        
        switch section {
        case .emoji:
            header.configure(with: "Emoji")
        case .color:
            header.configure(with: NSLocalizedString("color", comment: ""))
        }
        return header
    }
}

//MARK: - CollectionViewDelegateFlowLayout
extension AddTrackerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch Section(rawValue: section) {
        case .emoji:
            UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0)
        case .color:
            UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        case .none:
                .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }
        
        switch section {
        case .emoji:
            let previousIndexPath = selectedEmojiIndexPath
            
            selectedEmojiIndexPath = indexPath
            selectedEmoji = MockData.emojiSymbols[indexPath.item]
            
            var itemsToReload = [indexPath]
            if let previousIndexPath {
                itemsToReload.append(previousIndexPath)
            }
            
            collectionView.reloadItems(at: itemsToReload)
            
        case .color:
            let previousIndexPath = selectedColorIndexPath
            
            selectedColorIndexPath = indexPath
            selectedColor = MockData.colors[indexPath.item]
            
            var itemsToReload = [indexPath]
            if let previousIndexPath {
                itemsToReload.append(previousIndexPath)
            }
            
            collectionView.reloadItems(at: itemsToReload)
        }
        updateCreateButtonState()
    }
}
