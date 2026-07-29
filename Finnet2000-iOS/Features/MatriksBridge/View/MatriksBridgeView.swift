import SwiftUI

private let matriksGreen = Color(red: 0.196, green: 0.717, blue: 0.486)

struct MatriksBridgeView: View {
    enum PostAuthDestination {
        case tradeMenu
        case orderEntry
    }

    @Environment(\.dismiss) private var dismiss
    @State private var accountId = ""
    @State private var password = ""
    @State private var selectedBroker = "Aracı Kurum Seçin"
    @State private var matriksUserName = ""
    @State private var matriksPassword = ""
    @State private var saveInformation = false
    @State private var showPassword = false
    @State private var showSmsAuth = false
    @State private var navigateToTradeMenu = false
    @State private var navigateToOrderEntry = false

    private let stockSymbol: String
    private let stockName: String
    private let stockPrice: String
    private let stockChange: String
    private let stockDate: String
    private let postAuthDestination: PostAuthDestination

    init(
        stockSymbol: String = "AKSA",
        stockName: String = "Aksa Akrilik",
        stockPrice: String = "12,54₺",
        stockChange: String = "+%4,33",
        stockDate: String = "16/06/2026",
        postAuthDestination: PostAuthDestination = .tradeMenu
    ) {
        self.stockSymbol = stockSymbol
        self.stockName = stockName
        self.stockPrice = stockPrice
        self.stockChange = stockChange
        self.stockDate = stockDate
        self.postAuthDestination = postAuthDestination
    }

    private let brokerOptions = [
        "Aracı Kurum Seçin",
        "A1 Capital",
        "İş Yatırım",
        "Meksa Yatırım"
    ]

    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer(minLength: 44)

                    // Logo + subtitle
                    VStack(spacing: 10) {
                        matriksLogo
                        Text("Devam etmek için bilgilerinizi giriniz")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(Color(.label))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)

                    // Form fields
                    VStack(spacing: 10) {
                        fieldRow {
                            TextField("Hesap ID Girin", text: $accountId)
                                .keyboardType(.numberPad)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                        }

                        fieldRow {
                            HStack(spacing: 10) {
                                passwordGlyph
                                Group {
                                    if showPassword {
                                        TextField("Parola", text: $password)
                                    } else {
                                        SecureField("Parola", text: $password)
                                    }
                                }
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                                Spacer(minLength: 0)
                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye" : "eye.slash")
                                        .font(.system(size: 18))
                                        .foregroundStyle(Color(.systemGray))
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        Menu {
                            ForEach(brokerOptions, id: \.self) { broker in
                                Button(broker) { selectedBroker = broker }
                            }
                        } label: {
                            fieldRow {
                                HStack {
                                    Text(selectedBroker)
                                        .foregroundStyle(Color(.label))
                                        .lineLimit(1)
                                    Spacer(minLength: 8)
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(Color(.label))
                                }
                            }
                        }
                        .buttonStyle(.plain)

                        fieldRow {
                            TextField("Matriks Kullanıcı Adı", text: $matriksUserName)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                        }

                        fieldRow {
                            SecureField("Matriks Şifre", text: $matriksPassword)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                        }
                    }
                    .padding(.horizontal, 20)

                    // Save checkbox
                    HStack(spacing: 12) {
                        Button(action: { saveInformation.toggle() }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .stroke(Color(.systemGray3), lineWidth: 1.5)
                                    .frame(width: 22, height: 22)
                                if saveInformation {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(matriksGreen)
                                }
                            }
                        }
                        .buttonStyle(.plain)

                        Text("Bilgilerimi Kaydet")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(Color(.label))

                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 14)

                    // Login button
                    Button(action: { showSmsAuth = true }) {
                        Text("Giriş Yap")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(matriksGreen, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)
                    .padding(.top, 18)

                    Spacer()
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .ignoresSafeArea()

            if showSmsAuth {
                MatriksSmsAuthView(isPresented: $showSmsAuth) {
                    switch postAuthDestination {
                    case .tradeMenu:
                        navigateToTradeMenu = true
                    case .orderEntry:
                        navigateToOrderEntry = true
                    }
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .navigationDestination(isPresented: $navigateToTradeMenu) {
            TradeMenuView()
        }
        .navigationDestination(isPresented: $navigateToOrderEntry) {
            MatriksOrderEntryView(
                stockSymbol: stockSymbol,
                stockName: stockName,
                stockPrice: stockPrice,
                stockChange: stockChange,
                stockDate: stockDate,
                brokerName: selectedBroker == "Aracı Kurum Seçin" ? "A1 Capital" : selectedBroker,
                accountNumber: accountId.isEmpty ? "47841" : accountId,
                balanceText: "681.48 ₺"
            )
        }
        .navigationTitle("Matriks")
        .navigationBarTitleDisplayMode(.inline)
        .transparentNavigationBar()
    }

    private var matriksLogo: some View {
        HStack(spacing: 0) {
            Text("MATRI")
                .tracking(4)
                .foregroundStyle(Color(.systemGray3))
                .padding(.horizontal, 1)
            Text("KS")
                .tracking(4)
                .foregroundStyle(Color(.systemGray3))
        }
        .font(.system(size: 30, weight: .light))
    }

    private var passwordGlyph: some View {
        VStack(spacing: 1) {
            Text("•••")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(Color(.label))
            Rectangle()
                .fill(Color(.label))
                .frame(width: 22, height: 2)
        }
        .frame(width: 30)
    }

    @ViewBuilder
    private func fieldRow<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .font(.system(size: 16, weight: .regular))
            .foregroundStyle(Color(.label))
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        MatriksBridgeView()
    }
}