import Foundation
import SwiftKeychainWrapper

final class KeychainService {
    static let shared = KeychainService()
    
    private init() {}
    
    func save(token: String, for key: String) {
        KeychainWrapper.standard.set(token, forKey: key)
    }
    
    func getToken(for key: String) -> String? {
        return KeychainWrapper.standard.string(forKey: key)
    }
    
    func deleteToken(for key: String) {
        KeychainWrapper.standard.removeObject(forKey: key)
    }
}
