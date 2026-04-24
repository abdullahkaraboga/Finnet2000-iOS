import Foundation
import Alamofire

final class AuthRepository {

    struct Headers {
        static let json: HTTPHeaders = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        static let form: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded; charset=utf-8",
            "Accept": "application/json"
        ]
    }

    private func logResponse(_ response: AFDataResponse<Data?>, label: String) {
        let url = response.request?.url?.absoluteString ?? "-"
        let status = response.response?.statusCode ?? 0
        debugPrint("⬅️ [\(label)] STATUS: \(status) URL: \(url)")
        if let headers = response.response?.allHeaderFields {
            debugPrint("HEADERS: \(headers)")
        }
        if let data = response.data, let text = String(data: data, encoding: .utf8) {
            debugPrint("RESPONSE BODY: \(text)")
        }
        if let error = response.error {
            debugPrint("ERROR: \(error)")
        }
    }

    func login(email: String, password: String, completion: @escaping (Result<LoginResponse, AFError>) -> Void) {
        let url = "https://api.finnet2000.com/api/Authorization/Login"
        // 1) JSON dene
        NetworkManager.shared.authSession
            .request(url,
                     method: .post,
                     parameters: ["email": email, "password": password],
                     encoder: JSONParameterEncoder.default,
                     headers: Headers.json)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: LoginResponse.self) { [weak self] (response: AFDataResponse<LoginResponse>) in
                // Ham response’u da ayrıca loglayalım
                let raw = AFDataResponse<Data?>(
                    request: response.request,
                    response: response.response,
                    data: response.data,
                    metrics: response.metrics,
                    serializationDuration: response.serializationDuration,
                    result: response.result.map { _ in Data() } // result’u korumak istemiyoruz, sadece data/log için
                )
                self?.logResponse(raw, label: "LOGIN(JSON)")

                switch response.result {
                case .success(let tokens):
                    TokenManager.shared.saveTokens(
                        accessToken: tokens.accessToken,
                        refreshToken: tokens.refreshToken,
                        expiresIn: tokens.expiresIn
                    )
                    completion(.success(tokens))
                case .failure(let error):
                    // 415 vs. olursa 2) form-encoded fallback
                    if let status = response.response?.statusCode, status == 415 || status == 400 {
                        self?.loginFormEncoded(email: email, password: password, completion: completion)
                    } else {
                        completion(.failure(error))
                    }
                }
            }
    }

    private func loginFormEncoded(email: String, password: String, completion: @escaping (Result<LoginResponse, AFError>) -> Void) {
        let url = "https://api.finnet2000.com/api/Authorization/Login"
        NetworkManager.shared.authSession
            .request(url,
                     method: .post,
                     parameters: ["email": email, "password": password],
                     encoder: URLEncodedFormParameterEncoder.default,
                     headers: Headers.form)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: LoginResponse.self) { [weak self] (response: AFDataResponse<LoginResponse>) in
                let raw = AFDataResponse<Data?>(
                    request: response.request,
                    response: response.response,
                    data: response.data,
                    metrics: response.metrics,
                    serializationDuration: response.serializationDuration,
                    result: response.result.map { _ in Data() }
                )
                self?.logResponse(raw, label: "LOGIN(FORM)")

                switch response.result {
                case .success(let tokens):
                    TokenManager.shared.saveTokens(
                        accessToken: tokens.accessToken,
                        refreshToken: tokens.refreshToken,
                        expiresIn: tokens.expiresIn
                    )
                    completion(.success(tokens))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    func refreshToken(completion: @escaping (Result<LoginResponse, AFError>) -> Void) {
        guard let refresh = TokenManager.shared.refreshToken else {
            completion(.failure(.explicitlyCancelled))
            return
        }
        let url = "https://api.finnet2000.com/api/Authorization/RefreshToken"

        NetworkManager.shared.authSession
            .request(url,
                     method: .get,
                     parameters: ["refreshToken": refresh], // query string
                     headers: Headers.json)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: LoginResponse.self) { [weak self] (response: AFDataResponse<LoginResponse>) in
                let raw = AFDataResponse<Data?>(
                    request: response.request,
                    response: response.response,
                    data: response.data,
                    metrics: response.metrics,
                    serializationDuration: response.serializationDuration,
                    result: response.result.map { _ in Data() }
                )
                self?.logResponse(raw, label: "REFRESH")

                switch response.result {
                case .success(let tokens):
                    TokenManager.shared.saveTokens(
                        accessToken: tokens.accessToken,
                        refreshToken: tokens.refreshToken,
                        expiresIn: tokens.expiresIn
                    )
                    debugPrint("🔐✅ [REFRESH] Yeni token kaydedildi.")
                    completion(.success(tokens))
                case .failure(let error):
                    debugPrint("🔐❌ [REFRESH] Decode/network hatası: \(error)")
                    completion(.failure(error))
                }
            }
    }
}

