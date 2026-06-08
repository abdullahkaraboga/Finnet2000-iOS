import SwiftUI

private let finnetGreen = Color(red: 0.161, green: 0.749, blue: 0.451)

struct LoginView: View {
    @StateObject private var viewModel: AuthViewModel
    @State private var showPassword = false
    @State private var rememberMe = false
    var onLoginSuccess: (() -> Void)? = nil

    @MainActor
    init(viewModel: AuthViewModel, onLoginSuccess: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onLoginSuccess = onLoginSuccess
    }

    @MainActor
    init(onLoginSuccess: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: AuthViewModel())
        self.onLoginSuccess = onLoginSuccess
    }

    var body: some View {
        NavigationStack {
        GeometryReader { geo in
            VStack(spacing: 0) {

                // MARK: - Dark top section
                ZStack {
                    Color.black
                        .frame(maxWidth: .infinity)

                    // Decorative arcs
                    Circle()
                        .stroke(Color.white.opacity(0.07), lineWidth: 1.5)
                        .frame(width: geo.size.width * 1.3)
                        .offset(x: geo.size.width * 0.35, y: -geo.size.width * 0.05)

                    Circle()
                        .stroke(Color.white.opacity(0.05), lineWidth: 1.5)
                        .frame(width: geo.size.width * 0.85)
                        .offset(x: -geo.size.width * 0.25, y: geo.size.width * 0.12)

                    // Logo
                    Image("finnet2000_logo_dark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.55)
                }
                .frame(width: geo.size.width, height: geo.size.height * 0.44)
                .clipped()

                // MARK: - Light bottom section
                VStack(spacing: 14) {

                    // Email field
                    TextField("Email", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .cornerRadius(12)

                    // Password field
                    HStack {
                        Group {
                            if showPassword {
                                TextField("Şifre", text: $viewModel.password)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            } else {
                                SecureField("Şifre", text: $viewModel.password)
                            }
                        }
                        Button(action: { showPassword.toggle() }) {
                            Image(systemName: showPassword ? "eye" : "eye.slash")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .cornerRadius(12)

                    // Forgot password + Remember me
                    HStack {
                        Button("Şifremi Unuttum") { }
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        Spacer()

                        Text("Beni Hatırla")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        Toggle("", isOn: $rememberMe)
                            .labelsHidden()
                            .tint(finnetGreen)
                            .scaleEffect(0.8)
                    }
                    .padding(.top, 2)

                    // Login button / loading
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    } else {
                        Button(action: { viewModel.login() }) {
                            Text("Giriş Yap")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(finnetGreen)
                                .cornerRadius(30)
                        }
                        .padding(.top, 6)
                    }

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                    }

                    NavigationLink(destination: RegisterStep1View()) {
                        Text("Kayıt Ol")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(finnetGreen)
                            .padding(.top, 4)
                    }

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 28)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor.systemGroupedBackground))
            }
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .onChange(of: viewModel.isLoggedIn) { loggedIn in
            if loggedIn {
                onLoginSuccess?()
            }
        }
        } // NavigationStack
    }
}

#Preview {
    LoginView()
}
