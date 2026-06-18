//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Роман Пичугин on 18.06.2026.
//

import UIKit

final class OnboardingViewController: UIPageViewController {
    
    // MARK: - Private Properties
    private let onboardingPages: [OnboardingPage] = [
        .init(image: UIImage(resource: .onboardingFirst), title: "Отслеживайте только то, что хотите"),
        .init(image: UIImage(resource: .onboardingSecond), title: "Даже если это не литры воды и йога")
    ]
    
    private lazy var pages: [OnboardingPageViewController] = {
        onboardingPages.map {
            let viewController = OnboardingPageViewController(page: $0)
            viewController.delegate = self
            return viewController
        }
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = onboardingPages.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = UIColor(resource: .trackerBlack)
        pageControl.pageIndicatorTintColor = UIColor(resource: .trackerBlack).withAlphaComponent(0.3)
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        return pageControl
    }()
    
    // MARK: - Initializers
    init() {
        super.init(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        setViewControllers([pages[0]], direction: .forward, animated: false)
        
        setupPageControl()
    }
    
    // MARK: - Private Methods
    private func setupPageControl() {
        view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134),
            pageControl.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
    }
    
    private func finishOnboarding() {
        UserDefaults.standard.set(true, forKey: "onboardingAlreadySeen")
        
        guard let scene = view.window?.windowScene,
              let sceneDelegate = scene.delegate as? SceneDelegate,
              let window = sceneDelegate.window
        else {
            return
        }
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
            window.rootViewController = MainTabBarController()
        }
    }
}

//MARK: - UIPageViewDataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let page = viewController as? OnboardingPageViewController,
              let index = pages.firstIndex(of: page),
              index > 0
        else {
            return nil
        }
        
        return pages[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let page = viewController as? OnboardingPageViewController,
              let index = pages.firstIndex(of: page),
              index < pages.count - 1
        else {
            return nil
        }
        
        return pages[index + 1]
    }
}

//MARK: - UIPageViewControllerDelegate
extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed,
              let currentPage = viewControllers?.first as? OnboardingPageViewController,
              let index = pages.firstIndex(of: currentPage)
        else {
            return
        }
        
        pageControl.currentPage = index
    }
}

//MARK: - PageViewControllerDelegate
extension OnboardingViewController: OnboardingPageViewControllerDelegate {
    func didTapButton(from controller: OnboardingPageViewController) {
        finishOnboarding()
    }
}
