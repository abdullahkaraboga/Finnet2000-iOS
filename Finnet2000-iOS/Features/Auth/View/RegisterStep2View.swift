import SwiftUI

private let finnetGreen = Color(red: 0.161, green: 0.749, blue: 0.451)

struct RegisterStep2View: View {
    @ObservedObject var viewModel: RegisterViewModel
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @Environment(\.dismiss) private var dismiss
    var onComplete: (() -> Void)? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // MARK: - Logo
                Image("finnet2000_logo_light")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                    .padding(.vertical, 24)

                // MARK: - Form
                VStack(spacing: 16) {

                    // Greeting
                    Text("\(viewModel.firstName) \(viewModel.lastName), Finnet2000'e Hoşgeldin!")
                        .font(.headline)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 4)

                    // Şifre
                    passwordField(
                        placeholder: "Şifre",
                        text: $viewModel.password,
                        showText: $showPassword
                    )

                    // Şifreyi Onayla
                    passwordField(
                        placeholder: "Şifreyi Onayla",
                        text: $viewModel.confirmPassword,
                        showText: $showConfirmPassword
                    )

                    // Live validation rows – always visible
                    VStack(alignment: .leading, spacing: 10) {
                        validationRow(isValid: viewModel.hasLetter,    message: "En az bir harf içermelidir.")
                        validationRow(isValid: viewModel.hasDigit,     message: "En az bir rakam içermelidir.")
                        validationRow(isValid: viewModel.hasMixedCase, message: "Hem büyük hem küçük harf içermelidir.")
                        validationRow(isValid: viewModel.hasSpecial,   message: "En az bir özel karakter içermelidir.")
                        validationRow(isValid: viewModel.isValidLength, message: "8-16 karakter arasında olmalıdır.")
                        validationRow(isValid: viewModel.noSpaces,     message: "Boşluk içermemelidir.")
                        validationRow(isValid: viewModel.passwordsMatch, message: "Şifreler aynı olmalıdır.")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 2)

                    // Kaydı Tamamla
                    Button(action: {
                        if viewModel.validateStep2() {
                            onComplete?()
                        }
                    }) {
                        Text("Kaydı Tamamla")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(finnetGreen)
                            .cornerRadius(30)
                    }
                    .padding(.top, 8)

                    // MARK: - Checkboxes
                    VStack(spacing: 14) {

                        // Email notifications
                        checkboxRow(
                            isChecked: $viewModel.emailNotifications,
                            label: {
                                Text("Finnet2000'e dair bildirim ve haberler hakkında e-posta almak istiyorum.")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                            }
                        )

                        // KVKK
                        checkboxRow(
                            isChecked: $viewModel.kvkkAccepted,
                            label: {
                                Text("Kaydı tamamlayarak ")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                + Text("kullanıcı sözleşmesi")
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(.primary)
                                + Text("ni ve ")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                + Text("KVKK Aydınlatma Metni ve Politikası")
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(.primary)
                                + Text("'nı onaylıyorsunuz.")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                            }
                        )
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Kayıt Ol")
        .navigationBarTitleDisplayMode(.inline)
        .transparentNavigationBar()
    }

    // MARK: - Helpers

    @ViewBuilder
    private func passwordField(
        placeholder: String,
        text: Binding<String>,
        showText: Binding<Bool>
    ) -> some View {
        HStack {
            Group {
                if showText.wrappedValue {
                    TextField(placeholder, text: text)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                } else {
                    SecureField(placeholder, text: text)
                }
            }
            Button(action: { showText.wrappedValue.toggle() }) {
                Image(systemName: showText.wrappedValue ? "eye" : "eye.slash")
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
        .cornerRadius(12)
    }

    @ViewBuilder
    private func validationRow(isValid: Bool, message: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: isValid ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .foregroundColor(isValid ? finnetGreen : .red)
                .font(.system(size: 18))
                .padding(.top, 1)
                .animation(.easeInOut(duration: 0.2), value: isValid)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private func checkboxRow<Label: View>(
        isChecked: Binding<Bool>,
        @ViewBuilder label: () -> Label
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: { isChecked.wrappedValue.toggle() }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(
                            isChecked.wrappedValue ? finnetGreen : Color.gray.opacity(0.5),
                            lineWidth: 1.5
                        )
                        .frame(width: 24, height: 24)

                    if isChecked.wrappedValue {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(finnetGreen)
                    }
                }
            }
            .buttonStyle(.plain)
            .padding(.top, 2)

            label()
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    RegisterStep2View(viewModel: RegisterViewModel())
}
