import UIKit

final class ScheduleViewController: UIViewController {
    
    // MARK: - Private Properties
    lazy private var headerLabel = UILabel()
    lazy private var doneButton = UIButton()
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    var onScheduleSelected: ((Set<WeekDays>) -> Void)?
    private var selectedDays: Set<WeekDays> = []
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(resource: .trackerWhite)
        setupHeader()
        setupTableView()
        setupDoneButton()
    }
    
    // MARK: - Private Methods
    @objc private func didTapDoneButton() {
        onScheduleSelected?(selectedDays)
        dismiss(animated: true)
    }
    
    @objc private func switchToggle(_ sender: UISwitch) {
        guard let day = WeekDays(rawValue: sender.tag) else { return }
        
        if sender.isOn {
            selectedDays.insert(day)
        } else {
            selectedDays.remove(day)
        }
    }
    
    //MARK: UI Setup
    private func setupHeader() {
        headerLabel.text = "Расписание"
        headerLabel.font = .systemFont(ofSize: 16, weight: .medium)
        headerLabel.textColor = UIColor(resource: .trackerBlack)
        
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(headerLabel)
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupDoneButton() {
        doneButton.setTitle("Готово", for: .normal)
        doneButton.setTitleColor(UIColor(resource: .trackerWhite), for: .normal)
        doneButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        doneButton.backgroundColor = UIColor(resource: .trackerBlack)
        doneButton.layer.cornerRadius = 16
        
        doneButton.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        
        tableView.rowHeight = 75
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = true
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 525)
        ])
    }
}

//MARK: - TableViewDataSource
extension ScheduleViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        7
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        if let day = WeekDays(rawValue: indexPath.row) {
            cell.textLabel?.text = day.displayName
        } else {
            cell.textLabel?.text = "Неизвестно"
        }
        
        let switchView = UISwitch()
        switchView.onTintColor = UIColor(resource: .trackerBlue)
        switchView.tag = indexPath.row
        
        switchView.addTarget(self, action: #selector(switchToggle(_:)), for: .valueChanged)
        
        cell.accessoryView = switchView
        
        let background = UIView()
        background.backgroundColor = UIColor(resource: .trackerGrayWithOpacity)
        
        background.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 75)
        
        if indexPath.row == 6 {
            background.layer.cornerRadius = 16
            background.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            background.layer.masksToBounds = true
            
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        
        cell.backgroundView = background
        
        return cell
    }
}
