
import SwiftUI
import Combine

struct AppRootView: View {
    private let dependencyContainer = DependencyContainer.shared
    @State private var isLoggedIn: Bool = TokenManager.shared.accessToken != nil

    var body: some View {
        Group {
            if isLoggedIn {
                TabBarView(dependencyContainer: dependencyContainer, onLogout: handleLogout)
            } else {
                LoginView(
                    viewModel: dependencyContainer.makeAuthViewModel(),
                    onLoginSuccess: handleLoginSuccess
                )
            }
        }
        .animation(.easeInOut, value: isLoggedIn)
        .onReceive(NotificationCenter.default.publisher(for: .sessionDidExpire)) { _ in
            handleLogout()
        }
    }

    private func handleLoginSuccess() {
        isLoggedIn = true
    }

    private func handleLogout() {
        TokenManager.shared.clearTokens()
        isLoggedIn = false
    }
}
