import SwiftUI

// MARK: - PozisyonAcSheet

struct PozisyonAcSheet: View {
    let stockCode: String
    var onClose: () -> Void = {}

    @State private var portfolios: [PortfolioInfo] = []
    @State private var isLoadingPortfolios = true
    @State private var selectedPortfolio: PortfolioInfo?
    @State private var isDropdownOpen = false
    @State private var selectedDate = Date()
    @State private var price = ""
    @State private var quantity = "0"
    @State private var commission = ""
    @State private var isSaving = false

    private let accentGreen = Color(red: 0.18, green: 0.72, blue: 0.40)
    private let fieldBg     = Color(UIColor.secondarySystemGroupedBackground)

    private var canSave: Bool {
        !price.isEmpty && !quantity.isEmpty && quantity != "0"
    }

    private var dateFormatted: String {
        let f = DateFormatter()
        f.dateFormat = "dd/MM/yyyy"
        return f.string(from: selectedDate)
    }

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Başlık
            HStack {
                Spacer()
                Text("Pozisyon Aç")
                    .font(.system(size: 20, weight: .bold))
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 28)
            .padding(.bottom, 14)

            Divider()

            // MARK: - Form
            VStack(spacing: 10) {

                // Portföy seçimi
                VStack(alignment: .leading, spacing: 4) {
                    fieldLabel("Portföy")
                    if isLoadingPortfolios {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .frame(height: 46)
                        .background(fieldBg, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    } else {
                        Button {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                isDropdownOpen.toggle()
                            }
                        } label: {
                            HStack {
                                Text(selectedPortfolio?.portfolioName ?? "Portföy Seçin")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(selectedPortfolio != nil ? .primary : .secondary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.secondary)
                                    .rotationEffect(.degrees(isDropdownOpen ? 180 : 0))
                            }
                            .padding(.horizontal, 14)
                            .frame(height: 46)
                            .background(fieldBg, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .overlay(alignment: .top) {
                            if isDropdownOpen {
                                ScrollView(showsIndicators: false) {
                                    VStack(alignment: .leading, spacing: 0) {
                                        ForEach(portfolios) { p in
                                            Button {
                                                selectedPortfolio = p
                                                withAnimation(.easeInOut(duration: 0.15)) { isDropdownOpen = false }
                                            } label: {
                                                Text(p.portfolioName)
                                                    .font(.system(size: 15, weight: .medium))
                                                    .foregroundColor(.primary)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding(.horizontal, 14)
                                                    .padding(.vertical, 12)
                                            }
                                            if p != portfolios.last {
                                                Divider().padding(.horizontal, 14)
                                            }
                                        }
                                    }
                                }
                                .frame(maxHeight: 220)
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                                .offset(y: 50)
                            }
                        }
                    }
                }
                .zIndex(10)

                // Tarih
                VStack(alignment: .leading, spacing: 4) {
                    fieldLabel("Tarih")
                    HStack {
                        Text("Tarih")
                            .font(.system(size: 15))
                            .foregroundColor(.primary)
                        Spacer()
                        DatePicker("", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                            .labelsHidden()
                            .environment(\.locale, Locale(identifier: "tr_TR"))
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 46)
                    .background(fieldBg, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .zIndex(9)
                .onChange(of: selectedDate) { newDate in
                    let calendar = Calendar.current
                    if calendar.isDateInWeekend(newDate) {
                        // Cumartesi (7) veya Pazar (1) seçildiyse önceki Cuma'ya sabitle
                        var components = DateComponents()
                        components.day = (calendar.component(.weekday, from: newDate) == 1) ? -2 : -1
                        if let friday = calendar.date(byAdding: components, to: newDate) {
                            selectedDate = friday
                        }
                    } else {
                        fetchPrice(for: newDate)
                    }
                }

                // Fiyat + Adet yan yana
                HStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 4) {
                        fieldLabel("Fiyat")
                        TextField("0,00", text: $price)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 15))
                            .padding(.horizontal, 14)
                            .frame(height: 46)
                            .background(fieldBg, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        fieldLabel("Adet")
                        TextField("0", text: $quantity)
                            .keyboardType(.numberPad)
                            .font(.system(size: 15))
                            .padding(.horizontal, 14)
                            .frame(height: 46)
                            .background(fieldBg, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }

                // Komisyon
                VStack(alignment: .leading, spacing: 4) {
                    fieldLabel("Komisyon (İsteğe Bağlı)")
                    TextField("0,00", text: $commission)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 15))
                        .padding(.horizontal, 14)
                        .frame(height: 46)
                        .background(fieldBg, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            Spacer()

            // MARK: - Kaydet butonu
            Button {
                savePosition()
            } label: {
                if isSaving {
                    ProgressView().tint(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            canSave ? accentGreen : Color(UIColor.systemGray3),
                            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                        )
                } else {
                    Text("Kaydet")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            canSave ? accentGreen : Color(UIColor.systemGray3),
                            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                        )
                }
            }
            .disabled(!canSave || selectedPortfolio == nil || isSaving)
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .onAppear {
            loadPortfolios()
            
            let calendar = Calendar.current
            if calendar.isDateInWeekend(selectedDate) {
                var components = DateComponents()
                components.day = (calendar.component(.weekday, from: selectedDate) == 1) ? -2 : -1
                if let friday = calendar.date(byAdding: components, to: selectedDate) {
                    selectedDate = friday
                    fetchPrice(for: friday)
                }
            } else {
                fetchPrice(for: selectedDate)
            }
        }
    }

    private func fetchPrice(for date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let dateString = formatter.string(from: date)
        
        ListsRepository().getPortfolioStockPrice(code: stockCode, date: dateString) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedPrice):
                    // Sadece 2 ondalık hane göster (örn: 15,30)
                    let formattedPrice = String(format: "%.2f", fetchedPrice).replacingOccurrences(of: ".", with: ",")
                    self.price = formattedPrice
                case .failure:
                    // Hata olursa kullanıcı kendi girebilir
                    if self.price.isEmpty || self.price.starts(with: "Yanıt") || self.price.starts(with: "The data couldn't") {
                        self.price = ""
                    }
                }
            }
        }
    }
    
    private func loadPortfolios() {
        isLoadingPortfolios = true
        ListsRepository().getPortfoliosInfo { result in
            DispatchQueue.main.async {
                self.isLoadingPortfolios = false
                switch result {
                case .success(let data):
                    self.portfolios = data
                    self.selectedPortfolio = data.first
                case .failure:
                    // Hata durumunda boş liste kalacak, kullanıcıya uyarı gösterilebilir
                    break
                }
            }
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.secondary)
            .textCase(.uppercase)
            .tracking(0.4)
    }

    private func parseDouble(_ text: String) -> Double {
        let cleanText = text.replacingOccurrences(of: ",", with: ".")
        return Double(cleanText) ?? 0.0
    }

    private func savePosition() {
        guard let portfolioId = selectedPortfolio?.portfolioId else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let dateString = formatter.string(from: selectedDate)
        
        let request = AddPositionRequest(
            portfolioId: portfolioId,
            code: stockCode,
            buyQuantity: parseDouble(quantity),
            buyDate: dateString,
            buyPrice: parseDouble(price),
            commission: parseDouble(commission)
        )
        
        isSaving = true
        ListsRepository().addPosition(request: request) { result in
            DispatchQueue.main.async {
                isSaving = false
                switch result {
                case .success:
                    onClose()
                case .failure(let error):
                    print("Pozisyon eklenemedi: \(error)")
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    Color.black.opacity(0.4)
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            PozisyonAcSheet(stockCode: "TKNSA")
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
}

