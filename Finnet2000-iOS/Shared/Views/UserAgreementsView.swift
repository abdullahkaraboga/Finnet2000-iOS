import SwiftUI

private let finnetGreen = Color(red: 0.161, green: 0.749, blue: 0.451)

struct UserAgreementsView: View {

    private let items: [String] = [
        "Finnet Kullanıcı Sözleşmesi",
        "Gizlilik Politikası",
        "Kişisel Verilerin Korunması",
        "Yasal Uyarı",
        "Kişisel Veri Başvuru Formu",
        "Kişisel Verilerin İşlenmesi Açık Rıza Beyanı"
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(items, id: \.self) { item in
                    agreementRow(title: item)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 32)
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Kullanıcı Sözleşmeleri")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.white)
                }
            }
        }
    }

    @ViewBuilder
    private func agreementRow(title: String) -> some View {
        Button(action: { }) {
            HStack {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(finnetGreen)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}
