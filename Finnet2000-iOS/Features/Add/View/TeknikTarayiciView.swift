import SwiftUI

// MARK: - Model

struct TeknikScannerRow: Identifiable {
    let id = UUID()
    let code: String
    let ma5Signal: String
    let ma5To20Signal: String
    let ma20Signal: String
    let rsiSignal: String
    let macdSignal: String
    let bollingerSignal: String
}

// MARK: - Signal Display

private func signalColor(_ value: String) -> Color {
    let lower = value.lowercased()
    if lower == "al" { return Color.signalAl }
    if lower == "sat" { return Color.signalSat }
    return .secondary
}

private func signalWeight(_ value: String) -> Font.Weight {
    let lower = value.lowercased()
    if lower == "al" || lower == "sat" { return .bold }
    return .regular
}

// MARK: - Mock Data

private enum TeknikMockData {
    static let alRows: [TeknikScannerRow] = [
        TeknikScannerRow(code: "ALCAR", ma5Signal: "-",   ma5To20Signal: "AL",  ma20Signal: "-",   rsiSignal: "-",   macdSignal: "-",   bollingerSignal: "-"),
        TeknikScannerRow(code: "BESLR", ma5Signal: "-",   ma5To20Signal: "AL",  ma20Signal: "-",   rsiSignal: "-",   macdSignal: "-",   bollingerSignal: "-"),
        TeknikScannerRow(code: "BIENY", ma5Signal: "-",   ma5To20Signal: "-",   ma20Signal: "-",   rsiSignal: "-",   macdSignal: "-",   bollingerSignal: "-"),
        TeknikScannerRow(code: "BMSTL", ma5Signal: "-",   ma5To20Signal: "-",   ma20Signal: "-",   rsiSignal: "-",   macdSignal: "-",   bollingerSignal: "-"),
        TeknikScannerRow(code: "EGPRO", ma5Signal: "-",   ma5To20Signal: "al",  ma20Signal: "-",   rsiSignal: "-",   macdSignal: "-",   bollingerSignal: "-"),
        TeknikScannerRow(code: "ENERY", ma5Signal: "-",   ma5To20Signal: "-",   ma20Signal: "-",   rsiSignal: "-",   macdSignal: "-",   bollingerSignal: "-"),
        TeknikScannerRow(code: "EYGYO", ma5Signal: "-",   ma5To20Signal: "sat", ma20Signal: "-",   rsiSignal: "-",   macdSignal: "-",   bollingerSignal: "-"),
        TeknikScannerRow(code: "KARSN", ma5Signal: "-",   ma5To20Signal: "AL",  ma20Signal: "-",   rsiSignal: "-",   macdSignal: "-",   bollingerSignal: "-"),
        TeknikScannerRow(code: "KLYPV", ma5Signal: "-",   ma5To20Signal: "AL",  ma20Signal: "-",   rsiSignal: "-",   macdSignal: "-",   bollingerSignal: "-"),
        TeknikScannerRow(code: "KRPLS", ma5Signal: "-",   ma5To20Signal: "-",   ma20Signal: "-",   rsiSignal: "-",   macdSignal: "-",   bollingerSignal: "-"),
        TeknikScannerRow(code: "SELVA", ma5Signal: "-",   ma5To20Signal: "-",   ma20Signal: "-",   rsiSignal: "-",   macdSignal: "-",   bollingerSignal: "-"),
        TeknikScannerRow(code: "ULUUN", ma5Signal: "-",   ma5To20Signal: "AL",  ma20Signal: "-",   rsiSignal: "-",   macdSignal: "-",   bollingerSignal: "-"),
        TeknikScannerRow(code: "VSNMD", ma5Signal: "-",   ma5To20Signal: "AL",  ma20Signal: "-",   rsiSignal: "-",   macdSignal: "-",   bollingerSignal: "-"),
        TeknikScannerRow(code: "YAYLA", ma5Signal: "-",   ma5To20Signal: "sat", ma20Signal: "-",   rsiSignal: "-",   macdSignal: "-",   bollingerSignal: "-"),
        TeknikScannerRow(code: "AKMGY", ma5Signal: "AL",  ma5To20Signal: "al",  ma20Signal: "-",   rsiSignal: "-",   macdSignal: "-",   bollingerSignal: "-"),
        TeknikScannerRow(code: "ANHYT", ma5Signal: "AL",  ma5To20Signal: "AL",  ma20Signal: "-",   rsiSignal: "-",   macdSignal: "-",   bollingerSignal: "-"),
    ]

