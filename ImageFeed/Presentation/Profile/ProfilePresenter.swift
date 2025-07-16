import Foundation

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func didTapLogout()
    func confirmLogout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    
    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    init(profileService: ProfileServiceProtocol = ProfileService.shared, profileImageService: ProfileImageService = .shared) {
        self.profileService = profileService
        self.profileImageService = profileImageService
    }
    
    func viewDidLoad() {
        updateDetails()
        setupAvatarObserver()
        updateProfileAvatar()
    }
    
    func confirmLogout() {
        ProfileLogoutService.shared.logout()
        view?.showSplashScreen()
    }
    
    func didTapLogout() {
        view?.showLogoutAlert()
    }
    
    func updateDetails() {
        guard let profile = profileService.profile else { return }
        view?.updateProfileDetails(name: profile.name, loginName: profile.loginName, bio: profile.bio)
    }
    
    private func setupAvatarObserver() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.updateProfileAvatar()
        }
    }

    func updateProfileAvatar() {
        guard let avatarURL = profileImageService.avatarURL,
              let url = URL(string: avatarURL) else { return }
        view?.updateProfileAvatar(with: url)
        
    }
}
