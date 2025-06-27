import UIKit


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
        
        guard let token = KeychainService.shared.getToken(for: "Auth token") else {
            // Переход на AuthViewController
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            guard let navigationController = storyboard.instantiateViewController(withIdentifier: "UINavigationController") as? UINavigationController
            else {
                assertionFailure("❌ Не удалось загрузить AuthViewController из Storyboard")
                return
            }
            navigationController.delegate = self
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true)
            return
        }
        
        // Токен успешно получен
        fetchProfile(token)
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
            UIBlockingProgressHUD.dismiss()
            guard let self else { return }
            
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
            case .success:
                print("✅ Аватарка получена в fetchProfileImageURL в SplashViewController")
            case . failure(let error):
                print("❌ Ошибка декодирования в fetchProfileImageURL в SplashViewController: \(error.localizedDescription)")
            }
        }
    }
}
