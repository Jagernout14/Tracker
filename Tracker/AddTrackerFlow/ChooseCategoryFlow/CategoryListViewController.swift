//
//  CategoryListViewController.swift
//  Tracker
//
//  Created by Роман Пичугин on 18.06.2026.
//

import UIKit

final class CategoryListViewController: UIViewController {
    
    // MARK: - Public Properties
    var onCategorySelected: ((String) -> Void)?
    
    // MARK: - Private Properties
    private let headerLabel = UILabel()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let addCategoryButton = UIButton()
    
    private let emptyScreenLabel = UILabel()
    private let emptyScreenImage = UIImageView()
    
    private var viewModel: CategoryListViewModelProtocol
    
    // MARK: - Initializers
    init(viewModel: CategoryListViewModelProtocol = CategoryListViewModel()) {
        self.viewModel = viewModel
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
        setupPlaceholder()
        bind()
        updatePlaceholder()
    }
    
    // MARK: - Private Methods
    private func bind() {
        viewModel.onCategoriesChanged = { [weak self] in
            self?.tableView.reloadData()
            self?.updatePlaceholder()
        }
    }
    
    @objc private func didTapAddCategoryButton() {
        let viewController = AddNewCategoryViewController()
        present(viewController, animated: true)
        
    }
    
    
    
    
    
    private func editCategory(named title: String) {
        print("Редактировать:", title)
    }
    
    private func deleteCategory(at index: Int) {
        viewModel.deleteCategory(at: index)
    }
}

//MARK: UI Setup
extension CategoryListViewController {
    
    private func setupUI() {
        view.backgroundColor = UIColor(resource: .trackerWhite)
        setupHeader()
        setupAddCategoryButton()
        setupTableView()
    }
    
    private func setupHeader() {
        headerLabel.text = "Категория"
        headerLabel.font = .systemFont(ofSize: 16, weight: .medium)
        headerLabel.textColor = UIColor(resource: .trackerBlack)
        
        view.addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = 75
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = true
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -16)
        ])
    }
    
    private func setupAddCategoryButton() {
        addCategoryButton.setTitle("Добавить категорию", for: .normal)
        addCategoryButton.setTitleColor(UIColor(resource: .trackerWhite), for: .normal)
        addCategoryButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        addCategoryButton.backgroundColor = UIColor(resource: .trackerBlack)
        addCategoryButton.layer.cornerRadius = 16
        
        addCategoryButton.addTarget(self, action: #selector(didTapAddCategoryButton), for: .touchUpInside)
        
        addCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(addCategoryButton)
        
        NSLayoutConstraint.activate([
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
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
        emptyScreenLabel.text = "Привычки и события можно объединить по смыслу"
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
    
    private func setupPlaceholder() {
        setupEmptyScreenImage()
        setupEmptyScreenLabel()
    }
    
    private func updatePlaceholder() {
        let isEmpty = viewModel.numberOfRows == 0
        
        emptyScreenImage.isHidden = !isEmpty
        emptyScreenLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
}

//MARK: - TableViewDataSource
extension CategoryListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        cell.textLabel?.text = viewModel.titleForCell(at: indexPath.row)
        cell.accessoryType = viewModel.isSelected(at: indexPath.row) ? .checkmark : .none
        
        let background = UIView()
        background.backgroundColor = UIColor(resource: .trackerGrayWithOpacity)
        background.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 75)
        
        if indexPath.row == viewModel.numberOfRows - 1 {
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

//MARK: - TableViewDelegate
extension CategoryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectRow(at: indexPath.row)
        let categoryName = viewModel.categoryTitle(at: indexPath.row)
        
        onCategorySelected?(categoryName)
        
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let categoryName = viewModel.categoryTitle(at: indexPath.row)
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            
            let editAction = UIAction(title: "Редактировать") { _ in
                self?.editCategory(named: categoryName)
            }
            
            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { _ in
                self?.deleteCategory(at: indexPath.row)
            }
            
            return UIMenu(children: [editAction, deleteAction])
        }
    }
}
