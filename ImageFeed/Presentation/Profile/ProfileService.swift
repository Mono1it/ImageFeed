import UIKit

final class ProfileService {
    // MARK: - Singleton
    static let shared = ProfileService()
    
    // MARK: - Private Variables
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    
    // MARK: - Private Initializer
    private init() {}
    
    //MARK: - Structs
    struct ProfileResult: Codable {
        let username: String
        let firstName: String
        let lastName: String
        let bio: String?
        
        enum CodingKeys: String, CodingKey {
            case username
            case firstName = "first_name"
            case lastName = "last_name"
            case bio
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
            self.bio = profileResult.bio ?? ""
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
        
        let token: String? = KeychainService.shared.getToken(for: "Auth token")
        guard let token = token else {
            preconditionFailure("❌ Не удалось развернуть токен")
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        print("🛑 Отменяем предыдущий task: \(task != nil ? "Да" : "Нет")")
        task?.cancel()
        
        guard
            let request = makeProfileRequest()
        else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            print("📡 objectTask создан: \(request.url?.absoluteString ?? "нет URL")")
            guard let self else {
                completion(.failure(NetworkError.urlSessionError))
                return
            }
            
            switch result {
            case .success(let profileResponse):
                
                print("✅ Профиль получен: \(profileResponse.username) ")
                let profile = Profile(profileResult: profileResponse)
                self.profile = profile
                completion(.success(profile)) // Успешно декодировали
                
            case .failure(let error):
                if case let NetworkError.httpStatusCode(code) = error {
                    print("❌ Unsplash вернул ошибку. Код: \(code)")
                } else {
                    print("❌ Ошибка: \(error.localizedDescription)")
                }
                completion(.failure(error)) // Ошибка сети
            }
            self.task = nil
        }
        self.task = task
        print("🚀 Запускаем новый task: \(request.url?.absoluteString ?? "нет URL")")
        task.resume()
    }

    func clearProfile() {
        self.profile = nil
    }
}

