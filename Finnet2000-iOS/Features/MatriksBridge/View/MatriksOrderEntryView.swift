import SwiftUI

private let orderGreen = Color(red: 0.18, green: 0.72, blue: 0.40)
private let orderSellPink = Color(red: 1.00, green: 0.38, blue: 0.58)
private let orderBlue = Color(red: 0.24, green: 0.50, blue: 0.96)

struct MatriksOrderEntryView: View {
    enum TradeSide {
        case buy
        case sell

        var title: String { self == .buy ? "Alış" : "Satış" }
        var accent: Color { self == .buy ? orderGreen : orderSellPink }
    }

    @Environment(\.dismiss) private var dismiss
    @State private var selectedSide: TradeSide = .buy
    @State private var quantityText = "0"
    @State private var limitPriceText: String
    @State private var selectedOrderType = "Piyasadan Limite"
    @State private var selectedDuration = "Günlük"
    @State private var showResultPopup = false
    @State private var showConfirmation = false
    @State private var navigateToPortfolio = false

    let stockSymbol: String
    let stockName: String
    let stockPrice: String
    let stockChange: String
    let stockDate: String
    let brokerName: String
    let accountNumber: String
    let balanceText: String

    private let orderTypeOptions = ["Piyasadan Limite", "Limit", "Piyasa", "Stop Limite"]
    private let durationOptions = ["Günlük", "İptale Kadar Geçerli", "Geçerlilik Tarihli"]

    init(
        stockSymbol: String = "AKSA",
        stockName: String = "Aksa Akrilik",
        stockPrice: String = "12,54₺",
        stockChange: String = "+%4,33",
        stockDate: String = "16/06/2026",
        brokerName: String = "A1 Capital",
        accountNumber: String = "47841",
        balanceText: String = "681.48 ₺"
    ) {
        self.stockSymbol = stockSymbol
        self.stockName = stockName
        self.stockPrice = stockPrice
        self.stockChange = stockChange
        self.stockDate = stockDate
        self.brokerName = brokerName
        self.accountNumber = accountNumber
        self.balanceText = balanceText
        _limitPriceText = State(initialValue: stockPrice.replacingOccurrences(of: "₺", with: ""))
    }

    private var quantity: Int {
        Int(quantityText.replacingOccurrences(of: ".", with: "").trimmingCharacters(in: .whitespaces)) ?? 0
    }

    private var limitPrice: Double {
        decimalValue(from: limitPriceText)
    }

    private var totalAmount: Double {
        Double(quantity) * limitPrice
    }

    private var afterTradeBalance: Double {
        let balance = decimalValue(from: balanceText)
        switch selectedSide {
        case .buy:  return balance - totalAmount
        case .sell: return balance + totalAmount
        }
    }

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    topBar
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    stockHeader
                        .padding(.horizontal, 16)
                        .padding(.top, 18)

                    accountSummary
                        .padding(.horizontal, 16)
                        .padding(.top, 18)

                    sideToggle
                        .padding(.horizontal, 16)
                        .padding(.top, 18)

                    VStack(spacing: 18) {
                        stepperField(title: "Adet", value: $quantityText, keyboardType: .numberPad)
                        stepperField(title: "Limit Fiyat", value: $limitPriceText, keyboardType: .decimalPad)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 14)

                    tradeSummary
                        .padding(.horizontal, 16)
                        .padding(.top, 12)

                    menuRow(title: "Emir Tipi", value: selectedOrderType, options: orderTypeOptions, selection: $selectedOrderType)
                        .padding(.horizontal, 16)
                        .padding(.top, 20)

                    menuRow(title: "Süre", value: selectedDuration, options: durationOptions, selection: $selectedDuration)
                        .padding(.horizontal, 16)
                        .padding(.top, 14)

