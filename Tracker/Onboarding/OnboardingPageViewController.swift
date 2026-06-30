//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Роман Пичугин on 18.06.2026.
//

import UIKit

//MARK: - OnboardingPageViewControllerDelegateProtocol
protocol OnboardingPageViewControllerDelegate: AnyObject {
    func didTapButton(from controller: OnboardingPageViewController)
}

final class OnboardingPageViewController: UIViewController {
    
    // MARK: - Private Properties
    private let page: OnboardingPage
    
    private let titleLabel = UILabel()
    private let button = UIButton()
    private let backgroundImageView = UIImageView()
    
    weak var delegate: OnboardingPageViewControllerDelegate?
    
    // MARK: - Initializers
    init(page: OnboardingPage) {
        self.page = page
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
    }
    
    // MARK: - Private Methods
    @objc private func didTapButton() {
        print("Button tapped")
        delegate?.didTapButton(from: self)
    }
}

//MARK: - UI Setup
extension OnboardingPageViewController {
    private func setupUI() {
        setupBackgroundImage()
        setupButton()
        setupTitleLabel()
    }
    
    private func setupTitleLabel() {
        titleLabel.text = page.title
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = UIColor(resource: .trackerBlack)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            titleLabel.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -160)
        ])
    }
    
    private func setupButton() {
        button.setTitle(NSLocalizedString("Wow, that's technology!", comment: ""), for: .normal)
        button.setTitleColor(UIColor(resource: .trackerWhite), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(resource: .trackerBlack)
        button.layer.cornerRadius = 16
        
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupBackgroundImage() {
        backgroundImageView.image = page.image
        backgroundImageView.contentMode = .scaleAspectFill
        
        view.addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
