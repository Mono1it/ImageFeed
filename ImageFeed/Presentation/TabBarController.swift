import Foundation
import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        // Создаём экземпляр нужного контроллера из Storyboard с помощью ранее заданного идентификатора
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
        
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfilePresenter(
            profileService: ProfileService.shared,
            profileImageService: ProfileImageService.shared
        )
        profileViewController.configure(profilePresenter)
        
        if let imagesListVC = imagesListViewController as? ImagesListViewController {
            let imagesListPresenter = ImagesListPresenter(
                imagesListService: ImagesListService.shared
            )
            imagesListVC.configure(imagesListPresenter)
        }
        
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "Tab Bar Active"),
            selectedImage: nil
        )
        viewControllers = [imagesListViewController, profileViewController]
    }
}
