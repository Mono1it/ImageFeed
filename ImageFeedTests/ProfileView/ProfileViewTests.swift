import XCTest
@testable import ImageFeed

final class ProfileViewTests: XCTestCase {
    // MARK: - Tests
    func testProfileViewControllerCallsViewDidLoad() {
        //given
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfilePresenterSpy()
        profileViewController.configure(profilePresenter)
        
        //when
        _ = profileViewController.view
        
        //then
        XCTAssertTrue(profilePresenter.viewDidLoadCalled)
    }
    
    func testProfileViewControllerCallsDidTapLogout() {
        //given
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfilePresenterSpy()
        profileViewController.configure(profilePresenter)
        
        //when
        profileViewController.perform(#selector(ProfileViewController.didTapExitButton))
        
        //then
        XCTAssertTrue(profilePresenter.didTapLogoutCalled)
    }
    
    func testUpdateProfileDetails() {
        //given
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfilePresenterSpy()
        profileViewController.configure(profilePresenter)
        
        //when
        profileViewController.updateProfileDetails(name: "Test Name", loginName: "@testuser", bio: "Test bio")
        
        //then
        XCTAssertEqual(profileViewController.nameLabel.text, "Test Name")
        XCTAssertEqual(profileViewController.nickNameLabel.text, "@testuser")
        XCTAssertEqual(profileViewController.descriptionLabel.text, "Test bio")
    }
    
    func testUpdateProfileAvatar() {
        //given
        let profileViewController = ProfileViewController()
        let dummyURL = URL(string: "https://example.com/avatar.jpg")!
        profileViewController.updateProfileAvatar(with: dummyURL)
        
        //when
        let expectation = XCTestExpectation(description: "Image is loaded")
        
        //then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertNotNil(profileViewController.profileImageView.image)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testShowLogoutAlert() {
        //given
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfilePresenterSpy()
        profileViewController.configure(profilePresenter)
        let window = UIWindow()
        window.rootViewController = profileViewController
        window.makeKeyAndVisible()
        
        //when
        profileViewController.showLogoutAlert()
        
        //then
        let expectation = XCTestExpectation(description: "Wait for alert presentation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let presented = profileViewController.presentedViewController as? UIAlertController
            XCTAssertNotNil(presented)
            XCTAssertEqual(presented?.title, "Пока, пока!")
            XCTAssertEqual(presented?.actions.count, 2)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testShowSplashScreen() {
        //given
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfilePresenterSpy()
        profileViewController.configure(profilePresenter)
        guard let window = UIApplication.shared.windows.first else { return }
        window.rootViewController = profileViewController
        window.makeKeyAndVisible()
        
        //when
        profileViewController.showSplashScreen()
        
        //then
        let expectation = XCTestExpectation(description: "Wait for rootController changed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(window.rootViewController is SplashViewController, "Expected SplashViewController, got \(String(describing: window.rootViewController))")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
