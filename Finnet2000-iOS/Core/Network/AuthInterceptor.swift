
//
//  AuthInterceptor.swift
//  Finnet2000-iOS
//
//  Created by Karaboğa on 10/24/25.
//

import Foundation
import Alamofire

// MARK: - Session Expiry Bildirimi
extension Notification.Name {
    /// Refresh token da geçersiz olduğunda yayınlanır → Uygulama Login ekranına yönlendirir.
    static let sessionDidExpire = Notification.Name("com.finnet2000.sessionDidExpire")
}

final class AuthInterceptor: RequestInterceptor {

    private let retryLimit = 1
    private var isRefreshing = false
    private var requestsToRetry: [(RetryResult) -> Void] = []
    private let lock = NSLock()

    private let authRepository = AuthRepository()

    // MARK: - Adapt (Her istekte Authorization header ekle)

    func adapt(_ urlRequest: URLRequest,
               for session: Session,
               completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var request = urlRequest
        let absolute = request.url?.absoluteString ?? ""

        // Login / Refresh endpoint'lerine token EKLEMEmeliyz
        if absolute.contains("/Authorization/Login") || absolute.contains("/Authorization/RefreshToken") {
            completion(.success(request))
            return
        }

        if let token = TokenManager.shared.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        completion(.success(request))
    }

    // MARK: - Retry (401 → Token Yenile → Tekrar Dene)

    func retry(_ request: Request,
               for session: Session,
               dueTo error: Error,
               completion: @escaping (RetryResult) -> Void) {

        let absolute = request.request?.url?.absoluteString ?? ""

        // Refresh / Login uç noktalarını sonsuz döngüye sokmamak için asla retry etme
        guard !absolute.contains("/Authorization/RefreshToken"),
              !absolute.contains("/Authorization/Login") else {
            completion(.doNotRetry)
            return
        }

        // Yalnızca 401 Unauthorized hatasında yenile
        guard request.response?.statusCode == 401 else {
            completion(.doNotRetry)
            return
        }

        // Refresh token mevcut değilse direkt logout — gereksiz API çağrısı yapma
        guard TokenManager.shared.refreshToken != nil else {
            TokenManager.shared.clearTokens()
            handleSessionExpired()
            completion(.doNotRetry)
            return
        }

        // Retry limitini aşmışsa vazgeç
        guard request.retryCount < retryLimit else {
            handleSessionExpired()
            completion(.doNotRetry)
            return
        }

        lock.lock()
        requestsToRetry.append(completion)

        // Zaten refresh yapılıyorsa sadece kuyruğa ekle
        guard !isRefreshing else {
            lock.unlock()
            return
        }

        isRefreshing = true
        lock.unlock()

        authRepository.refreshToken { [weak self] result in
            guard let self else { return }

            self.lock.lock()
            let queued = self.requestsToRetry
            self.requestsToRetry.removeAll()
            self.isRefreshing = false
            self.lock.unlock()

            switch result {
            case .success:
                queued.forEach { $0(.retry) }

            case .failure(let err):
                TokenManager.shared.clearTokens()
                queued.forEach { $0(.doNotRetry) }
                self.handleSessionExpired()
            }
        }
    }

    // MARK: - Oturum Sonlandırma

    private func handleSessionExpired() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .sessionDidExpire, object: nil)
        }
    }
}

