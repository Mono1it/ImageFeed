import UIKit

final class SplashViewController: UIViewController {
    // MARK: - Private Constants
    private let storage = OAuth2TokenStorageImplementation()
    private let showAuthenticationScreenSegueIdentifier = "showAuthentication"
    
    // MARK: - Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if storage.token != nil {
            guard let token = storage.token else {
                return
            }
            
            fetchProfile(token)
            //switchToTabBarController()    //  Поместил его в fetchProfile(token)
            
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
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
}

// MARK: - Extension
extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Проверим, что переходим на авторизацию
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            
            // Доберёмся до первого контроллера в навигации.
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                return
            }
            
            // Установим делегатом контроллера наш SplashViewController
            viewController.delegate = self
            
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - Extension
extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {

        guard let token = storage.token else {
            return
        }
        
        fetchProfile(token)
    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        ProfileService.shared.fetchProfile(token) { [weak self] result in
            guard let self else { return }
            
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success(let profile):
                print("✅ Профиль получен в didAuthenticate: \(profile.username) ")
                fetchProfileImageURL(token)
                self.switchToTabBarController()
            case . failure(let error):
                print("❌ Ошибка декодирования: \(error.localizedDescription)")
                break
            }
        }
    }
    
    private func fetchProfileImageURL(_ token: String) {
        ProfileImageService.shared.fetchProfileImageURL(token) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let avatar):
                let avatarURL = ProfileImageService.shared.avatarURL
            case . failure(let error):
                print("❌ Ошибка декодирования: \(error.localizedDescription)")
                break
            }
        }
    }
}
