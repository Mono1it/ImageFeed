import Foundation

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var photos: [Photo] { get }
    func viewDidLoad()
    func cellDidDisplay(at indexPath: IndexPath)
    func didSelectImage(at indexPath: IndexPath)
    func didLikeButtonTap(at indexPath: IndexPath)
    func photo(at indexPath: IndexPath) -> Photo
    func imageURL(for indexPath: IndexPath) -> URL?
    func formattedDate(for indexPath: IndexPath) -> String
    func isLiked(for indexPath: IndexPath) -> Bool
    func imageSize(at indexPath: IndexPath) -> CGSize
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    // MARK: - Variables
    weak var view: ImagesListViewControllerProtocol?
    var notificationToken: NSObjectProtocol?
    // MARK: - Private Constants
    private let imagesListService: ImagesListService
    private(set) var photos: [Photo] = []
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()
    // MARK: - Initializer
    init(imagesListService: ImagesListService = ImagesListService.shared) {
            self.imagesListService = imagesListService
        }
    
    deinit {
        if let token = notificationToken {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    // MARK: - Lifecycle
    func viewDidLoad() {
        notificationToken = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self else { return }
                let newPhotos = self.imagesListService.photos
                let oldCount = self.photos.count
                self.handlePhotosUpdated(oldCount: oldCount, newPhotos: newPhotos)
        }
        // Запускаем первую загрузку
        imagesListService.fetchPhotosNextPage()
    }
    
    // MARK: - Public Methods
    func handlePhotosUpdated(oldCount: Int, newPhotos: [Photo]) {
        let newCount = newPhotos.count
        let addedIndexes = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        
        self.photos = newPhotos
        view?.insertRows(at: addedIndexes)
    }
    
    func photo(at indexPath: IndexPath) -> Photo {
        photos[indexPath.row]
    }

    func imageURL(for indexPath: IndexPath) -> URL? {
        let photo = photo(at: indexPath)
        return URL(string: photo.thumbImageURL)
    }

    func formattedDate(for indexPath: IndexPath) -> String {
        let photo = photo(at: indexPath)
        let date = photo.createdAt ?? Date()
        return Self.dateFormatter.string(from: date)
    }

    func isLiked(for indexPath: IndexPath) -> Bool {
        photo(at: indexPath).isLiked
    }

    func imageSize(at indexPath: IndexPath) -> CGSize {
        photos[indexPath.row].size
    }
    
    func cellDidDisplay(at indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func didSelectImage(at indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        let imageURL = photo.largeImageURL
        guard
            let url = URL(string: imageURL) else {
            print("❌ Некорректный URL")
            return
        }
        view?.showImageViewer(with: url)
    }
    
    func didLikeButtonTap(at indexPath: IndexPath) {
        guard photos.indices.contains(indexPath.row) else { return }

        // Текущий элемент
        let photo = photos[indexPath.row]
        let newValue = !photo.isLiked
        
        view?.setLikeUI(at: indexPath, isLiked: newValue)
        view?.showProgressHUD()
        
        imagesListService.changeLike(photoId: photo.id, isLike: newValue) { [weak self] result in
            guard let self else { return }
            self.view?.hideProgressHUD()
            
            switch result {
            case .success:
                self.photos[indexPath.row] = Photo(
                    id: photo.id,
                    size: photo.size,
                    createdAt: photo.createdAt,
                    welcomeDescription: photo.welcomeDescription,
                    thumbImageURL: photo.thumbImageURL,
                    largeImageURL: photo.largeImageURL,
                    isLiked: newValue
                )
                // Обновляем список фотографий в сервисе, чтобы при прокрутке вниз списка лайки не исчезали сверху
                imagesListService.updateLikeStatus(photoId: photo.id, isLiked: newValue)
                print("✅ Поставлен лайк/дизлайк фото с id: \(photo.id)")
                
            case .failure(let error):
                print("❌ Не удалось изменить лайк: \(error)")
                DispatchQueue.main.async {
                    self.view?.setLikeUI(at: indexPath, isLiked: newValue)
                }
            }
        }
    } 
}
