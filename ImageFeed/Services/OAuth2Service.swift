import UIKit
import WebKit

enum OAuth2ServiceConstants {
    static let unsplashURLString = "https://unsplash.com"
}

final class OAuth2Service {
    // MARK: - Private Constants
    static let shared = OAuth2Service()
    private var tokenStorage : OAuth2TokenStorage
    
    // MARK: - Private Initializer
    private init(tokenStorage: OAuth2TokenStorage = OAuth2TokenStorageImplementation()) {
        self.tokenStorage = tokenStorage
    }
    
    // MARK: - Private Methods
    func makeOAuthTokenRequest(code: String) -> URLRequest {
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
            fatalError("❌ Невозможно создать URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    // MARK: - Iternal Methods
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let request = makeOAuthTokenRequest(code: code)
        
        let task = URLSession.shared.data(for: request) { [weak self] result in
            guard let self = self else {
                completion(.failure(NetworkError.unknownError))
                return
            }
            
            switch result {
            case .success(let data):
                do {
                    let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    print("✅ Получен токен: \(tokenResponse.accessToken)")
                    self.tokenStorage.token = tokenResponse.accessToken
                    completion(.success(tokenResponse.accessToken)) // Успешно декодировали
                } catch {
                    print("❌ Ошибка декодирования: \(error.localizedDescription)")
                    completion(.failure(NetworkError.decodingError(error))) // Ошибка при декодировании
                }
            case .failure(let error):
                print("❌ Ошибка при выполнении запроса: \(error)")
                completion(.failure(NetworkError.urlSessionError)) // Ошибка сети
            }
        }
        
        task.resume()
    }
}