    static let satRows: [TeknikScannerRow] = [
        TeknikScannerRow(code: "AKMGY", ma5Signal: "-",   ma5To20Signal: "-",   ma20Signal: "-",   rsiSignal: "-",   macdSignal: "-",   bollingerSignal: "-"),
        TeknikScannerRow(code: "BRMEN", ma5Signal: "-",   ma5To20Signal: "-",   ma20Signal: "SAT", rsiSignal: "-",   macdSignal: "-",   bollingerSignal: "-"),
        TeknikScannerRow(code: "CELHA", ma5Signal: "-",   ma5To20Signal: "-",   ma20Signal: "-",   rsiSignal: "SAT", macdSignal: "-",   bollingerSignal: "-"),
        TeknikScannerRow(code: "DUNYH", ma5Signal: "-",   ma5To20Signal: "-",   ma20Signal: "-",   rsiSignal: "-",   macdSignal: "SAT", bollingerSignal: "-"),
        TeknikScannerRow(code: "AHGAZ", ma5Signal: "SAT", ma5To20Signal: "-",   ma20Signal: "SAT", rsiSignal: "-",   macdSignal: "-",   bollingerSignal: "-"),
        TeknikScannerRow(code: "AKHAN", ma5Signal: "SAT", ma5To20Signal: "sat", ma20Signal: "-",   rsiSignal: "SAT", macdSignal: "-",   bollingerSignal: "-"),
        TeknikScannerRow(code: "AKSA",  ma5Signal: "SAT", ma5To20Signal: "-",   ma20Signal: "-",   rsiSignal: "-",   macdSignal: "SAT", bollingerSignal: "-"),
        TeknikScannerRow(code: "ALFAS", ma5Signal: "SAT", ma5To20Signal: "-",   ma20Signal: "SAT", rsiSignal: "-",   macdSignal: "-",   bollingerSignal: "SAT"),
        TeknikScannerRow(code: "ALKIM", ma5Signal: "SAT", ma5To20Signal: "sat", ma20Signal: "-",   rsiSignal: "SAT", macdSignal: "SAT", bollingerSignal: "-"),
        TeknikScannerRow(code: "ANELE", ma5Signal: "SAT", ma5To20Signal: "-",   ma20Signal: "-",   rsiSignal: "-",   macdSignal: "-",   bollingerSignal: "SAT"),
        TeknikScannerRow(code: "ARDYZ", ma5Signal: "SAT", ma5To20Signal: "-",   ma20Signal: "SAT", rsiSignal: "-",   macdSignal: "-",   bollingerSignal: "-"),
        TeknikScannerRow(code: "ASTOR", ma5Signal: "SAT", ma5To20Signal: "-",   ma20Signal: "-",   rsiSignal: "SAT", macdSignal: "-",   bollingerSignal: "-"),
        TeknikScannerRow(code: "ATATP", ma5Signal: "SAT", ma5To20Signal: "-",   ma20Signal: "-",   rsiSignal: "-",   macdSignal: "SAT", bollingerSignal: "-"),
        TeknikScannerRow(code: "AYEN",  ma5Signal: "SAT", ma5To20Signal: "sat", ma20Signal: "SAT", rsiSignal: "-",   macdSignal: "-",   bollingerSignal: "-"),
        TeknikScannerRow(code: "BAKAB", ma5Signal: "SAT", ma5To20Signal: "-",   ma20Signal: "-",   rsiSignal: "SAT", macdSignal: "-",   bollingerSignal: "SAT"),
        TeknikScannerRow(code: "BIGEN", ma5Signal: "SAT", ma5To20Signal: "-",   ma20Signal: "SAT", rsiSignal: "-",   macdSignal: "-",   bollingerSignal: "-"),
    ]
}

// MARK: - View

struct TeknikTarayiciView: View {
    @Namespace private var animation
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: ScanTab = .al
    @State private var showFilterSheet = false

    enum ScanTab { case al, sat }

    private let columns: [(header: String, keyPath: KeyPath<TeknikScannerRow, String>)] = [
        ("MA5 Sinyal",       \TeknikScannerRow.ma5Signal),
        ("MA5>20 Sinyal",    \TeknikScannerRow.ma5To20Signal),
        ("MA20 Sinyal",      \TeknikScannerRow.ma20Signal),
        ("RSI Sinyal",       \TeknikScannerRow.rsiSignal),
        ("MACD Sinyal",      \TeknikScannerRow.macdSignal),
        ("Bollinger Sinyal", \TeknikScannerRow.bollingerSignal),
    ]

