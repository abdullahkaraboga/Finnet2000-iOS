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
    // Ayrı bir kuyrukta loglama
    let queue = DispatchQueue(label: "finnet2000.network.log")

    // Ayarlar
    private let enableLogging = true
    private let logHeaders = true
    private let logSensitiveHeaders = true   // ⚠️ PROD’da false yap!
    private let logRequestBody = true
    private let logResponseBody = true
    private let maxBodyLogLength = 8 * 1024 // 8 KB
    private let includeCurl = true

    // Süre ölçümü için metrics / startTime takibi
    private var metricsByRequestID = [UUID: URLSessionTaskMetrics]()
    private let lock = NSLock()

    // MARK: - Helpers

    private func redactHeadersIfNeeded(_ headers: [String: String]?) -> [String: String] {
        guard var headers = headers else { return [:] }
        guard !logSensitiveHeaders else { return headers } // Kullanıcı istedi: token’ı da göster.
        let sensitiveKeys = ["authorization", "api-key", "x-api-key", "x-auth-token"]
        for (k, v) in headers {
            if sensitiveKeys.contains(k.lowercased()) {
                headers[k] = "•••REDACTED••• (\(v.count) chars)"
            }
        }
        return headers
    }

    private func prettyJSONString(from data: Data) -> String? {
        guard !data.isEmpty else { return nil }
        do {
            let obj = try JSONSerialization.jsonObject(with: data, options: [])
            let pretty = try JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted, .withoutEscapingSlashes])
            return String(data: pretty, encoding: .utf8)
        } catch {
            return String(data: data, encoding: .utf8)
        }
    }

    private func limitedString(from data: Data) -> String? {
        guard !data.isEmpty else { return nil }
        let slice = data.prefix(maxBodyLogLength)
        var text = String(data: slice, encoding: .utf8) ?? "<non-utf8 body \(slice.count) bytes>"
        if data.count > maxBodyLogLength {
            text += "\n… (truncated, \(data.count - maxBodyLogLength) more bytes)"
        }
        return text
    }

    private func curlString(for request: URLRequest) -> String {
        var components: [String] = ["curl -v"]

        if let method = request.httpMethod {
            components.append("-X \(method)")
        }

        let headers = request.allHTTPHeaderFields ?? [:]
        for (key, value) in headers {
            // logSensitiveHeaders true ise maskeleme yapma
            if !logSensitiveHeaders && key.lowercased() == "authorization" {
                components.append("-H '\(key): •••REDACTED•••'")
            } else {
                components.append("-H '\(key): \(value)'")
            }
        }

        if let bodyData = request.httpBody, !bodyData.isEmpty {
            if let body = String(data: bodyData, encoding: .utf8) {
                // Tek satır güvenli hale getir
                let escaped = body.replacingOccurrences(of: "'", with: "'\"'\"'")
                components.append("--data '\(escaped)'")
            } else {
                components.append("--data-binary @<non-utf8-body>")
            }
        }

        if let url = request.url?.absoluteString {
            components.append("'\(url)'")
        }

        return components.joined(separator: " \\\n  ")
    }

    private func log(_ message: String) {
        guard enableLogging else { return }
        if #available(iOS 14.0, macOS 11.0, *) {
            let logger = Logger(subsystem: "com.finnet2000.network", category: "http")
            logger.debug("\(message, privacy: .public)")
        } else {
            debugPrint(message)
        }
    }

    private func formatDuration(for request: Request) -> String {
        lock.lock(); defer { lock.unlock() }
        if let metrics = metricsByRequestID[request.id] {
            let duration = metrics.taskInterval.duration
            return String(format: "%.3f s", duration)
        } else {
            return "-"
        }
    }

    // MARK: - EventMonitor

    func requestDidResume(_ request: Request) {
        let method = request.request?.httpMethod ?? "?"
        let url = request.request?.url?.absoluteString ?? "?"

        var lines: [String] = []
        lines.append("➡️ REQUEST \(method) \(url)")
        if logHeaders, let headers = request.request?.allHTTPHeaderFields {
            lines.append("HEADERS: \(redactHeadersIfNeeded(headers))")
        }

        if logRequestBody, let httpBody = request.request?.httpBody, !httpBody.isEmpty {
            if let pretty = prettyJSONString(from: httpBody) {
                lines.append("BODY(JSON):\n\(pretty)")
            } else if let text = limitedString(from: httpBody) {
                lines.append("BODY:\n\(text)")
            } else {
                lines.append("BODY: <\(httpBody.count) bytes>")
            }
        }

        if includeCurl, let urlRequest = request.request {
            lines.append("cURL:\n\(curlString(for: urlRequest))")
        }

        log(lines.joined(separator: "\n"))
    }

    func request(_ request: Request, didGatherMetrics metrics: URLSessionTaskMetrics) {
        lock.lock()
        metricsByRequestID[request.id] = metrics
        lock.unlock()
    }

    func request(_ request: DataRequest, didParseResponse response: DataResponse<Data?, AFError>) {
        let status = response.response?.statusCode ?? 0
        let url = response.request?.url?.absoluteString ?? "?"
        var lines: [String] = []
        lines.append("⬅️ RESPONSE \(status) \(url) (\(formatDuration(for: request)))")

        if logHeaders, let headers = response.response?.allHeaderFields as? [String: Any] {
            lines.append("RESP HEADERS: \(headers)")
        }

        if logResponseBody, let data = response.data, !data.isEmpty {
            if let pretty = prettyJSONString(from: data) {
                lines.append("RESP BODY(JSON):\n\(pretty)")
            } else if let text = limitedString(from: data) {
                lines.append("RESP BODY:\n\(text)")
            } else {
                lines.append("RESP BODY: <\(data.count) bytes>")
            }
        }

        if let error = response.error {
            lines.append("ERROR: \(error)")
        }

        log(lines.joined(separator: "\n"))
    }

    func requestDidFinish(_ request: Request) {
        // Temizlik
        lock.lock()
        metricsByRequestID.removeValue(forKey: request.id)
        lock.unlock()
    }

    func request(_ request: Request, didFailTask task: URLSessionTask, earlyWithError error: AFError) {
        log("❌ EARLY FAIL: \(request.description) ERROR: \(error)")
    }

    func requestIsRetrying(_ request: Request) {
        log("🔁 RETRY: \(request.description)")
    }

    func requestDidCancel(_ request: Request) {
        log("🛑 CANCELLED: \(request.description)")
    }
}
