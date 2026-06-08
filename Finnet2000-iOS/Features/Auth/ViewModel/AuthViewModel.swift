import Foundation
import Combine
import Alamofire

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String?

    private let repository: AuthRepositoryProtocol
    private var sessionExpiryCancellable: AnyCancellable?

    init(repository: AuthRepositoryProtocol = AuthRepository()) {
        self.repository = repository

        // Uygulama başlarken mevcut token varsa oturum açık say
        isLoggedIn = TokenManager.shared.accessToken != nil

        // Refresh token da bittiğinde → otomatik logout
        sessionExpiryCancellable = NotificationCenter.default
            .publisher(for: .sessionDidExpire)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.forceLogout()
            }
    }

    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Lütfen e-posta ve şifre girin."
            return
        }

        isLoading = true
        errorMessage = nil

        repository.login(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false

                switch result {
                case .success:
                    self.isLoggedIn = true
                case .failure(let error):
                    self.errorMessage = "Giriş başarısız: \(error.localizedDescription)"
                }
            }
        }
    }

    func logout() {
        TokenManager.shared.clearTokens()
        isLoggedIn = false
        email = ""
        password = ""
    }

    // MARK: - Private

    /// Refresh token süresi dolduğunda çağrılır – kullanıcıya bildirim verebilirsiniz.
    private func forceLogout() {
        TokenManager.shared.clearTokens()
        isLoggedIn = false
        email = ""
        password = ""
        errorMessage = "Oturumunuz sona erdi. Lütfen tekrar giriş yapın."
    }
}


