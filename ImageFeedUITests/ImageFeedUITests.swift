import XCTest

class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication() // переменная приложения
    
    override func setUpWithError() throws {
        continueAfterFailure = false // настройка выполнения тестов, которая прекратит выполнения тестов, если в тесте что-то пошло не так
        app.launchArguments = ["testMode"]
        app.launch() // запускаем приложение перед каждым тестом
    }
    
    func testAuth() throws {
        // тестируем сценарий авторизации
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("login")
        webView.swipeUp()
        webView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 5)).tap()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 3))
        passwordTextField.typeText("pass")
        webView.swipeUp()
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        // тестируем сценарий ленты
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 2))
        cell.swipeUp()
        
        XCTAssertTrue(cell.waitForExistence(timeout: 3))
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 2)
        let likeButton = cellToLike.buttons["like button"]
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5))
        let initialValue = likeButton.value as? String ?? "off"
        likeButton.tap()
        XCTAssertTrue(likeButton.waitForExistence(timeout: 2))
        let newValue = likeButton.value as? String ?? "off"
        XCTAssertNotEqual(initialValue, newValue, "Состояние лайка должно измениться")
        likeButton.tap()
        
        XCTAssertTrue(likeButton.waitForExistence(timeout: 2))
        
        cellToLike.tap()
        
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 2))
        // Zoom in
        image.pinch(withScale: 3, velocity: 1) // zoom in
        // Zoom out
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["nav back button white"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        // тестируем сценарий профиля
        let tabBarButton = app.tabBars.buttons.element(boundBy: 1)
        XCTAssertTrue(tabBarButton.waitForExistence(timeout: 3))
        tabBarButton.tap()
        
        XCTAssertTrue(app.staticTexts["profileName"].exists)
        XCTAssertTrue(app.staticTexts["profileUsername"].exists)
        
        app.buttons["logoutButton"].tap()
        
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
}