    private var rows: [TeknikScannerRow] {
        selectedTab == .al ? TeknikMockData.alRows : TeknikMockData.satRows
    }

    // MARK: Body

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                segmentedControl
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)

                tableContainer
            }
            .padding(.bottom, 80)


            floatingFilterButton
        }
        .navigationTitle("Teknik Tarayıcı")
        .navigationBarTitleDisplayMode(.inline)
        .transparentNavigationBar()
        .sheet(isPresented: $showFilterSheet) {
            TeknikFilterSheet()
        }
    }

    // MARK: - Segmented Control

    private var segmentedControl: some View {
        HStack(spacing: 0) {
            segmentButton(tab: .al, iconName: "arrow.up.right", label: "AL")
            segmentButton(tab: .sat, iconName: "arrow.down.right", label: "SAT")
        }
        .padding(4)
        .background(Color.secondaryBackground, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func segmentButton(tab: ScanTab, iconName: String, label: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.system(size: 14, weight: .semibold))
                Text(label)
                    .font(.system(size: 15, weight: .bold))
            }
            .foregroundColor(selectedTab == tab ? .primary : .secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background {
                if selectedTab == tab {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.primaryBackground)
                        .shadow(color: .black.opacity(0.1), radius: 3, y: 2)
                        .matchedGeometryEffect(id: "segment-bg", in: animation)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Table

    private var tableContainer: some View {
        VStack(spacing: 0) {
            tableHeader
            Divider()
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(Array(rows.enumerated()), id: \.element.id) { idx, row in
                        tableRow(row, isEven: idx % 2 == 0)
                        Divider()
                    }
                }
            }
        }
        .background(Color.primaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }

    private var tableHeader: some View {
        HStack(spacing: 0) {
            Text("Kod")
                .font(.system(size: 14, weight: .semibold))
                .frame(width: 80, alignment: .leading)
                .padding(.leading, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(columns.indices, id: \.self) { i in
                        Text(columns[i].header)
                            .font(.system(size: 14, weight: .semibold))
                            .frame(width: 120, alignment: .leading)
                            .lineLimit(2)
                    }
                }
            }
        }
        .foregroundColor(.secondary)
        .padding(.vertical, 12)
    }

    private func tableRow(_ row: TeknikScannerRow, isEven: Bool) -> some View {
        HStack(spacing: 0) {
            Text(row.code)
                .font(.system(size: 14, weight: .semibold))
                .frame(width: 80, alignment: .leading)
                .padding(.leading, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(columns.indices, id: \.self) { i in
                        let value = row[keyPath: columns[i].keyPath]
                        Text(value)
                            .font(.system(size: 14, weight: signalWeight(value)))
                            .foregroundColor(signalColor(value))
                            .frame(width: 120, alignment: .leading)
                    }
                }
            }
        }
        .padding(.vertical, 16)
        .background(isEven ? Color.primaryBackground : Color.secondaryBackground.opacity(0.4))
    }

    // MARK: - Floating Filter Button

    private var floatingFilterButton: some View {
        Button {
            showFilterSheet = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.system(size: 17, weight: .semibold))
                Text("Endeks/Sektör Filtrele")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(.primary)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(Color.primaryBackground)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.secondary.opacity(0.2), lineWidth: 1))
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .padding(.bottom, 24)
    }
}


// MARK: - Filter Sheet (Unchanged but included for completeness)

