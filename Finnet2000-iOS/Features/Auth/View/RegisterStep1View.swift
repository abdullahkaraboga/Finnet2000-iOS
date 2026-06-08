import SwiftUI

private let finnetGreen = Color(red: 0.161, green: 0.749, blue: 0.451)

struct RegisterStep1View: View {
    @StateObject private var viewModel = RegisterViewModel()
    @State private var goToStep2 = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {

            // Hidden NavigationLink to Step 2
            NavigationLink(
                destination: RegisterStep2View(viewModel: viewModel),
                isActive: $goToStep2
            ) { EmptyView() }
                .hidden()

            // MARK: - Navigation bar area
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.primary)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 8)

            // MARK: - Logo
            Image("finnet2000_logo_light")
                .resizable()
                .scaledToFit()
                .frame(width: 200)
                .padding(.vertical, 24)

            // MARK: - Form
            VStack(spacing: 16) {

                // İsim
                iconTextField(
                    icon: "person",
                    placeholder: "İsim",
                    text: $viewModel.firstName,
                    keyboardType: .default
                )

                // Soyisim
                iconTextField(
                    icon: "person",
                    placeholder: "Soyisim",
                    text: $viewModel.lastName,
                    keyboardType: .default
                )

                // Email
                iconTextField(
                    icon: "envelope",
                    placeholder: "Email",
                    text: $viewModel.email,
                    keyboardType: .emailAddress
                )

                // Live validation rows – always visible
                VStack(alignment: .leading, spacing: 10) {
                    validationRow(
                        isValid: viewModel.firstNameValid,
                        message: "İsim en az 2 karakter olmalı ve sadece harflerden oluşmalı."
                    )
                    validationRow(
                        isValid: viewModel.lastNameValid,
                        message: "Soyisim en az 2 karakter olmalı ve sadece harflerden oluşmalı."
                    )
                    validationRow(
                        isValid: viewModel.emailValid,
                        message: "Geçerli bir e-posta girin (abc@example.com)"
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 2)

                // Sonraki Adım button
                Button(action: {
                    if viewModel.validateStep1() {
                        goToStep2 = true
                    }
                }) {
                    Text("Sonraki Adım")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(finnetGreen)
                        .cornerRadius(30)
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationBarHidden(true)
    }

    // MARK: - Helpers

    @ViewBuilder
    private func iconTextField(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 20)
            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .autocapitalization(keyboardType == .emailAddress ? .none : .words)
                .disableAutocorrection(true)
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
}

#Preview {
    RegisterStep1View()
}
