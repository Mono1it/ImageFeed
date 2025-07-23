import Foundation

final class ImagesListService{
    // MARK: - Singleton
    static let shared = ImagesListService()
    
    // MARK: - Private Variables
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var isFetching = false
    private let imagesPerPage = "10"
    // MARK: - Notification
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    // MARK: - Private Initializer
    private init() {}
    
    //MARK: - Methods
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
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
            guard let self else {
                preconditionFailure("❌ UrlSessionError")
            }
            
            switch result {
            case .success(let photoResponse):
                for response in photoResponse {
                    let photo = Photo(photoResult: response)
                    
                    // Фильтр от дублирующихся фотографий, которые присылает unsplash.
                    let existingIds = Set(self.photos.map { $0.id })
                    if !existingIds.contains(photo.id) {
                        self.photos.append(photo)
                    }
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
        let imagePerPage: String = imagesPerPage //  Оптимальное число загружаемых фотографий за один вызов.
        
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
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard let request = makeLikeRequest(photoId: photoId, isLike: isLike) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<LikePhotoResult, Error>) in
            guard let self else {
                completion(.failure(NetworkError.urlSessionError))
                return
            }
            
            DispatchQueue.main.async {
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    if case let NetworkError.httpStatusCode(code) = error {
                        print("❌ Unsplash вернул ошибку. Код: \(code)")
                    } else {
                        print("❌ Ошибка: \(error.localizedDescription)")
                    }
                    completion(.failure(error)) // Ошибка сети
                }
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    
    func makeLikeRequest(photoId: String, isLike: Bool) -> URLRequest? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.unsplash.com"
        components.path = "/photos/\(photoId)/like"
        
        guard let url = components.url else {
            preconditionFailure("❌ Невозможно создать URL")
            // Функция имеет возвращаемый тип Never и не нужно возвращать бессмысленное значение из функции в отличии от assertionFailure()
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = isLike ? HTTPMethod.post.rawValue : HTTPMethod.delete.rawValue
        
        let token: String? = KeychainService.shared.getToken(for: "Auth token")
        guard let token = token else {
            preconditionFailure("❌ Не удалось развернуть токен")
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func updateLikeStatus(photoId: String, isLiked: Bool) {
        if let index = photos.firstIndex(where: { $0.id == photoId }) {
            let old = photos[index]
            let updated = Photo(
                id: old.id,
                size: old.size,
                createdAt: old.createdAt,
                welcomeDescription: old.welcomeDescription,
                thumbImageURL: old.thumbImageURL,
                largeImageURL: old.largeImageURL,
                isLiked: isLiked
            )
            photos[index] = updated
        }
    }
    
    func clearPhotos() {
        self.photos = []
        self.lastLoadedPage = nil
    }
}
