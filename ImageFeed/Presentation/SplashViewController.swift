import UIKit
import SwiftKeychainWrapper

final class SplashViewController: UIViewController, UINavigationControllerDelegate {
    // MARK: - UI Elements
    lazy var splashImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "vectorLaunchScreen")
        return imageView
    }()
    
    // MARK: - Private Constants
    private let showAuthenticationScreenSegueIdentifier = "showAuthentication"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSplashImageView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let token: String? = KeychainWrapper.standard.string(forKey: "Auth token")
        if token != nil {
            guard let token = token else {
                preconditionFailure("❌ Не удалось развернуть токен")
            }
            
            fetchProfile(token)
            
        } else {
            
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            // Загружаем UINavigationController по его ID
            guard let navigationController = storyboard.instantiateViewController(withIdentifier: "UINavigationController") as? UINavigationController,
                  let authViewController = navigationController.viewControllers.first as? AuthViewController
            else {
                assertionFailure("❌ Не удалось загрузить AuthViewController из Storyboard")
                return
            }
            navigationController.delegate = self
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Private Methods
    private func switchToTabBarController() {
        // Получаем экземпляр `window` приложения
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        // Создаём экземпляр нужного контроллера из Storyboard с помощью ранее заданного идентификатора
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        // Установим в `rootViewController` полученный контроллер
        window.rootViewController = tabBarController
    }
    
    // MARK: - Setup Functions
    private func setupUI() {
        view.addSubviews(splashImageView)
        view.backgroundColor = UIColor(named: "YP Black")
    }
    
    private func setupSplashImageView() {
        NSLayoutConstraint.activate([
            splashImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            splashImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
}

// MARK: - Extension
extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        
    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        ProfileService.shared.fetchProfile(token) { [weak self] result in
            guard let self else { return }
            
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success(let profile):
                print("✅ Профиль получен в didAuthenticate: \(profile.username) ")
                self.fetchProfileImageURL(username: profile.username)
                self.switchToTabBarController()
            case . failure(let error):
                print("❌ Ошибка декодирования в fetchProfile: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchProfileImageURL(username: String) {
        ProfileImageService.shared.fetchProfileImageURL(username: username) { result in
            
            switch result {
            case .success(_):
                print("✅ Аватарка получена в fetchProfileImageURL в SplashViewController")
            case . failure(let error):
                print("❌ Ошибка декодирования в fetchProfileImageURL в SplashViewController: \(error.localizedDescription)")
            }
        }
    }
}
