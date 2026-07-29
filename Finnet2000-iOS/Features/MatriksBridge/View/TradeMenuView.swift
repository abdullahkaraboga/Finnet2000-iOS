import SwiftUI

private let tradeGreen = Color(red: 0.196, green: 0.717, blue: 0.486)

struct TradeMenuView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToAccountSummary = false
    @State private var navigateToPortfolio = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    traderCard
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 12)

                    menuCard
                        .padding(.horizontal, 16)

                    Spacer(minLength: 32)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
        .navigationDestination(isPresented: $navigateToAccountSummary) {
            AccountSummaryView()
        }
        .navigationDestination(isPresented: $navigateToPortfolio) {
            PortfolioView()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Trade Menu")
        .navigationBarTitleDisplayMode(.inline)
        .transparentNavigationBar()
    }

    // MARK: - Trader header card

    private var traderCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "chevron.up")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(tradeGreen)

            Text("Trader")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color(.label))

            Spacer()

            a1CapitalLogo
        }
        .padding(.horizontal, 16)
        .frame(height: 60)
        .background(Color(UIColor.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var a1CapitalLogo: some View {
        VStack(spacing: 2) {
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color(red: 0.00, green: 0.34, blue: 0.72))
                    .frame(width: 40, height: 32)
                Text("N")
                    .font(.system(size: 20, weight: .heavy, design: .serif))
                    .italic()
                    .foregroundStyle(.white)
            }
            Text("A1 Capital")
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(Color(.secondaryLabel))
        }
    }

    // MARK: - Menu list card

    private var menuCard: some View {
        VStack(spacing: 0) {
            row(icon: "doc.text.fill",
                title: "Hesap Özeti",
                trailing: .chevron,
                action: { navigateToAccountSummary = true })

            insetDivider()

            row(icon: "wallet.bifold.fill",
                title: "Portföyüm",
                trailing: .chevron,
                action: { navigateToPortfolio = true })

            insetDivider()

            row(icon: "clock.arrow.circlepath",
                title: "Tamamlanmış Emirler",
                trailing: .chevron)

            insetDivider()

            row(icon: "hourglass.bottomhalf.filled",
                title: "Bekleyen Emirler",
                trailing: .chevron)

            insetDivider()

            row(icon: "xmark.circle.fill",
                title: "İptal Edilmiş Emirler",
                trailing: .chevron)

            insetDivider()

            row(icon: "arrow.2.circlepath",
                title: "Alt Hesap Seçimi",
                trailing: .value("47841"))

            insetDivider()

            row(icon: "rectangle.portrait.and.arrow.right",
                title: "Yatırım Hesabından Çıkış Yap",
                trailing: .none,
                isDestructive: true)
        }
        .background(Color(UIColor.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Row helper

    private enum Trailing {
        case chevron
        case value(String)
        case none
    }

    @ViewBuilder
    private func row(
        icon: String,
        title: String,
        trailing: Trailing,
        isDestructive: Bool = false,
        action: (() -> Void)? = nil
    ) -> some View {
        Button(action: action ?? {}) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(isDestructive ? .red : tradeGreen)
                    .frame(width: 28, alignment: .center)

                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(isDestructive ? .red : Color(.label))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                Spacer()

                switch trailing {
                case .chevron:
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color(.systemGray3))
                case .value(let text):
                    Text(text)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(Color(.label))
                case .none:
                    EmptyView()
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 62)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func insetDivider() -> some View {
        Rectangle()
            .fill(Color(.separator).opacity(0.5))
            .frame(height: 0.5)
            .padding(.leading, 58)
    }
}

#Preview {
    NavigationStack {
        TradeMenuView()
    }
}
