import SwiftUI

struct AddView: View {
    private enum MenuItem: String, CaseIterable {
        case filtration = "Filtreleme"
        case sectoralAnalysis = "Sektörel Analiz"
        case technicalScanner = "Teknik Tarayıcı"

        var icon: String {
            switch self {
            case .filtration:
                return "line.3.horizontal.decrease.circle"
            case .sectoralAnalysis:
                return "chart.pie"
            case .technicalScanner:
                return "magnifyingglass.circle"
            }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(MenuItem.allCases, id: \.self) { item in
                    NavigationLink(destination: destination(for: item)) {
                        HStack(spacing: 14) {
                            Image(systemName: item.icon)
                                .foregroundStyle(.blue)
                                .frame(width: 28)
                            Text(item.rawValue)
                                .font(.body)
                            Spacer()
                                .foregroundStyle(.secondary)
                                .font(.caption.weight(.semibold))
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                }
            }
            .listStyle(.insetGrouped)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private func destination(for item: MenuItem) -> some View {
        switch item {
        case .filtration:
            StockScannerView()
        case .sectoralAnalysis:
            SectoralAnalysisView()
        case .technicalScanner:
            TeknikTarayiciView()
        }
    }
}
