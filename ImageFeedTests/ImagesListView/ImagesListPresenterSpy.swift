@testable import ImageFeed
import Foundation

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?

    var photos: [Photo] = []

    // MARK: - Call Trackers
    private(set) var viewDidLoadCalled = false
    private(set) var cellDidDisplayCalled = false
    private(set) var didSelectImageCalled = false
    private(set) var didLikeButtonTapCalled = false
    private(set) var photoCalled = false
    private(set) var imageURLCalled = false
    private(set) var formattedDateCalled = false
    private(set) var isLikedCalled = false
    private(set) var imageSizeCalled = false

    // MARK: - Method Implementations
    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func cellDidDisplay(at indexPath: IndexPath) {
        cellDidDisplayCalled = true
    }

    func didSelectImage(at indexPath: IndexPath) {
        didSelectImageCalled = true
    }

    func didLikeButtonTap(at indexPath: IndexPath) {
        didLikeButtonTapCalled = true
    }

    func photo(at indexPath: IndexPath) -> Photo {
        photoCalled = true
        return photos[indexPath.row]
    }

    func imageURL(for indexPath: IndexPath) -> URL? {
        imageURLCalled = true
        return URL(string: "https://example.com/image.jpg")
    }

    func formattedDate(for indexPath: IndexPath) -> String {
        formattedDateCalled = true
        return "16 Jul 2025"
    }

    func isLiked(for indexPath: IndexPath) -> Bool {
        isLikedCalled = true
        return photos[indexPath.row].isLiked
    }

    func imageSize(at indexPath: IndexPath) -> CGSize {
        imageSizeCalled = true
        return photos[indexPath.row].size
    }
}
