import SwiftUI

// MARK: - AlarmOlusturSheet

struct AlarmOlusturSheet: View {
    @Binding var isPresented: Bool

    enum AlarmKriter: String, CaseIterable {
        case hedefFiyat         = "Hedef Fiyat"
        case toplamYuzde        = "Toplam Yüzde Değişim"
        case gunlukYuzde        = "Günlük Yüzde Değişim"
    }

    @State private var selectedKriter: AlarmKriter = .hedefFiyat
    @State private var fiyat = ""

    private let accentGreen = Color(red: 0.18, green: 0.72, blue: 0.40)
    private let headerGreen = Color(red: 0.72, green: 0.91, blue: 0.81)
    private let fieldBg     = Color(UIColor.secondarySystemGroupedBackground)

    private var canSave: Bool { !fiyat.isEmpty }

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Alarm Oluştur butonu (üst bant)
            Button {
                // Alarm oluştur aksiyonu
                isPresented = false
            } label: {
                Text("Alarm Oluştur")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.black.opacity(0.75))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(headerGreen, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.top, 24)

            // MARK: - Form
            VStack(spacing: 20) {

                // Kriterler satırı
                HStack(spacing: 12) {
                    HStack(spacing: 6) {
                        Text("Kriterler")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.primary)
                        Image(systemName: "info.circle")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Menu {
                        ForEach(AlarmKriter.allCases, id: \.self) { k in
                            Button(k.rawValue) { selectedKriter = k }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text(selectedKriter.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(accentGreen)
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 44)
                        .background(fieldBg, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }

                // Fiyat satırı
                HStack(spacing: 12) {
                    Text("Fiyat")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)

                    Spacer()

                    TextField("Fiyat", text: $fiyat)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 15))
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 14)
                        .frame(width: 180, height: 44)
                        .background(fieldBg, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)

            Spacer()

            // MARK: - Kaydet
            Button {
                isPresented = false
            } label: {
                Text("Kaydet")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(canSave ? .white : Color(UIColor.systemGray))
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        canSave ? accentGreen : Color(UIColor.systemGray4),
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                    )
            }
            .disabled(!canSave)
            .padding(.horizontal, 20)
            .padding(.bottom, 36)
        }
    }
}

// MARK: - Preview

#Preview {
    Color(.systemBackground)
        .sheet(isPresented: .constant(true)) {
            AlarmOlusturSheet(isPresented: .constant(true))
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
}
