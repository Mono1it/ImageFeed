import UIKit
import Foundation

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
        let ProfileAvatarURL: String
        
        init(userResult: UserResult) {
            self.ProfileAvatarURL = userResult.profileImage.small
        }
    }
    
    //MARK: - Methods
    func makeProfileRequest() -> URLRequest? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.unsplash.com"
        components.path = "/me"
        
        guard let url = components.url else {
            preconditionFailure("❌ Невозможно создать URL")
            // Функция имеет возвращаемый тип Never и не нужно возвращать бессмысленное значение из функции в отличии от assertionFailure()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        
        let token = OAuth2TokenStorageImplementation().token ?? ""
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfileImageURL(_ token: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        task?.cancel()
            
        NotificationCenter.default                                     // 1
            .post(                                                     // 2
                name: ProfileImageService.didChangeNotification,       // 3
                object: self,                                          // 4
                userInfo: ["URL": self.avatarURL])                    // 5
        
        guard
            let request = makeProfileRequest()
        else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = urlSession.data(for: request) { [weak self] result in
            guard let self else {
                completion(.failure(NetworkError.urlSessionError))
                return
            }
            
            DispatchQueue.main.async {
                
                switch result {
                case .success(let data):
                    do {
                        let userResult = try self.decoder.decode(UserResult.self, from: data)
                        print("✅ Аватарка получена")
                        let avatarURL = userResult.profileImage.small
                        self.avatarURL = avatarURL
                        completion(.success(avatarURL)) // Успешно декодировали
                    } catch {
                        print("❌ Ошибка декодирования: \(error.localizedDescription)")
                        completion(.failure(NetworkError.decodingError(error))) // Ошибка при декодировании
                    }
                case .failure(let error):
                    // Нашёл вот такой интересный "синтаксический сахар", не хотел через switch описывать все случаи и наткнулся на вот такую кострукцию.
                    // Вопрос ревьюверу: Является ли это хорошей практикой или же стоило перебрать все ошибки через switch?
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
}

