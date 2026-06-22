import SwiftUI

private struct SummaryRow: Identifiable {
    let id = UUID()
    let parameter: String
    let value: String
}

private let summaryRows: [SummaryRow] = [
    .init(parameter: "Müşteri Kredi Limiti",        value: "0.00"),
    .init(parameter: "Kredili İşlem Limiti",         value: "0.00"),
    .init(parameter: "Açığa İşlem Limiti",           value: "0.00"),
    .init(parameter: "Virmanlı Satış Limiti",        value: "0.00"),
    .init(parameter: "T Kredi Özkaynak Oranı",       value: "100.00"),
    .init(parameter: "T1 Kredi Özkaynak Oranı",      value: "100.00"),
    .init(parameter: "T2 Kredi Özkaynak Oranı",      value: "100.00"),
    .init(parameter: "Cari Bakiye",                  value: "1331.46"),
    .init(parameter: "T1 Cari Bakiye",               value: "1331.46"),
    .init(parameter: "T2 Cari Bakiye",               value: "1337.98"),
    .init(parameter: "Güniçi İşlem Limiti",          value: "1337.98"),
    .init(parameter: "Islem Limiti",                 value: "1337.98"),
    .init(parameter: "Alım Satım Neti",              value: "6.52"),
    .init(parameter: "Hisse Toplamı",                value: "8438.45"),
    .init(parameter: "Overall",                      value: "9776.41"),
    .init(parameter: "T1 Overall",                   value: "9776.41"),
    .init(parameter: "T2 Overall",                   value: "9776.43"),
    .init(parameter: "Açığa Satış",                  value: "A"),
    .init(parameter: "Güniçi",                       value: "G"),
    .init(parameter: "Kredili",                      value: "K"),
    .init(parameter: "Normal",                       value: "N"),
    .init(parameter: "Özel",                         value: "O"),
    .init(parameter: "Virmanlı Satış",               value: "V"),
]

private struct SummaryStat: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let tint: Color
}

private let summaryStats: [SummaryStat] = [
    .init(title: "Cari Bakiye", value: "1331.46", tint: Color(red: 0.196, green: 0.717, blue: 0.486)),
    .init(title: "Hisse Toplamı", value: "8438.45", tint: Color(red: 0.078, green: 0.49, blue: 0.84)),
    .init(title: "Overall", value: "9776.41", tint: Color(red: 0.88, green: 0.48, blue: 0.12)),
]

struct AccountSummaryView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            navBar

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    accountCard
                    statsStrip
                    tableCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
        .navigationBarHidden(true)
        .background(Color(UIColor.systemGroupedBackground))
    }

    // MARK: - Nav bar

    private var navBar: some View {
        ZStack {
            Color.white
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(width: 44, height: 44, alignment: .leading)
                }
                .buttonStyle(.plain)

                Spacer()

                Text("Hesap Özeti")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.black)

                Spacer()

                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 56)
    }

    // MARK: - Account card

    private var accountCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Hesap Numarası : 47841")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color(.label))

                    Text("A1 Capital")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(red: 0.196, green: 0.717, blue: 0.486))
                }

                Spacer(minLength: 12)

                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(red: 0.196, green: 0.717, blue: 0.486))
                    .frame(width: 38, height: 38)
                    .background(Color(red: 0.196, green: 0.717, blue: 0.486).opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }

            HStack(spacing: 8) {
                Label("Aktif Hesap", systemImage: "checkmark.seal.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color(red: 0.196, green: 0.717, blue: 0.486))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Color(red: 0.196, green: 0.717, blue: 0.486).opacity(0.10), in: Capsule())

                Label("Matriks Bağlı", systemImage: "link")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color(.secondaryLabel))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Color(.systemGray6), in: Capsule())

                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            LinearGradient(
                colors: [Color.white, Color(red: 0.98, green: 0.99, blue: 1.0)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.07), radius: 10, x: 0, y: 5)
    }

    private var statsStrip: some View {
        HStack(spacing: 10) {
            ForEach(summaryStats) { stat in
                VStack(alignment: .leading, spacing: 8) {
                    Text(stat.title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color(.secondaryLabel))

                    Text(stat.value)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color(.label))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    RoundedRectangle(cornerRadius: 999, style: .continuous)
                        .fill(stat.tint)
                        .frame(width: 32, height: 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(stat.tint.opacity(0.18), lineWidth: 1)
                )
            }
        }
    }

    // MARK: - Table card

    private var tableCard: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Parametre")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color(.label))
                Spacer()
                Text("Değer")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color(.label))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(red: 0.96, green: 0.96, blue: 0.99))

            Rectangle()
                .fill(Color(.separator).opacity(0.5))
                .frame(height: 0.5)

            ForEach(Array(summaryRows.enumerated()), id: \.element.id) { idx, row in
                HStack(alignment: .top) {
                    Text(row.parameter)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color(.label))
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(row.value)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(.label))
                        .frame(width: 90, alignment: .trailing)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(idx.isMultiple(of: 2) ? Color.white : Color(red: 0.98, green: 0.98, blue: 1.0))

                if idx < summaryRows.count - 1 {
                    Rectangle()
                        .fill(Color(.separator).opacity(0.4))
                        .frame(height: 0.5)
                }
            }
        }
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.07), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    NavigationStack {
        AccountSummaryView()
    }
}
