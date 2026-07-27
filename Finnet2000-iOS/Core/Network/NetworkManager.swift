import Foundation
import Alamofire
import os

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}

    // 🔍 Ayrıntılı log (tek monitor, iki session tarafından paylaşılır)
    private let monitor = FinnetLogEventMonitor()

    // 🔐 Uygulama genelinde kullanılan (Authorization header + 401 retry)
    private let interceptor = AuthInterceptor()

    // Auth gerektiren istekler
    lazy var authedSession: Session = {
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = 30
        cfg.requestCachePolicy = .reloadIgnoringLocalCacheData
        return Session(configuration: cfg,
                       interceptor: interceptor,
                       eventMonitors: [monitor])
    }()

    // ❗️Login/Refresh gibi istekler için INTERCEPTOR YOK
    lazy var authSession: Session = {
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = 30
        cfg.requestCachePolicy = .reloadIgnoringLocalCacheData
        return Session(configuration: cfg,
                       eventMonitors: [monitor])
    }()

    @discardableResult
    func request<T: Decodable>(
        _ urlConvertible: URLRequestConvertible,
        type: T.Type,
        completion: @escaping (Result<T, AFError>) -> Void
    ) -> DataRequest {
        return authedSession.request(urlConvertible)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: T.self) { response in
                completion(response.result)
            }
    }
}

// MARK: - EventMonitor
final class FinnetLogEventMonitor: EventMonitor {
    let queue = DispatchQueue(label: "finnet2000.network.log")

    private func log(_ message: String) {
        if #available(iOS 14.0, macOS 11.0, *) {
            let logger = Logger(subsystem: "com.finnet2000.network", category: "http")
            logger.debug("\(message, privacy: .public)")
        } else {
            debugPrint(message)
        }
    }

    func request(_ request: DataRequest, didParseResponse response: DataResponse<Data?, AFError>) {
        let status = response.response?.statusCode ?? 0
        let url = response.request?.url?.absoluteString ?? "?"
        let logMessage = "URL: \(url) - Status Code: \(status)"
        log(logMessage)

        if let error = response.error {
            log("URL: \(url) - Error: \(error.localizedDescription)")
        }
    }
}
