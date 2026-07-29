import SwiftUI

private let finnetGreen = Color(red: 0.161, green: 0.749, blue: 0.451)

struct PriceAlarmsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: AlarmTab = .targetPrice

    enum AlarmTab: Int, CaseIterable {
        case targetPrice, totalPercentage, dailyPercentage

        var title: String {
            switch self {
            case .targetPrice:      return "Hedef Fiyat"
            case .totalPercentage:  return "Toplam Yüzde Değişim"
            case .dailyPercentage:  return "Günlük Yüzde Değişim"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            tabBar
            tabContent
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Fiyat Alarmları")
        .navigationBarTitleDisplayMode(.inline)
        .transparentNavigationBar()
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(AlarmTab.allCases, id: \.self) { tab in
                    tabItem(tab)
                }
            }
        }
        .background(Color(.systemBackground))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 1)
        }
    }

    private func tabItem(_ tab: AlarmTab) -> some View {
        let isSelected = selectedTab == tab

        return Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
        }) {
            VStack(spacing: 0) {
                Text(tab.title)
                    .font(.system(size: 14, weight: isSelected ? .bold : .regular))
                    .foregroundColor(isSelected ? .primary : .secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .fixedSize()

                Rectangle()
                    .fill(isSelected ? finnetGreen : Color.clear)
                    .frame(height: 2)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Tab Content

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .targetPrice:
            AlarmEmptyView()
        case .totalPercentage:
            AlarmEmptyView()
        case .dailyPercentage:
            AlarmEmptyView()
        }
    }
}

// MARK: - Empty State

private struct AlarmEmptyView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Fiyat alarmınız bulunmamaktadır.")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    PriceAlarmsView()
}
