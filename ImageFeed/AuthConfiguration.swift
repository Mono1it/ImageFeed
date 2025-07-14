import Foundation

enum Constants {
    static let accessKey = "qzJuk6n2d-3S7YrvQ_WhrvRbh6wdWq2NYmi0lJ8ZhBM"
    static let secretKey = "DcmU381jwFeKmox7c1j7pEvMLfzdSb6LeQFmSPSkED0"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")
    // Оставил опцианальной, а не вычисляемой, так как эта переменная в коде ни разу не вызывалась. При вызове просто нужно будет распаковать опционал.
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    
    static var standard: AuthConfiguration {
        guard let baseURL = Constants.defaultBaseURL else {
            preconditionFailure("❌ Неправильная ссылка на api unsplash")
        }
        
        return AuthConfiguration(accessKey: Constants.accessKey,
                                 secretKey: Constants.secretKey,
                                 redirectURI: Constants.redirectURI,
                                 accessScope: Constants.accessScope,
                                 authURLString: Constants.unsplashAuthorizeURLString,
                                 defaultBaseURL: baseURL)
    }
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURL: URL) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
}
