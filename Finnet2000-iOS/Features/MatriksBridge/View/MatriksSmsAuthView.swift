import SwiftUI
import Combine

struct MatriksSmsAuthView: View {
    @Binding var isPresented: Bool
    let onSuccess: () -> Void

    @State private var code = ""
    @State private var secondsRemaining = 60
    @FocusState private var isCodeFocused: Bool

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.black.opacity(0.58)
                .ignoresSafeArea()
                .onTapGesture { }

            VStack(spacing: 0) {
                VStack(spacing: 18) {
                    Text("Doğrulama")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color(red: 0.06, green: 0.08, blue: 0.12))

                    codeInput

                    Text(secondsRemaining > 0 ? "Kalan Süre: \(secondsRemaining) sn" : "Süre Doldu!")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(secondsRemaining > 0 ? Color.secondary : Color(red: 0.95, green: 0.24, blue: 0.15))

                    Button {
                        onSuccess()
                        isPresented = false
                    } label: {
                        Text("Tamam")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(red: 0.27, green: 0.71, blue: 0.47), in: Capsule())
                    }
                    .buttonStyle(.plain)

                    Button {
                        resendCode()
                    } label: {
                        Text("SMS'i Tekrar Gönder")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(Color(red: 0.10, green: 0.28, blue: 0.95))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .frame(maxWidth: 360)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            isCodeFocused = true
        }
        .onReceive(timer) { _ in
            guard isPresented, secondsRemaining > 0 else { return }
            secondsRemaining -= 1
        }
    }

    private var codeInput: some View {
        VStack(spacing: 12) {
            TextField("", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .multilineTextAlignment(.center)
                .focused($isCodeFocused)
                .opacity(0.01)
                .frame(width: 1, height: 1)

            HStack(spacing: 10) {
                ForEach(0..<6, id: \.self) { index in
                    let character = codeCharacter(at: index)
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color(red: 0.78, green: 0.78, blue: 0.80), lineWidth: 1)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .frame(width: 44, height: 56)
                        .overlay {
                            Text(character)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(Color(red: 0.10, green: 0.12, blue: 0.18))
                        }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { isCodeFocused = true }
        }
    }

    private func codeCharacter(at index: Int) -> String {
        guard index < code.count else { return "" }
        let stringIndex = code.index(code.startIndex, offsetBy: index)
        return String(code[stringIndex])
    }

    private func resendCode() {
        code = ""
        secondsRemaining = 60
        isCodeFocused = true
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.3).ignoresSafeArea()
        MatriksSmsAuthView(isPresented: .constant(true)) {}
    }
}