import ImageFeed
import Foundation

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ImageFeed.ProfileViewControllerProtocol?
    
    // MARK: - Call Trackers
    var viewDidLoadCalled: Bool = false
    var didTapLogoutCalled: Bool = false
    var confirmLogoutCalled: Bool = false
    
    // MARK: - Method Implementations
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapLogout() {
         didTapLogoutCalled = true
    }
    
    func confirmLogout() {
        view?.showSplashScreen()
    }
}
