import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    var onLoginSuccess: (() -> Void)? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Finnet2000 Giriş")
                    .font(.largeTitle.bold())
                    .padding(.bottom, 40)

                TextField("E-posta adresi", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                SecureField("Şifre", text: $viewModel.password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                if viewModel.isLoading {
                    ProgressView("Giriş yapılıyor…")
                } else {
                    Button(action: {
                        viewModel.login()
                    }) {
                        Text("Giriş Yap")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }
            .padding()
            .onChange(of: viewModel.isLoggedIn) { loggedIn in
                if loggedIn {
                    onLoginSuccess?()
                }
            }
        }
    }
}
