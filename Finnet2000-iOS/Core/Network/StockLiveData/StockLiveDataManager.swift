import Foundation
import OSLog
import Alamofire

final class StockLiveDataManager {
    static let shared = StockLiveDataManager()
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Finnet2000", category: "StockLiveDataManager")
    
    private init() {}
    
    /// Logins to live data API and connects the provided WebSocket manager
    func loginAndConnect(wsManager: StockWebSocketManager) async {
        logger.debug("Live Data login process started")
        let url = "https://api.finnet2000.com/live_data/Login"
        let parameters: [String: String] = [
            "username": "finnet",
            "password": "F].34Mga13Fc+*46Oo"
        ]
        
        do {
            let responseData = try await NetworkManager.shared.authSession
                .request(url, method: .post, parameters: parameters, encoder: JSONParameterEncoder.default)
                .serializingData()
                .value
            
            let response = try JSONDecoder().decode(LiveLoginResponse.self, from: responseData)
            
            if response.authenticateResult, let token = response.authToken {
                logger.debug("Live Data login successful, token received.")
                await MainActor.run {
                    // Save for reconnects
                    UserDefaults.standard.set(token, forKey: "liveDataAuthToken")
                    // Connect
                    wsManager.connect(token: token)
                }
            } else {
                logger.error("Live Data login failed: Token not received or authentication failed.")
            }
        } catch {
            logger.error("Live Data login exception: \(error.localizedDescription)")
        }
    }
}

