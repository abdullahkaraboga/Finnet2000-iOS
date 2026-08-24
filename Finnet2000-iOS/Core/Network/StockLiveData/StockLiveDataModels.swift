import Foundation

// MARK: - Login Response
struct LiveLoginResponse: Decodable, Sendable {
    let authenticateResult: Bool
    let authToken: String?
    let accessTokenExpireDate: String?
    
    enum CodingKeys: String, CodingKey {
        case authenticateResult = "AuthenticateResult"
        case authToken = "AuthToken"
        case accessTokenExpireDate = "AccessTokenExpireDate"
    }
}

