import Foundation

final class OAuth2TokenStorageImplementation: OAuth2TokenStorage {
    private let tokenKey = "OAuthToken"
    private let defaults = UserDefaults.standard
    var token: String? {
        get {
            return defaults.string(forKey: tokenKey)
        }
        set {
            defaults.setValue(newValue, forKey: tokenKey)
        }
    }
}
