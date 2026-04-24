import Foundation
import Security

/// Token'ları Keychain'de güvenli şekilde saklayan singleton.
/// OWASP M2 (Insecure Data Storage) gereksinimlerini karşılamak için
/// UserDefaults yerine Keychain kullanılmaktadır.
final class TokenManager {
    static let shared = TokenManager()
    private init() {}

    // MARK: - Keychain Anahtarları
    private enum Keys {
        static let accessToken  = "com.finnet2000.accessToken"
        static let refreshToken = "com.finnet2000.refreshToken"
        /// Access token'ın UTC Unix timestamp olarak sona erme zamanı
        static let accessTokenExpiry = "com.finnet2000.accessTokenExpiry"
    }

    // MARK: - Public API

    var accessToken: String? {
        get { keychainRead(key: Keys.accessToken) }
        set {
            if let v = newValue { keychainWrite(key: Keys.accessToken, value: v) }
            else { keychainDelete(key: Keys.accessToken) }
        }
    }

    var refreshToken: String? {
        get { keychainRead(key: Keys.refreshToken) }
        set {
            if let v = newValue { keychainWrite(key: Keys.refreshToken, value: v) }
            else { keychainDelete(key: Keys.refreshToken) }
        }
    }

    /// Access token'ın sona erme tarihi. Login/Refresh sırasında `expiresIn` saniye
    /// cinsinden alınarak hesaplanmalıdır.
    var accessTokenExpiry: Date? {
        get {
            guard let raw = keychainRead(key: Keys.accessTokenExpiry),
                  let ts = Double(raw) else { return nil }
            return Date(timeIntervalSince1970: ts)
        }
        set {
            if let d = newValue {
                keychainWrite(key: Keys.accessTokenExpiry,
                              value: String(d.timeIntervalSince1970))
            } else {
                keychainDelete(key: Keys.accessTokenExpiry)
            }
        }
    }

    /// Access token'ın geçerli mi yoksa yakında (30 sn eşiği) sona mı ereceğini kontrol eder.
    var isAccessTokenValid: Bool {
        guard accessToken != nil else { return false }
        guard let expiry = accessTokenExpiry else {
            // Expiry bilgisi yoksa (eski davranış): varsa geçerli say
            return true
        }
        // 30 saniyelik tampon: süresi dolmadan önce refresh başlat
        return expiry.timeIntervalSinceNow > 30
    }

    func saveTokens(accessToken: String,
                    refreshToken: String,
                    expiresIn: TimeInterval? = nil) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        if let ttl = expiresIn {
            self.accessTokenExpiry = Date().addingTimeInterval(ttl)
        }
    }

    func clearTokens() {
        keychainDelete(key: Keys.accessToken)
        keychainDelete(key: Keys.refreshToken)
        keychainDelete(key: Keys.accessTokenExpiry)
    }

    // MARK: - Keychain Yardımcıları

    @discardableResult
    private func keychainWrite(key: String, value: String) -> Bool {
        let data = Data(value.utf8)
        // Önce varsa sil (duplicate item hatasını önler)
        keychainDelete(key: key)
        let query: [CFString: Any] = [
            kSecClass:            kSecClassGenericPassword,
            kSecAttrAccount:      key,
            kSecValueData:        data,
            // Cihaz kilit açıldıktan sonra erişilebilir; iCloud'a yedeklenmez
            kSecAttrAccessible:   kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            debugPrint("🔑 Keychain write error (\(key)): \(status)")
        }
        return status == errSecSuccess
    }

    private func keychainRead(key: String) -> String? {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData:  true,
            kSecMatchLimit:  kSecMatchLimitOne
        ]
        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecSuccess,
           let data = item as? Data,
           let string = String(data: data, encoding: .utf8) {
            return string
        }

        // Keychain'de bulunamadıysa eski UserDefaults'a fallback yap (migration).
        // Bulunursa Keychain'e taşı ve UserDefaults'tan sil.
        let udKey: String
        switch key {
        case Keys.accessToken:  udKey = "accessToken"
        case Keys.refreshToken: udKey = "refreshToken"
        default: return nil
        }
        if let migrated = UserDefaults.standard.string(forKey: udKey) {
            debugPrint("🔑 [Migration] \(udKey) UserDefaults→Keychain taşınıyor.")
            keychainWrite(key: key, value: migrated)
            UserDefaults.standard.removeObject(forKey: udKey)
            return migrated
        }
        return nil
    }

    @discardableResult
    private func keychainDelete(key: String) -> Bool {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrAccount: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
