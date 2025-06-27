import UIKit

final class ProfileImageService {
    // MARK: - Singleton
    static let shared = ProfileImageService()
    
    // MARK: - Notification
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    // MARK: - Private Variables
    private let decoder = JSONDecoder()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var avatarURL: String?
    
    // MARK: - Private Initializer
    private init() {}
    
    //MARK: - Structs
    struct ProfileImageSize: Codable {
        let small: String
        let medium: String
        let large: String
    }
    struct UserResult: Codable {
        let profileImage: ProfileImageSize
        
        enum CodingKeys: String, CodingKey {
            case profileImage = "profile_image"
        }
    }
    
    struct ProfileAvatar {
        let profileAvatarURL: String
        
        init(userResult: UserResult) {
            self.profileAvatarURL = userResult.profileImage.small
        }
    }
    
    //MARK: - Iternal Methods
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        task?.cancel()
        
        guard
            let request = makeProfileRequest(username: username)
        else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self else {
                completion(.failure(NetworkError.urlSessionError))
                return
            }
            
            DispatchQueue.main.async {
                
                switch result {
                case .success(let userResult):
                    print("✅ Аватарка получена в ProfileImageService")
                    let avatarURL = userResult.profileImage.small
                    self.avatarURL = avatarURL
                    completion(.success(avatarURL)) // Успешно декодировали
                    NotificationCenter.default
                        .post(
                            name: ProfileImageService.didChangeNotification,
                            object: self,
                            userInfo: ["URL": self.avatarURL ?? ""])
                    
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
    
    //MARK: - Private Methods
    private func makeProfileRequest(username: String) -> URLRequest? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.unsplash.com"
        components.path = "/users/\(username)"
        
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
