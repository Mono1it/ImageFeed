import Foundation

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
    let profileAvatarURL: String
    
    init(userResult: UserResult) {
        self.profileAvatarURL = userResult.profileImage.small
    }
}
