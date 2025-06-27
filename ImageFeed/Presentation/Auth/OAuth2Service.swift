import UIKit
import WebKit
import SwiftKeychainWrapper

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
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    // MARK: - Private Initializer
    private init() { }
    
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
        
        let task = urlSession.objectTask(for: request) { (result: Result<OAuthTokenResponseBody, Error>) in
            
            switch result {
            case .success(let tokenResponse):
                print("✅ Получен токен в OAuth2Service: \(tokenResponse.accessToken)")
                let token = tokenResponse.accessToken
                let isSuccess = KeychainWrapper.standard.set(token, forKey: "Auth token")
                guard isSuccess else {
                    print("❌ Не удалось сохранить токен в keyChain")
                    return
                }
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
    
    // MARK: - Private Methods
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
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
}
