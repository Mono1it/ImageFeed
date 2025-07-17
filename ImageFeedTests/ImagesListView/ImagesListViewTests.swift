import XCTest
@testable import ImageFeed

final class ImagesListViewTests: XCTestCase {
    // MARK: - Test Data
    private let testPhoto = Photo(
        id: "test_id",
        size: CGSize(width: 100, height: 100),
        createdAt: Date(),
        welcomeDescription: "Test Description",
        thumbImageURL: "https://example.com/thumb.jpg",
        largeImageURL: "https://example.com/large.jpg",
        isLiked: false
    )
    
    private func makePhoto(id: String) -> Photo {
        Photo(id: id,
              size: CGSize(width: 10, height: 10),
              createdAt: Date(),
              welcomeDescription: nil,
              thumbImageURL: "https://url",
              largeImageURL: "https://url",
              isLiked: false)
    }
    
    // MARK: - Tests
    func testImagesListViewViewControllerCallsViewDidLoad() {
        //given
        let imagesListViewController = ImagesListViewController()
        let imagesListPresenter = ImagesListPresenterSpy()
        imagesListViewController.configure(imagesListPresenter)
        
        let tableView = UITableView()
        imagesListViewController.setValue(tableView, forKey: "tableView")
        
        //when
        _ = imagesListViewController.view
        
        //then
        XCTAssertTrue(imagesListPresenter.viewDidLoadCalled)
    }
    
    func testImagesListViewViewControllerTableViewNumberOfRows() {
        //given
        let imagesListViewController = ImagesListViewController()
        let imagesListPresenter = ImagesListPresenterSpy()
        imagesListViewController.configure(imagesListPresenter)
        imagesListPresenter.photos = [makePhoto(id: "1"), makePhoto(id: "2"), makePhoto(id: "3")]
        
        let tableView = UITableView()
        imagesListViewController.setValue(tableView, forKey: "tableView")
        tableView.dataSource = imagesListViewController
        
        //when
        _ = imagesListViewController.view
        let rows = imagesListViewController.tableView(tableView, numberOfRowsInSection: 0)
        
        //then
        XCTAssertEqual(rows, 3)
    }
    
    func testImagesListViewViewControllerDidSelectRow() {
        //given
        let imagesListViewController = ImagesListViewController()
        let ImagesListPresenter = ImagesListPresenterSpy()
        imagesListViewController.configure(ImagesListPresenter)
        ImagesListPresenter.photos = [testPhoto]
        
        let tableView = UITableView()
        imagesListViewController.setValue(tableView, forKey: "tableView")
        tableView.dataSource = imagesListViewController
        tableView.delegate = imagesListViewController
        
        //when
        _ = imagesListViewController.view
        imagesListViewController.tableView(tableView, didSelectRowAt: IndexPath(row:0, section:0))
        
        //then
        XCTAssertTrue(ImagesListPresenter.didSelectImageCalled)
    }
    
    func testImagesListViewViewControllerCallsCellDidDisplay() {
        //given
        let imagesListViewController = ImagesListViewController()
        let ImagesListPresenter = ImagesListPresenterSpy()
        imagesListViewController.configure(ImagesListPresenter)
        ImagesListPresenter.photos = [makePhoto(id: "1"), makePhoto(id: "2"), makePhoto(id: "3"), makePhoto(id: "4")]
        
        let tableView = UITableView()
        imagesListViewController.setValue(tableView, forKey: "tableView")
        tableView.dataSource = imagesListViewController
        let cell = UITableViewCell()
        //when
        imagesListViewController.tableView(tableView, willDisplay: cell, forRowAt: IndexPath(row:2, section:0))
        
        //then
        XCTAssertTrue(ImagesListPresenter.cellDidDisplayCalled)
    }
}

