import Foundation

struct UrlsResult: Codable {
    let thumb: String
    let full: String
}

struct PhotoResult: Codable {
    let id: String
    let createdAt: Date?
    let width: Int
    let height: Int
    let isLiked: Bool
    let description: String?
    let imageURL: UrlsResult
    
    private enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case isLiked = "liked_by_user"
        case description
        case imageURL = "urls"
    }
}
