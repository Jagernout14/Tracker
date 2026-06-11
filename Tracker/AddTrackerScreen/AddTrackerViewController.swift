import UIKit

final class AddTrackerViewController: UIViewController {
    
    // MARK: - Public Properties
    var onCreateTracker: ((Tracker) -> Void)?
    
    // MARK: - Private Properties
    private lazy var headerLabel = UILabel()
    private lazy var searchField = UITextField()
    private lazy var cancelButton = UIButton()
    private lazy var createButton = UIButton()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    private let options = ["Категория", "Расписание"]
    
    private var selectedSchedule: Set<WeekDays> = []
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private var scheduleText: String?
    
    private var selectedEmojiIndexPath: IndexPath?
    private var selectedColorIndexPath: IndexPath?
    
    private enum Section: Int, CaseIterable {
        case emoji
        case color
    }
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        view.backgroundColor = UIColor(resource: .trackerWhite)
        
        searchField.delegate = self
        searchField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        updateCreateButtonState()
    }
    
    // MARK: - Private Methods
    private func updateCreateButtonState() {
        let text = searchField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let isValid = !text.isEmpty
        
        createButton.isEnabled = isValid
        createButton.backgroundColor = isValid ? UIColor(resource: .trackerBlack) : UIColor(resource: .trackerDarkGray)
    }
    
    @objc private func textFieldDidChange() {
        updateCreateButtonState()
    }
    
    @objc private func didTapCancelButton() {
        dismiss(animated: true)
    }
    
    @objc private func didTapCreateButton() {
        guard let text = searchField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else { return }
        
        let tracker = Tracker(id: UUID(), name: text, color: selectedColor ?? .systemRed, icon: selectedEmoji ?? "🛑", schedule: selectedSchedule.sorted { $0.rawValue < $1.rawValue })
        
        onCreateTracker?(tracker)
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
        headerLabel.text = "Новая привычка"
        headerLabel.font = .systemFont(ofSize: 16, weight: .medium)
        headerLabel.textColor = .trackerBlack
        headerLabel.textAlignment = .center
        
        contentView.addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    private func setupSearchField() {
        searchField.placeholder = "Введите название трекера"
        searchField.backgroundColor = UIColor(resource: .trackerGrayWithOpacity)
        searchField.layer.cornerRadius = 16
        searchField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        searchField.leftViewMode = .always
        searchField.isUserInteractionEnabled = true
        
        contentView.addSubview(searchField)
        searchField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 38),
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
        cancelButton.setTitle("Отменить", for: .normal)
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
        createButton.setTitle("Создать", for: .normal)
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
            //TODO: Логика выбора категории
            print("А здесь пока ничего нет")
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.AddTrackerEmojiCollectionViewCell.cellReuseIdentifier, for: indexPath) as! AddTrackerEmojiCollectionViewCell
            cell.configure(with: MockData.emojiSymbols[indexPath.item], isSelected: indexPath == selectedEmojiIndexPath)
            cell.isSelected = indexPath == selectedEmojiIndexPath
            return cell
        case .color:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.AddTrackerColorCollectionViewCell.cellReuseIdentifier, for: indexPath) as! AddTrackerColorCollectionViewCell
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
            header.configure(with: "Цвет")
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
