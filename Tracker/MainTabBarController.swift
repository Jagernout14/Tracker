import UIKit

final class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMainTabBar()
    }
    
    private func setupMainTabBar() {
        let trackersViewController = TrackersViewController()
        let statisticViewController = StatisticViewController()
        
        let trackersTabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(resource: .trackerIcon), selectedImage: nil)
        trackersViewController.tabBarItem = trackersTabBarItem
        
        let statisticTabBarItem = UITabBarItem(title: "Статистика", image: UIImage(resource: .statisticIcon), selectedImage: nil)
        statisticViewController.tabBarItem = statisticTabBarItem
        
        viewControllers = [trackersViewController, statisticViewController]
    }
}
