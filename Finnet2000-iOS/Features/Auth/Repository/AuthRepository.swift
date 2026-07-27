import Foundation
import Alamofire

protocol AuthRepositoryProtocol {
    func login(email: String, password: String, completion: @escaping (Result<LoginResponse, AFError>) -> Void)
    func refreshToken(completion: @escaping (Result<LoginResponse, AFError>) -> Void)
}

final class AuthRepository: AuthRepositoryProtocol {

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
            .responseDecodable(of: LoginResponse.self) { (response: AFDataResponse<LoginResponse>) in
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
        var components = URLComponents(string: "https://api.finnet2000.com/api/Authorization/RefreshToken")
        components?.queryItems = [
            URLQueryItem(name: "refreshToken", value: refresh)
        ]

        guard let url = components?.url else {
            completion(.failure(.invalidURL(url: "https://api.finnet2000.com/api/Authorization/RefreshToken")))
            return
        }

        var request = URLRequest(url: url)
        request.method = .post
        request.headers = ["Accept": "application/json"]
        request.httpBody = Data()

        NetworkManager.shared.authSession
            .request(request)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: LoginResponse.self) { (response: AFDataResponse<LoginResponse>) in
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
}

