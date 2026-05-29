import UIKit

final class AddTrackerViewController: UIViewController {
    // MARK: - Private Properties
    lazy private var headerLabel = UILabel()
    lazy private var searchField = UITextField()
    lazy private var cancelButton = UIButton()
    lazy private var createButton = UIButton()
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let options = ["Категория", "Расписание"]
    
    private var selectedSchedule: Set<WeekDays> = []
    var onCreateTracker: ((Tracker) -> Void)?
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(resource: .trackerWhite)
        
        setupHeader()
        setupSearchField()
        setupCancelButton()
        setupCreateButton()
        setupTableView()
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
        
        let tracker = Tracker(id: UUID(), name: text, color: .systemCyan, icon: "🙌", schedule: [0, 1, 2, 3, 4, 5, 6])
        
        onCreateTracker?(tracker)
        dismiss(animated: true)
    }
    
    //MARK: - UI Setup
    private func setupHeader() {
        headerLabel.text = "Новая привычка"
        headerLabel.font = .systemFont(ofSize: 16, weight: .medium)
        headerLabel.textColor = .trackerBlack
        
        view.addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupSearchField() {
        searchField.placeholder = "Введите название трекера"
        searchField.backgroundColor = UIColor(resource: .trackerGrayWithOpacity)
        searchField.layer.cornerRadius = 16
        searchField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        searchField.leftViewMode = .always
        searchField.isUserInteractionEnabled = true
        
        view.addSubview(searchField)
        searchField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 38),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchField.heightAnchor.constraint(equalToConstant: 75)
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
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = 75
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = false
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150)
        ])
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
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        cell.textLabel?.text = options[indexPath.row]
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
