import SwiftUI

struct SideDrawerView: View {
    @Binding var isPresented: Bool
    @Binding var isDarkModeEnabled: Bool
    var onLogout: (() -> Void)? = nil
    var onAccountInfoTap: (() -> Void)? = nil
    var onAgreementsTap: (() -> Void)? = nil
    var onNotificationsTap: (() -> Void)? = nil
    var onPriceAlarmsTap: (() -> Void)? = nil
    var onMatriksBridgeTap: (() -> Void)? = nil

    @GestureState private var dragTranslation: CGFloat = 0
    @Environment(\.colorScheme) private var colorScheme

    private let profile = DrawerProfile(
        name: "Abdullah Karaboğa",
        email: "abdullahkaraboga@icloud.com"
    )

    var body: some View {
        GeometryReader { geometry in
            let panelWidth = min(geometry.size.width * 0.74, 286)

            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    drawerHeader

                    VStack(alignment: .leading, spacing: 0) {
                        drawerSection(title: "Genel") {
                            VStack(spacing: 0) {
                                drawerRow(icon: "person.fill", title: "Hesap Bilgileri", action: {
                                    dismiss()
                                    onAccountInfoTap?()
                                })
                                drawerRow(icon: "bell.fill", title: "Bildirim Ayarları", action: {
                                    dismiss()
                                    onNotificationsTap?()
                                })
                                drawerRow(icon: "alarm", title: "Fiyat Alarmları", action: {
                                    dismiss()
                                    onPriceAlarmsTap?()
                                })
                                drawerRow(icon: "checkmark.shield.fill", title: "Sözleşmeler", action: {
                                    dismiss()
                                    onAgreementsTap?()
                                })
                                toggleRow
                                drawerRow(icon: "envelope.fill", title: "Bize Ulaşın")
                            }
                        }

                        drawerSection(title: "Yatırım") {
                            VStack(alignment: .leading, spacing: 0) {
                                drawerRow(icon: "chart.line.uptrend.xyaxis", title: "Matriks Bridge", action: {
                                    dismiss()
                                    onMatriksBridgeTap?()
                                })

                                Text("Yatırım Hesabınıza Giriş Yapın")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(Color(red: 0.23, green: 0.73, blue: 0.53))
                                    .padding(.leading, 56)
                                    .padding(.top, -2)
                                    .padding(.bottom, 6)
                            }
                        }
                    }
                    .padding(.top, 12)

                    Spacer(minLength: 8)

                    Button(action: logout) {
                        HStack(spacing: 12) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 15, weight: .semibold))
                            Text("Çıkış Yap")
                                .font(.system(size: 15, weight: .semibold))
                            Spacer()
                        }
                        .foregroundStyle(Color.red)
                        .padding(.horizontal, 18)
                        .frame(height: 50)
                        .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                }
                .padding(.top, geometry.safeAreaInsets.top + 14)
                .padding(.bottom, max(geometry.safeAreaInsets.bottom, 12) + 10)
                .frame(width: panelWidth)
                .frame(maxHeight: .infinity, alignment: .topLeading)
                .background(
                    ZStack {
                        Rectangle()
                            .fill(.ultraThinMaterial)

                        LinearGradient(
                            colors: [Color.white.opacity(0.86), Color(.systemGray6).opacity(0.92)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .blendMode(.overlay)
                    }
                )
                .overlay(alignment: .trailing) {
                    Rectangle()
                        .fill(Color.black.opacity(colorScheme == .dark ? 0.22 : 0.08))
                        .frame(width: 1)
                }
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .shadow(color: Color.black.opacity(0.12), radius: 24, x: 10, y: 0)
                .padding(.vertical, 8)
                .offset(x: min(0, dragTranslation))
                .gesture(closeGesture)

                Spacer(minLength: 0)
            }
            .ignoresSafeArea()
        }
    }

    private var drawerHeader: some View {
        HStack(spacing: 14) {
            Text(profile.initials)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color(red: 0.14, green: 0.62, blue: 0.45))
                .frame(width: 50, height: 50)
                .background(Color.white)
                .clipShape(Circle())
                
            VStack(alignment: .leading, spacing: 4) {
                Text(profile.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(profile.email)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.9))
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color(red: 0.20, green: 0.74, blue: 0.52), Color(red: 0.14, green: 0.62, blue: 0.45)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    private func drawerSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
            .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
            .padding(.horizontal, 20)
            .padding(.bottom, 4)

            VStack(spacing: 0) {
                content()
            }
            .background(Color.white.opacity(0.56), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .padding(.bottom, 16)
        .padding(.horizontal, 16)
    }

    private func drawerRow(icon: String, title: String, action: (() -> Void)? = nil) -> some View {
        Button(action: action ?? dismiss) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                    .frame(width: 24)

                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)

                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(height: 52)
        }
        .buttonStyle(.plain)
    }

    private var toggleRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "moon.fill")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.secondary)
                .frame(width: 24)

            Text("Koyu Tema")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.9)

            Spacer()

            Toggle("", isOn: $isDarkModeEnabled)
                .labelsHidden()
                .tint(Color(red: 0.23, green: 0.73, blue: 0.53))
        }
        .padding(.horizontal, 20)
        .frame(height: 52)
    }

    private var closeGesture: some Gesture {
        DragGesture(minimumDistance: 12, coordinateSpace: .local)
            .updating($dragTranslation) { value, state, _ in
                if value.translation.width < 0 {
                    state = value.translation.width
                }
            }
            .onEnded { value in
                if value.translation.width < -80 {
                    dismiss()
                }
            }
    }

    private func dismiss() {
        isPresented = false
    }

    private func logout() {
        dismiss()
        onLogout?()
    }
}

private struct DrawerProfile {
    let name: String
    let email: String

    var initials: String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }
}