                    Spacer(minLength: 120)
                }
                .padding(.bottom, 120)
            }

            if showResultPopup {
                tradeResultPopup
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    .zIndex(1)
            }
        }
        .navigationBarHidden(true)
        .safeAreaInset(edge: .bottom) {
            Group {
                if showResultPopup {
                    Color.clear.frame(height: 60)
                } else {
                    Button {
                        showConfirmation = true
                    } label: {
                        Text("Onayla")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(orderBlue, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 10)
                    .background(Color(UIColor.systemBackground).opacity(0.98))
                }
            }
        }
        .confirmationDialog("Emri onaylıyor musunuz?", isPresented: $showConfirmation, titleVisibility: .visible) {
            Button(selectedSide == .buy ? "Alışı Onayla" : "Satışı Onayla", role: .none) {
                showResultPopup = true
            }
            Button("Vazgeç", role: .cancel) { }
        }
        .navigationDestination(isPresented: $navigateToPortfolio) {
            PortfolioView()
        }
    }

    private var topBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(red: 0.10, green: 0.12, blue: 0.18))
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)

            Spacer()

            Text("Alış/Satış")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color(red: 0.10, green: 0.12, blue: 0.18))

            Spacer()

            Button(action: {}) {
                Image(systemName: "info.circle")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(Color(red: 0.10, green: 0.12, blue: 0.18))
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)
        }
    }

    private var stockHeader: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(UIColor.systemGray6))
                .frame(width: 50, height: 50)
                .overlay {
                    Text(String(stockSymbol.prefix(1)))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color(red: 0.20, green: 0.23, blue: 0.28))
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(stockSymbol)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color(red: 0.10, green: 0.12, blue: 0.18))
                Text(stockName)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.secondary)
            }

            Spacer(minLength: 12)

            VStack(alignment: .trailing, spacing: 2) {
                Text(stockPrice)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color(red: 0.10, green: 0.12, blue: 0.18))
                Text(stockDate)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color.secondary)
                Text(stockChange)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(orderGreen)
            }
        }
    }

    private var accountSummary: some View {
        HStack(alignment: .top, spacing: 10) {
            summaryItem(title: "Hesap No", value: accountNumber)
            summaryItem(title: "Bakiye", value: balanceText)
            summaryItem(title: "Aracı Kurum", value: brokerName)
        }
        .padding(.top, 4)
    }

    private func summaryItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(Color.secondary)
            Text(value)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color(red: 0.10, green: 0.12, blue: 0.18))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var sideToggle: some View {
        HStack(spacing: 0) {
            sideButton(.buy)
            sideButton(.sell)
        }
        .padding(4)
        .background(Color(UIColor.systemGray6), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func sideButton(_ side: TradeSide) -> some View {
        Button {
            selectedSide = side
        } label: {
            Text(side.title)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(selectedSide == side ? .white : Color.secondary)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(selectedSide == side ? side.accent : Color.clear, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var tradeResultPopup: some View {
        ZStack {
            Color.black.opacity(0.28)
                .ignoresSafeArea()
                .onTapGesture { }

            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.40, green: 0.95, blue: 0.68).opacity(0.30))
                            .frame(width: 60, height: 60)
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundStyle(Color(red: 0.08, green: 0.65, blue: 0.38))
                    }

                    Text("İşlem Başarılı")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color(red: 0.10, green: 0.12, blue: 0.18))
                        .multilineTextAlignment(.center)

                    VStack(spacing: 0) {
                        Text("\(quantity) adet \(stockSymbol) hissesi \(formatPrice(limitPrice)) TL")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color(red: 0.15, green: 0.19, blue: 0.28))
                        Text(selectedSide == .buy ? "fiyattan başarıyla alındı." : "fiyattan başarıyla satıldı.")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(Color(red: 0.15, green: 0.19, blue: 0.28))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0.93, green: 0.95, blue: 1.0), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                    Divider()
                        .padding(.top, 2)

                    VStack(spacing: 12) {
                        resultRow(title: "İşlem Tipi", value: selectedSide == .buy ? "ALIM (BUY)" : "SATIŞ (SELL)", valueColor: selectedSide == .buy ? orderGreen : orderSellPink)
                        resultRow(title: "Tarih", value: "\(currentDateString()) - 14:32")
                        resultRow(title: "Toplam Tutar", value: currencyString(totalAmount))
                    }
                    .padding(.top, 6)

                    Button {
                        showResultPopup = false
                    } label: {
                        Text("Tamam")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(orderBlue, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    Button {
                        navigateToPortfolio = true
                    } label: {
                        Text("Portföyüm")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(orderBlue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.clear, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(orderBlue, lineWidth: 1.2)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 20)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .frame(maxWidth: 340)
                .shadow(color: Color.black.opacity(0.20), radius: 18, x: 0, y: 10)
            }
            .padding(.horizontal, 24)
        }
    }

    private func resultRow(title: String, value: String, valueColor: Color = Color(red: 0.10, green: 0.12, blue: 0.18)) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(valueColor)
        }
    }

    private func stepperField(title: String, value: Binding<String>, keyboardType: UIKeyboardType) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.secondary)

            HStack(spacing: 12) {
                TextField("0", text: value)
                    .keyboardType(keyboardType)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color(red: 0.10, green: 0.12, blue: 0.18))

                Spacer(minLength: 8)

                VStack(spacing: 0) {
                    controlButton(systemName: "chevron.up") {
                        increment(value: value)
                    }

                    Rectangle()
                        .fill(Color(UIColor.systemGray4))
                        .frame(height: 0.5)

                    controlButton(systemName: "chevron.down") {
                        decrement(value: value)
                    }
                }
                .frame(width: 34, height: 44)
                .background(Color(UIColor.systemGray5), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .padding(.horizontal, 14)
            .frame(height: 56)
            .background(Color(UIColor.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private func controlButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color(red: 0.45, green: 0.48, blue: 0.55))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(.plain)
    }

    private var tradeSummary: some View {
        VStack(spacing: 10) {
            summaryLine(title: "Toplam Satılabilir Adet", value: "\(quantity)")
            summaryLine(title: "Toplam Tutar", value: currencyString(totalAmount))
            summaryLine(title: "İşlem Sonrası Bakiye", value: currencyString(afterTradeBalance))
        }
    }

    private func summaryLine(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(Color.secondary)
            Spacer(minLength: 12)
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color(red: 0.10, green: 0.12, blue: 0.18))
        }
    }

    private func menuRow(title: String, value: String, options: [String], selection: Binding<String>) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color(red: 0.10, green: 0.12, blue: 0.18))
            Image(systemName: "info.circle")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(Color.secondary)

            Spacer(minLength: 10)

            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) { selection.wrappedValue = option }
                }
            } label: {
                HStack(spacing: 10) {
                    Text(value)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color(red: 0.10, green: 0.12, blue: 0.18))
                        .lineLimit(1)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color(red: 0.42, green: 0.50, blue: 0.70))
                }
                .padding(.horizontal, 14)
                .frame(height: 48)
                .frame(minWidth: 156)
                .background(Color(UIColor.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }

    private func increment(value: Binding<String>) {
        if titleLooksDecimal(value.wrappedValue) {
            let current = decimalValue(from: value.wrappedValue)
            value.wrappedValue = currencyInputString(current + 1)
        } else {
            let current = Int(value.wrappedValue) ?? 0
            value.wrappedValue = "\(current + 1)"
        }
    }

    private func decrement(value: Binding<String>) {
        if titleLooksDecimal(value.wrappedValue) {
            let current = max(0, decimalValue(from: value.wrappedValue) - 1)
            value.wrappedValue = currencyInputString(current)
        } else {
            let current = max(0, Int(value.wrappedValue) ?? 0)
            value.wrappedValue = "\(max(0, current - 1))"
        }
    }

    private func titleLooksDecimal(_ value: String) -> Bool {
        value.contains(",") || value.contains(".")
    }

    private func decimalValue(from text: String) -> Double {
        var normalized = text
            .replacingOccurrences(of: "₺", with: "")
            .replacingOccurrences(of: " ", with: "")
        if normalized.contains(",") {
            normalized = normalized.replacingOccurrences(of: ".", with: "")
            normalized = normalized.replacingOccurrences(of: ",", with: ".")
        } else {
            normalized = normalized.replacingOccurrences(of: ",", with: ".")
        }
        return Double(normalized) ?? 0
    }

    private func currencyInputString(_ value: Double) -> String {
        String(format: "%.2f", value).replacingOccurrences(of: ".", with: ",")
    }

    private func currencyString(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = ","
        formatter.groupingSeparator = "."
        let formatted = formatter.string(from: NSNumber(value: max(0, value))) ?? currencyInputString(max(0, value))
        return "\(formatted) ₺"
    }

    private func formatPrice(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = ","
        formatter.groupingSeparator = "."
        return formatter.string(from: NSNumber(value: value)) ?? currencyInputString(value)
    }

    private func currentDateString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: Date())
    }
}

#Preview {
    NavigationStack {
        MatriksOrderEntryView()
    }
}
