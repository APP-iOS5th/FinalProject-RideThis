import Foundation


class TokenManager {
    static let shared = TokenManager()
    
    var fcmToken: String?
    
    private init() {}
}
