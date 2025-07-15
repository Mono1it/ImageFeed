import Foundation

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func fetchCode(from url: URL) -> String?
}

final class AuthHelper: AuthHelperProtocol {
    // MARK: - Constants
    let configuration: AuthConfiguration

    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }
    
    // MARK: - Methods
    func authRequest() -> URLRequest? {
        guard let url = authURL() else { return nil }
        
        return URLRequest(url: url)
    }

    func authURL() -> URL? {
        guard
            var urlComponents = URLComponents(string: configuration.authURLString)
        else {
            assertionFailure("Invalid authorization URL string: \(configuration.authURLString)")
            return nil
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: configuration.accessScope)
        ]
        
        return urlComponents.url
    }
    
    func fetchCode(from url: URL) -> String? {
        guard
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        else {
            return nil
        }
        
        return codeItem.value
    }
}