private struct TeknikFilterSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var ulusalExpanded    = true
    @State private var sektorelExpanded  = true
    @State private var sektorlerExpanded = true
    @State private var selectedItems: Set<String> = []
    @State private var ulusalPage    = 0
    @State private var sektorelPage  = 0
    @State private var sektorlerPage = 0

    private let ulusalItems: [String] = [
        "XU100", "XU050", "XU030", "XUTUM", "XIKIU",
        "XKURY", "XYUZO", "XTUMY"
    ]
    private let sektorelItems: [String] = [
        "XUSIN", "XGIDA", "XTEKS", "XKAGT", "XKMYA",
        "XTAST", "XMANA", "XMESY"
    ]
    private let sektorlerItems: [String] = [
        "Madencilik ve Kıymetli Maden", "Tekstil Ürünleri",
        "Deri ve Benzer Ürünler",       "Giyim Eşyası",
        "Orman Ürünleri Ve Mobilya",    "Boya",
        "Gübre ve Zirai Ürünler",       "İlaç&Sağlık"
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Tarayıcıyı Filtrele")
                    .font(.system(size: 24, weight: .bold))
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(width: 34, height: 34)
                        .background(Color.secondaryBackground, in: Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 12)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    sectionView(
                        title: "Ulusal Endeksler",
                        items: ulusalItems,
                        isExpanded: $ulusalExpanded,
                        currentPage: $ulusalPage,
                        totalDots: 5,
                        itemsPerRow: 5
                    )
                    sectionView(
                        title: "Sektörel Endeksler",
                        items: sektorelItems,
                        isExpanded: $sektorelExpanded,
                        currentPage: $sektorelPage,
                        totalDots: 6,
                        itemsPerRow: 5
                    )
                    sectionView(
                        title: "Sektörler",
                        items: sektorlerItems,
                        isExpanded: $sektorlerExpanded,
                        currentPage: $sektorlerPage,
                        totalDots: 9,
                        itemsPerRow: 2
                    )
                }
                .padding(.bottom, 16)
            }

            // Kaydet button
            Button { dismiss() } label: {
                Text("Filtreyi Uygula")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.midGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .shadow(color: Color.midGreen.opacity(0.4), radius: 8, y: 4)
        }
        .background(Color.primaryBackground)
    }

    @ViewBuilder
    private func sectionView(
        title: String,
        items: [String],
        isExpanded: Binding<Bool>,
        currentPage: Binding<Int>,
        totalDots: Int,
        itemsPerRow: Int
    ) -> some View {
        let pages = makePages(items: items, itemsPerPage: 10)

        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.22)) {
                    isExpanded.wrappedValue.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .rotationEffect(.degrees(isExpanded.wrappedValue ? 0 : -180))
                }
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .buttonStyle(.plain)

            if isExpanded.wrappedValue {
                VStack(spacing: 12) {
                    TabView(selection: currentPage) {
                        ForEach(pages.indices, id: \.self) { pi in
                            chipPageView(items: pages[pi], itemsPerRow: itemsPerRow)
                                .tag(pi)
                                .padding(.horizontal, 20)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: chipGridHeight(
                        itemCount: pages.first?.count ?? 0,
                        itemsPerRow: itemsPerRow
                    ))

                    pageDotsView(total: totalDots, current: currentPage.wrappedValue)
                        .padding(.bottom, 16)
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.95, anchor: .top)),
                    removal: .opacity
                ))
            }
        }
    }

    private func makePages(items: [String], itemsPerPage: Int) -> [[String]] {
        stride(from: 0, to: items.count, by: itemsPerPage).map {
            Array(items[$0..<min($0 + itemsPerPage, items.count)])
        }
    }

    @ViewBuilder
    private func chipPageView(items: [String], itemsPerRow: Int) -> some View {
        let rows = stride(from: 0, to: items.count, by: itemsPerRow).map {
            Array(items[$0..<min($0 + itemsPerRow, items.count)])
        }
        VStack(alignment: .leading, spacing: 10) {
            ForEach(rows.indices, id: \.self) { ri in
                HStack(spacing: 8) {
                    ForEach(rows[ri], id: \.self) { item in
                        chipToggle(item)
                    }
                    Spacer(minLength: 0)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 3)
    }

    private func chipToggle(_ item: String) -> some View {
        Button {
            if selectedItems.contains(item) {
                selectedItems.remove(item)
            } else {
                selectedItems.insert(item)
            }
        } label: {
            let isSelected = selectedItems.contains(item)
            Text(item)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .lineLimit(1)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background {
                    if isSelected {
                        Capsule().fill(Color.midGreen)
                    } else {
                        Capsule().fill(Color.secondaryBackground)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    private func chipGridHeight(itemCount: Int, itemsPerRow: Int) -> CGFloat {
        guard itemCount > 0 else { return 44 }
        let rows = Int(ceil(Double(itemCount) / Double(itemsPerRow)))
        let chipH: CGFloat = 44
        let spacing: CGFloat = 10
        return CGFloat(rows) * chipH + CGFloat(max(0, rows - 1)) * spacing + 6
    }

    private func pageDotsView(total: Int, current: Int) -> some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { i in
                Circle()
                    .fill(i == current ? Color.midGreen : Color.secondaryBackground)
                    .frame(width: 8, height: 8)
                    .scaleEffect(i == current ? 1.2 : 1.0)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: current)
        .padding(.horizontal, 20)
    }
}


#Preview {
    NavigationView {
        TeknikTarayiciView()
    }
    .preferredColorScheme(.dark)
}

#Preview {
    NavigationView {
        TeknikTarayiciView()
    }
    .preferredColorScheme(.light)
}
