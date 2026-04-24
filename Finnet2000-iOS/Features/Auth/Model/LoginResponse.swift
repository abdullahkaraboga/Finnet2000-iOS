import Foundation

/// Login ve RefreshToken endpoint'lerinin yanıt modeli.
struct LoginResponse: Decodable, Sendable {
    let accessToken: String
    let refreshToken: String
    /// Sunucunun döndürdüğü saniye cinsinden geçerlilik süresi (opsiyonel).
    let expiresIn: TimeInterval?

    // API camelCase ya da snake_case kullanıyor olabilir – her ikisini de destekle.
    enum CodingKeys: String, CodingKey {
        case accessToken  = "accessToken"
        case refreshToken = "refreshToken"
        case expiresIn    = "expiresIn"
    }

    nonisolated init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        accessToken  = try c.decode(String.self, forKey: .accessToken)
        refreshToken = try c.decode(String.self, forKey: .refreshToken)
        expiresIn    = try c.decodeIfPresent(TimeInterval.self, forKey: .expiresIn)
    }
}

