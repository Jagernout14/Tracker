import UIKit

final class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMainTabBar()
    }
    
    private func setupMainTabBar() {
        let trackersViewController = TrackersViewController()
        let statisticViewController = StatisticViewController()
        
        let trackersNavigationController = UINavigationController(rootViewController: trackersViewController)
        let statisticNavigationController = UINavigationController(rootViewController: statisticViewController)
        
        trackersNavigationController.tabBarItem = UITabBarItem(title: NSLocalizedString("trackers", comment: ""), image: UIImage(resource: .trackerIcon), selectedImage: nil)
        statisticNavigationController.tabBarItem = UITabBarItem(title: NSLocalizedString("statistics", comment: ""), image: UIImage(resource: .statisticIcon), selectedImage: nil)
        
        viewControllers = [trackersNavigationController, statisticNavigationController]
    }
}
