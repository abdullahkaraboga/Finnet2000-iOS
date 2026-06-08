import SwiftUI

// MARK: - PozisyonAcSheet

struct PozisyonAcSheet: View {
    var onClose: () -> Void = {}

    private let portfolios = [
        "Ana Portföy",
        "Büyüme Fonu",
        "Temettü Portföyü",
        "Emeklilik",
        "Kısa Vadeli"
    ]

    @State private var selectedPortfolio = "Ana Portföy"
    @State private var selectedDate = Date()
    @State private var price = ""
    @State private var quantity = "0"
    @State private var commission = ""

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
                    Menu {
                        ForEach(portfolios, id: \.self) { p in
                            Button(p) { selectedPortfolio = p }
                        }
                    } label: {
                        HStack {
                            Text(selectedPortfolio)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 46)
                        .background(fieldBg, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }

                // Tarih
                VStack(alignment: .leading, spacing: 4) {
                    fieldLabel("Tarih")
                    ZStack {
                        HStack {
                            Text(dateFormatted)
                                .font(.system(size: 15))
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "calendar")
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 46)
                        .background(fieldBg, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                        DatePicker("", selection: $selectedDate, displayedComponents: .date)
                            .labelsHidden()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .opacity(0.011)
                    }
                    .frame(height: 46)
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
                onClose()
            } label: {
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
            .disabled(!canSave)
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.secondary)
            .textCase(.uppercase)
            .tracking(0.4)
    }
}

// MARK: - Preview

#Preview {
    Color.black.opacity(0.4)
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            PozisyonAcSheet()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
}

