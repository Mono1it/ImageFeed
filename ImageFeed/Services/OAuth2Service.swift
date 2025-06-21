import UIKit
import WebKit

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

final class OAuth2Service {
    // MARK: - Private Constants
    static let shared = OAuth2Service()
    private let decoder = JSONDecoder()
    private var tokenStorage : OAuth2TokenStorage
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    // MARK: - Private Initializer
    private init(tokenStorage: OAuth2TokenStorage = OAuth2TokenStorageImplementation()) {
        self.tokenStorage = tokenStorage
    }
    
    // MARK: - Private Methods
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "unsplash.com"
        components.path = "/oauth/token"
        components.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]
        guard let url = components.url else {
            preconditionFailure("❌ Невозможно создать URL")
            // Функция имеет возвращаемый тип Never и не нужно возвращать бессмысленное значение из функции в отличии от assertionFailure()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        return request
    }
    
    // MARK: - Iternal Methods
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastCode = code
        
        guard
            let request = makeOAuthTokenRequest(code: code)
        else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }

//        let task = urlSession.data(for: request) { [weak self] result in
//            guard let self else {
//                completion(.failure(NetworkError.urlSessionError))
//                return
//            }
//            DispatchQueue.main.async {
//                
//                switch result {
//                case .success(let data):
//                    do {
//                        let tokenResponse = try self.decoder.decode(OAuthTokenResponseBody.self, from: data)
//                        print("✅ Получен токен: \(tokenResponse.accessToken)")
//                        self.tokenStorage.token = tokenResponse.accessToken
//                        completion(.success(tokenResponse.accessToken)) // Успешно декодировали
//                    } catch {
//                        print("❌ Ошибка декодирования: \(error.localizedDescription)")
//                        completion(.failure(NetworkError.decodingError(error))) // Ошибка при декодировании
//                    }
//                case .failure(let error):
//                    // Нашёл вот такой интересный "синтаксический сахар", не хотел через switch описывать все случаи и наткнулся на вот такую кострукцию.
//                    // Вопрос ревьюверу: Является ли это хорошей практикой или же стоило перебрать все ошибки через switch?
//                    if case let NetworkError.httpStatusCode(code) = error {
//                        print("❌ Unsplash вернул ошибку. Код: \(code)")
//                    } else {
//                        print("❌ Ошибка: \(error.localizedDescription)")
//                    }
//                    completion(.failure(error)) // Ошибка сети
//                }
//                
//            }
//            self.task = nil
//            self.lastCode = nil
//        }
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self else {
                completion(.failure(NetworkError.urlSessionError))
                return
            }
            
            switch result {
            case .success(let tokenResponse):
                    print("✅ Получен токен в OAuth2Service: \(tokenResponse.accessToken)")
                    self.tokenStorage.token = tokenResponse.accessToken
                    completion(.success(tokenResponse.accessToken)) // Успешно декодировали

            case .failure(let error):
                if case let NetworkError.httpStatusCode(code) = error {
                    print("❌ Unsplash вернул ошибку. Код: \(code)")
                } else {
                    print("❌ Ошибка в OAuth2Service: \(error.localizedDescription)")
                }
                completion(.failure(error)) // Ошибка сети
            }
        }
        self.task = task
        task.resume()
    }
}
