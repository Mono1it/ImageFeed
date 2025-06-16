import UIKit
import Foundation

final class ProfileService {
    // MARK: - Singleton
    static let shared = ProfileService()
    
    // MARK: - Private Variables
    private let decoder = JSONDecoder()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastToken: String?
    
    // MARK: - Private Initializer
    private init() {}
    
    //MARK: - Structs
    struct ProfileResult: Codable {
        let username: String
        let firstName: String
        let lastName: String
        let bio: String

        enum CodingKeys: String, CodingKey {
            case username = "username"
            case firstName = "first_name"
            case lastName = "last_name"
            case bio = "bio"
        }
    }
    
    struct Profile {
        let username: String
        let name: String
        let loginName: String
        let bio: String
        
        init(profileResult: ProfileService.ProfileResult) {
            self.username = profileResult.username
            self.name = "\(profileResult.firstName) \(profileResult.lastName)"
            self.loginName = "@\(profileResult.username)"
            self.bio = profileResult.bio
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
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        task?.cancel()
        
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
                        let profileResponse = try self.decoder.decode(ProfileResult.self, from: data)
                        print("✅ Профиль получен: \(profileResponse.username) ")
                        let profile = Profile(profileResult: profileResponse)
                        completion(.success(profile)) // Успешно декодировали
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

