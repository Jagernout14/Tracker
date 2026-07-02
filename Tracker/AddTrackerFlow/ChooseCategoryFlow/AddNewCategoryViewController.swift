//
//  AddNewCategoryViewController.swift
//  Tracker
//
//  Created by Роман Пичугин on 19.06.2026.
//

import UIKit

final class AddNewCategoryViewController: UIViewController {
    
    // MARK: - Public Properties
    var categoryToEdit: String?
    
    var onCategoryCreated: ((String) -> Void)?
    var onCategoryEdit: ((String, String) -> Void)?
    
    // MARK: - Private Properties
    private lazy var headerLabel = UILabel()
    private lazy var textField = UITextField()
    private lazy var doneButton = UIButton()
    
    private let categoryStore = TrackerCategoryStore()
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        updateDoneButtonState()
        configureScreenState()
    }
    
    // MARK: - Private Methods
    private func updateDoneButtonState() {
        let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let isEnabled = !text.isEmpty
        doneButton.isEnabled = isEnabled
        doneButton.backgroundColor = isEnabled ? UIColor(resource: .trackerBlack) : UIColor(resource: .trackerDarkGray)
    }
    
    private func configureScreenState() {
        if let categoryToEdit {
            headerLabel.text = NSLocalizedString("editCategory", comment: "")
            textField.text = categoryToEdit
            doneButton.setTitle(NSLocalizedString("done", comment: ""), for: .normal)
        } else {
            headerLabel.text = NSLocalizedString("newCategory", comment: "")
            textField.text = ""
            doneButton.setTitle(NSLocalizedString("create", comment: ""), for: .normal)
        }
    }
    
    @objc private func textDidChange() {
        updateDoneButtonState()
    }
    
    @objc private func didTapDoneButton() {
        guard let title = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !title.isEmpty
        else { return }
        
        do {
            if let oldTitle = categoryToEdit {
                try categoryStore.updateCategory(oldTitle: oldTitle, newTitle: title)
            } else {
                try categoryStore.addCategory(name: title)
            }
            dismiss(animated: true)
            
        } catch {
            print("Ошибка сохранения категории:", error)
        }
    }
}

//MARK: - UI Setup
extension AddNewCategoryViewController {
    
    private func setupUI() {
        view.backgroundColor = UIColor(resource: .trackerWhite)
        
        setupHeader()
        setupTextField()
        setupDoneButton()
    }
    
    private func setupHeader() {
        headerLabel.text = NSLocalizedString("newCategory", comment: "")
        headerLabel.font = .systemFont(ofSize: 16, weight: .medium)
        headerLabel.textColor = UIColor(resource: .trackerBlack)
        
        view.addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupTextField() {
        textField.placeholder = NSLocalizedString("enterCategoryName", comment: "")
        textField.backgroundColor = UIColor(resource: .trackerGrayWithOpacity)
        textField.layer.cornerRadius = 16
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        view.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 38),
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    func setupDoneButton() {
        doneButton.setTitle(NSLocalizedString("done", comment: ""), for: .normal)
        doneButton.layer.cornerRadius = 16
        
        doneButton.addTarget(self,action: #selector(didTapDoneButton), for: .touchUpInside)
        
        view.addSubview(doneButton)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
