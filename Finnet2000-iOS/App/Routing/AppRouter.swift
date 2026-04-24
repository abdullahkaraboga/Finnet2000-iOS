
import SwiftUI

struct AppRootView: View {
    @State private var isLoggedIn: Bool = TokenManager.shared.accessToken != nil

    var body: some View {
        Group {
            if isLoggedIn {
                TabBarView(onLogout: handleLogout)
            } else {
                LoginView(onLoginSuccess: handleLoginSuccess)
            }
        }
        .animation(.easeInOut, value: isLoggedIn)
    }

    private func handleLoginSuccess() {
        isLoggedIn = true
    }

    private func handleLogout() {
        TokenManager.shared.clearTokens()
        isLoggedIn = false
    }
}
