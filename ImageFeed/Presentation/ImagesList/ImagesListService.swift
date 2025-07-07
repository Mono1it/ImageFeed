import Foundation

//MARK: - Structs
struct UrlsResult: Codable {
    let thumb: String
    let full: String
}

struct PhotoResult: Codable {
    let id: String
    let createdAt: Date?
    let width: Int
    let height: Int
    let isLiked: Bool
    let description: String?
    let imageURL: UrlsResult
    
    private enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case isLiked = "liked_by_user"
        case description
        case imageURL = "urls"
    }
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}


class ImagesListService{
    // MARK: - Singleton
    static let shared = ImagesListService()
    
    // MARK: - Private Variables
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var isFetching = false
    
    // MARK: - Notification
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    // MARK: - Private Initializer
    private init() {}
    
    //MARK: - Methods
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        print("🛑 Отменяем предыдущий task: \(task != nil ? "Да" : "Нет")")
        task?.cancel()
        
        guard !isFetching else { return }
        isFetching = true
        
        // Здесь получим страницу номер 1, если ещё не загружали ничего,
        // и следующую страницу (на единицу больше), если есть предыдущая загруженная страница
        let nextPage = (lastLoadedPage ?? 0) + 1
        self.lastLoadedPage = nextPage
        
        guard
            let request = makeImageListRequest(page: nextPage)
        else {
            preconditionFailure("❌ InvalidRequest")
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            print("📡 objectTask создан: \(request.url?.absoluteString ?? "нет URL")")
            guard let self else {
                preconditionFailure("❌ UrlSessionError")
            }
            
            switch result {
            case .success(let photoResponse):
                for response in photoResponse {
                    let photo = Photo(
                        id: response.id,
                        size: CGSize(width: response.width, height: response.height),
                        createdAt: response.createdAt,
                        welcomeDescription: response.description,
                        thumbImageURL: response.imageURL.thumb,
                        largeImageURL: response.imageURL.full,
                        isLiked: response.isLiked
                    )
                    self.photos.append(photo)
                }
                self.lastLoadedPage = nextPage
                self.isFetching = false
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self,
                        userInfo: ["photos": self.photos]
                    )
                }
                
            case .failure(let error):
                if case let NetworkError.httpStatusCode(code) = error {
                    print("❌ Unsplash вернул ошибку. Код: \(code)")
                } else {
                    print("❌ Ошибка: \(error.localizedDescription)")
                }
                self.isFetching = false
            }
            self.task = nil
        }
        self.task = task
        print("🚀 Запускаем новый task: \(request.url?.absoluteString ?? "нет URL")")
        task.resume()
    }
    
    func makeImageListRequest(page: Int) -> URLRequest? {
        let imagePerPage: String = "10" //  Оптимальное число загружаемых фотографий за один вызов.
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.unsplash.com"
        components.path = "/photos"
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: imagePerPage)
        ]
        
        guard let url = components.url else {
            preconditionFailure("❌ Невозможно создать URL")
            // Функция имеет возвращаемый тип Never и не нужно возвращать бессмысленное значение из функции в отличии от assertionFailure()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        
        let token: String? = KeychainService.shared.getToken(for: "Auth token")
        guard let token = token else {
            preconditionFailure("❌ Не удалось развернуть токен")
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
