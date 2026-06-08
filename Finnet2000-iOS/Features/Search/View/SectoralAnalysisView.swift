import SwiftUI

// MARK: - SectorRow

struct SectorRow: Identifiable {
    let id = UUID()
    let sektor: String
    let aktifKarlilik: Double   // % e.g. 0.28 → %0,28
    let pdDd: Double
    let fdFavok: Double
    let roic: Double            // %
    let ozserKarlilik: Double   // %
    let fiyatKazanc: Double
}

// MARK: - Financial Stock Models

struct FinancialStock: Identifiable {
    let id = UUID()
    let code: String
    let donenVarliklar: Double
    let duranVarliklar: Double
    let toplamVarliklar: Double
    let kisaVadeliYuk: Double
    let uzunVadeliYuk: Double
    let ozkaynaklar: Double
}

struct FinancialSectorGroup: Identifiable {
    let id = UUID()
    let name: String
    let stocks: [FinancialStock]
}

// MARK: - SectoralAnalysisView

struct SectoralAnalysisView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: SATab = .genelBakis
    @State private var sortCol: SortCol = .aktifKarlilik
    @State private var ascending = true
    @State private var hOffset: CGFloat = 0
    @State private var hOffsetAtDragStart: CGFloat = 0
    // Sektörel Analiz tab state
    @State private var saSubTab: SASubTab = .finansallar
    @State private var finSubTab: FinSubTab = .bilanco
    @State private var selectedGroupIndex: Int = 0
    @State private var showingSectorPicker: Bool = false
    @State private var sectorSearchText: String = ""
    @State private var sHOffset: CGFloat = 0
    @State private var sHOffsetAtStart: CGFloat = 0
    @State private var stockSortCol: StockSortCol = .donenVarliklar
    @State private var stockSortAscending: Bool = true

    enum SATab: String, CaseIterable {
        case genelBakis     = "Genel Bakış"
        case sektorelAnaliz = "Sektörel Analiz"
    }

    enum SortCol {
        case sektor, aktifKarlilik, pdDd, fdFavok, roic, ozserKarlilik, fiyatKazanc
    }

    enum SASubTab: String, CaseIterable {
        case finansallar  = "Finansallar"
        case oranlar      = "Oranlar"
        case getiriRisk   = "Getiri & Risk"
        case teknikAnaliz = "Teknik Analiz"
    }

    enum FinSubTab: String, CaseIterable {
        case bilanco      = "Bilanço"
        case gelirTablosu = "Gelir Tablosu"
        case nakitAkim    = "Nakit Akım"
    }

    enum StockSortCol {
        case donenVarliklar, duranVarliklar, toplamVarliklar, kisaVadeliYuk, uzunVadeliYuk, ozkaynaklar
    }

    // MARK: - Layout Constants
    private let sektorWidth: CGFloat    = 110
    private let colAktif: CGFloat       = 82
    private let colPdDd: CGFloat        = 70
    private let colFd: CGFloat          = 78
    private let colRoic: CGFloat        = 70
    private let colOzser: CGFloat       = 90
    private let colFiyatKazanc: CGFloat = 78

    private var numericTotalWidth: CGFloat {
        colAktif + colPdDd + colFd + colRoic + colOzser + colFiyatKazanc + 16
    }
    private var numericVisibleWidth: CGFloat {
        UIScreen.main.bounds.width - sektorWidth
    }
    private var maxHOffset: CGFloat {
        max(0, numericTotalWidth - numericVisibleWidth)
    }

    // Stock table layout (Sektörel Analiz tab)
    private let hisseWidth: CGFloat = 70
    private let stockColW: CGFloat  = 120

    private var sNumericVisible: CGFloat {
        UIScreen.main.bounds.width - hisseWidth
    }
    private var sMaxHOffset: CGFloat {
        max(0, 6 * stockColW + 12 - sNumericVisible)
    }

    private var sortedRows: [SectorRow] {
        SAMockData.rows.sorted {
            switch sortCol {
            case .sektor:        return ascending ? $0.sektor < $1.sektor : $0.sektor > $1.sektor
            case .aktifKarlilik: return ascending ? $0.aktifKarlilik < $1.aktifKarlilik : $0.aktifKarlilik > $1.aktifKarlilik
            case .pdDd:          return ascending ? $0.pdDd < $1.pdDd : $0.pdDd > $1.pdDd
            case .fdFavok:       return ascending ? $0.fdFavok < $1.fdFavok : $0.fdFavok > $1.fdFavok
            case .roic:          return ascending ? $0.roic < $1.roic : $0.roic > $1.roic
            case .ozserKarlilik: return ascending ? $0.ozserKarlilik < $1.ozserKarlilik : $0.ozserKarlilik > $1.ozserKarlilik
            case .fiyatKazanc:   return ascending ? $0.fiyatKazanc < $1.fiyatKazanc : $0.fiyatKazanc > $1.fiyatKazanc
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            navBar
            tabBar

            if selectedTab == .genelBakis {
                genelBakisTab
            } else {
                sektorelAnalizTab
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Nav Bar

    private var navBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)

            Spacer()

            Text("Sektörel Analiz")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)

            Spacer()

            Button {} label: {
                Image(systemName: "info.circle")
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .background {
            Color.black.ignoresSafeArea(edges: .top)
        }
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(SATab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedTab = tab }
                } label: {
                    VStack(spacing: 0) {
                        Text(tab.rawValue)
                            .font(.system(size: 14, weight: selectedTab == tab ? .semibold : .regular))
                            .foregroundColor(selectedTab == tab ? .primary : .secondary)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                        Rectangle()
                            .fill(selectedTab == tab ? Color.midGreen : Color.clear)
                            .frame(height: 2)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .background(Color(.systemBackground))
        .overlay(alignment: .bottom) { Divider() }
    }

    // MARK: - Genel Bakış Tab

    private var genelBakisTab: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                Section {
                    ForEach(Array(sortedRows.enumerated()), id: \.element.id) { idx, row in
                        tableRow(row, idx: idx)
                        Divider()
                    }
                } header: {
                    tableHeader
                }
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 5)
                .onChanged { value in
                    guard abs(value.translation.width) > abs(value.translation.height) else { return }
                    let proposed = hOffsetAtDragStart - value.translation.width
                    hOffset = max(0, min(proposed, maxHOffset))
                }
                .onEnded { _ in
                    hOffsetAtDragStart = hOffset
                }
        )
        .background(Color(.systemBackground))
    }

    // MARK: - Table Header

    private var tableHeader: some View {
        HStack(spacing: 0) {
            // Fixed sector header
            sectorHeaderCell

            // Scrollable numeric headers
            HStack(spacing: 0) {
                numericHeaderCell("Aktif\nKarlılık",   col: .aktifKarlilik,  width: colAktif)
                numericHeaderCell("PD / DD",          col: .pdDd,           width: colPdDd)
                numericHeaderCell("Firma Değ.\nFAVÖK", col: .fdFavok,        width: colFd)
                numericHeaderCell("ROIC",              col: .roic,           width: colRoic)
                numericHeaderCell("Özs.\nKarlılık",    col: .ozserKarlilik, width: colOzser)
                numericHeaderCell("Fiyat /\nKazanç",   col: .fiyatKazanc,   width: colFiyatKazanc)
                Spacer(minLength: 16)
            }
            .offset(x: -hOffset)
            .frame(width: numericVisibleWidth, alignment: .leading)
            .clipped()
        }
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
        .overlay(alignment: .bottom) { Divider() }
    }

    private var sectorHeaderCell: some View {
        Button {
            if sortCol == .sektor { ascending.toggle() }
            else { sortCol = .sektor; ascending = true }
        } label: {
            HStack(spacing: 3) {
                Text("Sektör")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.primary)
                sortIndicator(active: sortCol == .sektor)
            }
            .frame(width: sektorWidth - 12, alignment: .leading)
            .padding(.leading, 12)
        }
        .buttonStyle(.plain)
        .frame(width: sektorWidth)
    }

    private func numericHeaderCell(_ title: String, col: SortCol, width: CGFloat) -> some View {
        Button {
            if sortCol == col { ascending.toggle() }
            else { sortCol = col; ascending = true }
        } label: {
            HStack(alignment: .center, spacing: 3) {
                sortIndicator(active: sortCol == col)
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(.primary)
            }
            .frame(width: width, alignment: .trailing)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Table Row

    private func tableRow(_ row: SectorRow, idx: Int) -> some View {
        HStack(spacing: 0) {
            // Fixed sector column
            Text(row.sektor)
                .font(.system(size: 13))
                .foregroundColor(.primary)
                .frame(width: sektorWidth - 12, alignment: .leading)
                .padding(.leading, 12)
                .frame(width: sektorWidth)

            // Scrollable numeric columns
            HStack(spacing: 0) {
                Text(fmtPercent(row.aktifKarlilik))
                    .font(.system(size: 13))
                    .foregroundColor(row.aktifKarlilik == 0 ? .secondary : Color.midGreen)
                    .frame(width: colAktif, alignment: .trailing)

                Text(fmtDecimal(row.pdDd))
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
                    .frame(width: colPdDd, alignment: .trailing)

                Text(fmtDecimal(row.fdFavok))
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
                    .frame(width: colFd, alignment: .trailing)

                Text(fmtPercent(row.roic))
                    .font(.system(size: 13))
                    .foregroundColor(row.roic == 0 ? .secondary : Color.midGreen)
                    .frame(width: colRoic, alignment: .trailing)

                Text(fmtPercent(row.ozserKarlilik))
                    .font(.system(size: 13))
                    .foregroundColor(row.ozserKarlilik == 0 ? .secondary : Color.midGreen)
                    .frame(width: colOzser, alignment: .trailing)

                Text(fmtDecimal(row.fiyatKazanc))
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
                    .frame(width: colFiyatKazanc, alignment: .trailing)

                Spacer(minLength: 16)
            }
            .offset(x: -hOffset)
            .frame(width: numericVisibleWidth, alignment: .leading)
            .clipped()
        }
        .padding(.vertical, 12)
        .background(idx % 2 == 1 ? Color(.systemGray6).opacity(0.5) : Color(.systemBackground))
    }

    // MARK: - Sektörel Analiz Tab

    private var sektorelAnalizTab: some View {
        VStack(spacing: 0) {
            saSubTabBar
            switch saSubTab {
            case .finansallar:               finansallarContent
            case .oranlar, .getiriRisk, .teknikAnaliz: saPlaceholder
            }
        }
    }

    private var saSubTabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(SASubTab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { saSubTab = tab }
                    } label: {
                        VStack(spacing: 0) {
                            Text(tab.rawValue)
                                .font(.system(size: 14, weight: saSubTab == tab ? .semibold : .regular))
                                .foregroundColor(saSubTab == tab ? .primary : .secondary)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 18)
                            Rectangle()
                                .fill(saSubTab == tab ? Color.midGreen : Color.clear)
                                .frame(height: 2)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .background(Color(.systemBackground))
        .overlay(alignment: .bottom) { Divider() }
    }

    private var filteredBilanco: [(index: Int, group: FinancialSectorGroup)] {
        SAGroupData.bilanco.enumerated()
            .filter { sectorSearchText.isEmpty || $0.element.name.localizedCaseInsensitiveContains(sectorSearchText) }
            .map { (index: $0.offset, group: $0.element) }
    }

    private var finansallarContent: some View {
        VStack(spacing: 0) {
            finSubTabBar

            ZStack(alignment: .top) {
                // Scrollable table
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        Color.clear.frame(height: 54)
                        Divider()
                        stockTableHeader
                        let stocks = sortedStocks(SAGroupData.bilanco[selectedGroupIndex].stocks)
                        ForEach(Array(stocks.enumerated()), id: \.element.id) { idx, stock in
                            Divider()
                            stockTableRow(stock, idx: idx)
                        }
                    }
                }
                .simultaneousGesture(
                    DragGesture(minimumDistance: 5)
                        .onChanged { value in
                            guard abs(value.translation.width) > abs(value.translation.height) else { return }
                            let proposed = sHOffsetAtStart - value.translation.width
                            sHOffset = max(0, min(proposed, sMaxHOffset))
                        }
                        .onEnded { _ in sHOffsetAtStart = sHOffset }
                )
                .background(Color(.systemBackground))

                // Tap backdrop — dismisses picker when tapping outside dropdown
                if showingSectorPicker {
                    Color.black.opacity(0.001)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                                showingSectorPicker = false
                                sectorSearchText = ""
                            }
                        }
                }

                // Sector selector (always fixed at top)
                sectorSelectorCard

                // Dropdown (separate layer, positioned directly below selector)
                if showingSectorPicker {
                    sectorDropdown
                        .padding(.top, 54)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        .transition(.opacity.combined(with: .scale(scale: 0.97, anchor: .top)))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
        }
    }

    private var sectorSelectorCard: some View {
        Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                showingSectorPicker.toggle()
                if !showingSectorPicker { sectorSearchText = "" }
            }
        } label: {
            HStack {
                Text(SAGroupData.bilanco[selectedGroupIndex].name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: showingSectorPicker ? "chevron.up" : "chevron.down")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.midGreen)
            }
            .padding(.horizontal, 16)
            .frame(height: 54)
        }
        .buttonStyle(.plain)
        .background(Color(.systemBackground))
        .overlay(alignment: .bottom) { Divider() }
    }

    private var sectorDropdown: some View {
        VStack(spacing: 0) {
            TextField("Ara...", text: $sectorSearchText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 14)
                .padding(.top, 12)
                .padding(.bottom, 6)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(filteredBilanco, id: \.group.id) { item in
                        Button {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                selectedGroupIndex = item.index
                                showingSectorPicker = false
                                sectorSearchText = ""
                                sHOffset = 0
                                sHOffsetAtStart = 0
                                stockSortCol = .donenVarliklar
                                stockSortAscending = true
                            }
                        } label: {
                            Text(item.group.name)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(selectedGroupIndex == item.index ? Color.midGreen : .primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(.plain)
                        Divider().padding(.leading, 16)
                    }
                }
            }
            .frame(maxHeight: 320)
        }
        .background(Color(.systemBackground))
        .overlay(alignment: .bottom) { Divider() }
    }

    private var finSubTabBar: some View {
        HStack(spacing: 0) {
            ForEach(FinSubTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) { finSubTab = tab }
                } label: {
                    Text(tab.rawValue)
                        .font(.system(size: 13, weight: finSubTab == tab ? .semibold : .regular))
                        .foregroundColor(finSubTab == tab ? Color.midGreen : .secondary)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .overlay(alignment: .bottom) { Divider() }
    }

    private var stockTableHeader: some View {
        HStack(spacing: 0) {
            Text("Hisse")
                .font(.system(size: 13, weight: .bold))
                .frame(width: hisseWidth - 12, alignment: .leading)
                .padding(.leading, 12)
                .frame(width: hisseWidth)
            HStack(spacing: 0) {
                stockHeaderCell("Dönen\nVarlıklar",   col: .donenVarliklar,  width: stockColW)
                stockHeaderCell("Duran\nVarlıklar",   col: .duranVarliklar,  width: stockColW)
                stockHeaderCell("Toplam\nVarlıklar",  col: .toplamVarliklar, width: stockColW)
                stockHeaderCell("Kısa Vad.\nYük.",    col: .kisaVadeliYuk,   width: stockColW)
                stockHeaderCell("Uzun Vad.\nYük.",    col: .uzunVadeliYuk,   width: stockColW)
                stockHeaderCell("Özkaynaklar",        col: .ozkaynaklar,     width: stockColW)
                Spacer(minLength: 12)
            }
            .offset(x: -sHOffset)
            .frame(width: sNumericVisible, alignment: .leading)
            .clipped()
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }

    private func stockHeaderCell(_ title: String, col: StockSortCol, width: CGFloat) -> some View {
        Button {
            if stockSortCol == col { stockSortAscending.toggle() }
            else { stockSortCol = col; stockSortAscending = true }
        } label: {
            HStack(alignment: .center, spacing: 3) {
                stockSortIcon(active: stockSortCol == col)
                Text(title)
                    .font(.system(size: 11, weight: .bold))
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(.primary)
            }
            .frame(width: width, alignment: .trailing)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func stockSortIcon(active: Bool) -> some View {
        if active {
            Image(systemName: stockSortAscending ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                .font(.system(size: 8))
                .foregroundColor(Color.midGreen)
        } else {
            VStack(spacing: 1) {
                Image(systemName: "arrowtriangle.up.fill")
                    .font(.system(size: 5))
                    .foregroundColor(Color.secondary.opacity(0.35))
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.system(size: 5))
                    .foregroundColor(Color.secondary.opacity(0.35))
            }
        }
    }

    private func stockTableRow(_ stock: FinancialStock, idx: Int) -> some View {
        HStack(spacing: 0) {
            Text(stock.code)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.primary)
                .frame(width: hisseWidth - 12, alignment: .leading)
                .padding(.leading, 12)
                .frame(width: hisseWidth)
            HStack(spacing: 0) {
                Text(fmtMoney(stock.donenVarliklar))
                    .frame(width: stockColW, alignment: .trailing)
                Text(fmtMoney(stock.duranVarliklar))
                    .frame(width: stockColW, alignment: .trailing)
                Text(fmtMoney(stock.toplamVarliklar))
                    .frame(width: stockColW, alignment: .trailing)
                Text(fmtMoney(stock.kisaVadeliYuk))
                    .frame(width: stockColW, alignment: .trailing)
                Text(fmtMoney(stock.uzunVadeliYuk))
                    .frame(width: stockColW, alignment: .trailing)
                Text(fmtMoney(stock.ozkaynaklar))
                    .frame(width: stockColW, alignment: .trailing)
                Spacer(minLength: 12)
            }
            .font(.system(size: 13))
            .foregroundColor(.primary)
            .offset(x: -sHOffset)
            .frame(width: sNumericVisible, alignment: .leading)
            .clipped()
        }
        .padding(.vertical, 11)
        .background(idx % 2 == 1 ? Color(.systemGray6).opacity(0.4) : Color(.systemBackground))
    }

    private func sortedStocks(_ stocks: [FinancialStock]) -> [FinancialStock] {
        stocks.sorted {
            let l: Double, r: Double
            switch stockSortCol {
            case .donenVarliklar:  l = $0.donenVarliklar;  r = $1.donenVarliklar
            case .duranVarliklar:  l = $0.duranVarliklar;  r = $1.duranVarliklar
            case .toplamVarliklar: l = $0.toplamVarliklar; r = $1.toplamVarliklar
            case .kisaVadeliYuk:   l = $0.kisaVadeliYuk;   r = $1.kisaVadeliYuk
            case .uzunVadeliYuk:   l = $0.uzunVadeliYuk;   r = $1.uzunVadeliYuk
            case .ozkaynaklar:     l = $0.ozkaynaklar;     r = $1.ozkaynaklar
            }
            return stockSortAscending ? l < r : l > r
        }
    }

    private var saPlaceholder: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 60)
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("Bu içerik yakında eklenecek.")
                .foregroundColor(.secondary)
                .font(.subheadline)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }

    // MARK: - Sort Indicator
    @ViewBuilder
    private func sortIndicator(active: Bool) -> some View {
        if active {
            Image(systemName: ascending ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                .font(.system(size: 11))
                .foregroundColor(Color.midGreen)
        } else {
            VStack(spacing: 1) {
                Image(systemName: "arrowtriangle.up.fill")
                    .font(.system(size: 8))
                    .foregroundColor(Color.secondary.opacity(0.35))
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.system(size: 8))
                    .foregroundColor(Color.secondary.opacity(0.35))
            }
        }
    }

    // MARK: - Formatters
    private func fmtPercent(_ v: Double) -> String {
        if v == 0 { return "%0" }
        return "%" + String(format: "%.3g", v).replacingOccurrences(of: ".", with: ",")
    }

    private func fmtDecimal(_ v: Double) -> String {
        if v == 0 { return "0,00" }
        return String(format: "%.2f", v).replacingOccurrences(of: ".", with: ",")
    }

    private func fmtMoney(_ v: Double) -> String {
        if v >= 1_000_000_000 {
            let b = v / 1_000_000_000
            return String(format: "%.2f", b).replacingOccurrences(of: ".", with: ",") + "Mr ₺"
        } else {
            let m = v / 1_000_000
            return String(format: "%.2f", m).replacingOccurrences(of: ".", with: ",") + "Mn ₺"
        }
    }
}

// MARK: - Mock Data

private enum SAMockData {
    static let rows: [SectorRow] = [
        //                                                                                              ROIC     Özs.Krl.   F/K
        SectorRow(sektor: "Kırtasiye",                   aktifKarlilik: 0,    pdDd: 0.00,  fdFavok: 0.00,   roic: 0,     ozserKarlilik: 0,     fiyatKazanc: 0.00),
        SectorRow(sektor: "Dayanıklı Tüketim",           aktifKarlilik: 0,    pdDd: 1.32,  fdFavok: 12.03,  roic: 0,     ozserKarlilik: 0,     fiyatKazanc: 18.40),
        SectorRow(sektor: "Medya",                       aktifKarlilik: 0,    pdDd: 1.43,  fdFavok: 0.00,   roic: 0,     ozserKarlilik: 0,     fiyatKazanc: 0.00),
        SectorRow(sektor: "Menkul Kıymet Yat. Ort.",     aktifKarlilik: 0,    pdDd: 1.83,  fdFavok: 3.30,   roic: 0,     ozserKarlilik: 0,     fiyatKazanc: 14.25),
        SectorRow(sektor: "Finansman Şirketleri",        aktifKarlilik: 0,    pdDd: 0.00,  fdFavok: 15.84,  roic: 0,     ozserKarlilik: 0,     fiyatKazanc: 0.00),
        SectorRow(sektor: "Girişim Sermayesi Yat. Ort.", aktifKarlilik: 0.28, pdDd: 0.82,  fdFavok: 7.05,   roic: 3.40,  ozserKarlilik: 4.20,  fiyatKazanc: 11.80),
        SectorRow(sektor: "Metal Ana Sanayi",            aktifKarlilik: 0.36, pdDd: 1.16,  fdFavok: 12.14,  roic: 4.50,  ozserKarlilik: 6.10,  fiyatKazanc: 8.45),
        SectorRow(sektor: "Çimento, Beton",              aktifKarlilik: 0.39, pdDd: 1.96,  fdFavok: 12.96,  roic: 5.20,  ozserKarlilik: 7.80,  fiyatKazanc: 10.20),
        SectorRow(sektor: "Cam",                         aktifKarlilik: 0.40, pdDd: 0.57,  fdFavok: 13.68,  roic: 4.80,  ozserKarlilik: 5.60,  fiyatKazanc: 7.35),
        SectorRow(sektor: "Toptan Ticaret",              aktifKarlilik: 0.42, pdDd: 1.38,  fdFavok: 24.50,  roic: 5.60,  ozserKarlilik: 8.40,  fiyatKazanc: 12.70),
        SectorRow(sektor: "Diğer İmalat",                aktifKarlilik: 0.45, pdDd: 0.90,  fdFavok: 6.48,   roic: 5.90,  ozserKarlilik: 7.20,  fiyatKazanc: 9.85),
        SectorRow(sektor: "Yatırım Şirketleri",          aktifKarlilik: 0.49, pdDd: 1.55,  fdFavok: 1.02,   roic: 6.10,  ozserKarlilik: 8.90,  fiyatKazanc: 15.60),
        SectorRow(sektor: "Ulaştırma",                   aktifKarlilik: 0.53, pdDd: 0.68,  fdFavok: 6.12,   roic: 6.80,  ozserKarlilik: 9.40,  fiyatKazanc: 8.90),
        SectorRow(sektor: "Banka",                       aktifKarlilik: 0.62, pdDd: 1.14,  fdFavok: 5.70,   roic: 8.20,  ozserKarlilik: 16.50, fiyatKazanc: 6.85),
        SectorRow(sektor: "Giyim Eşyası",                aktifKarlilik: 0.63, pdDd: 2.25,  fdFavok: 4.49,   roic: 8.40,  ozserKarlilik: 11.20, fiyatKazanc: 14.30),
        SectorRow(sektor: "Petrol",                      aktifKarlilik: 0.64, pdDd: 1.32,  fdFavok: 6.77,   roic: 8.80,  ozserKarlilik: 12.60, fiyatKazanc: 9.40),
        SectorRow(sektor: "Tekstil Ürünleri",            aktifKarlilik: 0.65, pdDd: 0.74,  fdFavok: 10.87,  roic: 7.90,  ozserKarlilik: 10.80, fiyatKazanc: 11.25),
        SectorRow(sektor: "Tekstil",                     aktifKarlilik: 0.67, pdDd: 1.28,  fdFavok: 8.45,   roic: 8.20,  ozserKarlilik: 11.40, fiyatKazanc: 10.60),
        SectorRow(sektor: "Perakende",                   aktifKarlilik: 0.72, pdDd: 3.14,  fdFavok: 18.30,  roic: 9.40,  ozserKarlilik: 18.20, fiyatKazanc: 22.40),
        SectorRow(sektor: "Teknoloji",                   aktifKarlilik: 0.84, pdDd: 4.22,  fdFavok: 22.60,  roic: 12.50, ozserKarlilik: 22.40, fiyatKazanc: 28.60),
        SectorRow(sektor: "İlaç",                        aktifKarlilik: 0.91, pdDd: 2.87,  fdFavok: 16.40,  roic: 14.20, ozserKarlilik: 19.80, fiyatKazanc: 20.15),
        SectorRow(sektor: "Elektrik",                    aktifKarlilik: 0.95, pdDd: 1.68,  fdFavok: 9.22,   roic: 11.40, ozserKarlilik: 14.60, fiyatKazanc: 12.85),
        SectorRow(sektor: "Gıda",                        aktifKarlilik: 1.02, pdDd: 1.90,  fdFavok: 11.85,  roic: 13.20, ozserKarlilik: 17.40, fiyatKazanc: 16.70),
        SectorRow(sektor: "Sigortacılık",                aktifKarlilik: 1.15, pdDd: 2.10,  fdFavok: 0.00,   roic: 0,     ozserKarlilik: 15.60, fiyatKazanc: 10.40),
        SectorRow(sektor: "Holding ve Yatırım",          aktifKarlilik: 1.23, pdDd: 1.47,  fdFavok: 14.22,  roic: 10.80, ozserKarlilik: 16.20, fiyatKazanc: 13.50),
        SectorRow(sektor: "Kimya",                       aktifKarlilik: 1.38, pdDd: 2.63,  fdFavok: 8.90,   roic: 16.40, ozserKarlilik: 21.30, fiyatKazanc: 17.80),
        SectorRow(sektor: "İnşaat",                      aktifKarlilik: 1.45, pdDd: 1.10,  fdFavok: 17.30,  roic: 14.60, ozserKarlilik: 18.40, fiyatKazanc: 11.25),
    ]
}

// MARK: - Financial Sector Group Mock Data

private enum SAGroupData {
    static let bilanco: [FinancialSectorGroup] = [
        FinancialSectorGroup(name: "Bina Malzemeleri", stocks: [
            FinancialStock(code: "DNISI",  donenVarliklar:  425_310_000,  duranVarliklar:  1_390_000_000, toplamVarliklar:  1_815_310_000, kisaVadeliYuk:   890_000_000, uzunVadeliYuk:  280_000_000, ozkaynaklar:   645_310_000),
            FinancialStock(code: "EPLAS",  donenVarliklar:  566_880_000,  duranVarliklar:  4_840_000_000, toplamVarliklar:  5_406_880_000, kisaVadeliYuk: 2_100_000_000, uzunVadeliYuk:  820_000_000, ozkaynaklar: 2_486_880_000),
            FinancialStock(code: "MARBL",  donenVarliklar: 2_240_000_000, duranVarliklar:  2_250_000_000, toplamVarliklar:  4_490_000_000, kisaVadeliYuk: 1_500_000_000, uzunVadeliYuk:  640_000_000, ozkaynaklar: 2_350_000_000),
            FinancialStock(code: "EGSER",  donenVarliklar: 4_010_000_000, duranVarliklar:  3_580_000_000, toplamVarliklar:  7_590_000_000, kisaVadeliYuk: 2_800_000_000, uzunVadeliYuk: 1_200_000_000, ozkaynaklar: 3_590_000_000),
            FinancialStock(code: "INTEM",  donenVarliklar: 4_040_000_000, duranVarliklar:    241_240_000, toplamVarliklar:  4_281_240_000, kisaVadeliYuk: 1_900_000_000, uzunVadeliYuk:  450_000_000, ozkaynaklar: 1_931_240_000),
            FinancialStock(code: "OZYSR",  donenVarliklar: 4_610_000_000, duranVarliklar:  4_180_000_000, toplamVarliklar:  8_790_000_000, kisaVadeliYuk: 3_200_000_000, uzunVadeliYuk:  900_000_000, ozkaynaklar: 4_690_000_000),
            FinancialStock(code: "EUREN",  donenVarliklar: 5_120_000_000, duranVarliklar: 10_970_000_000, toplamVarliklar: 16_090_000_000, kisaVadeliYuk: 5_400_000_000, uzunVadeliYuk: 2_200_000_000, ozkaynaklar: 8_490_000_000),
            FinancialStock(code: "KLKIM",  donenVarliklar: 5_820_000_000, duranVarliklar:  4_460_000_000, toplamVarliklar: 10_280_000_000, kisaVadeliYuk: 3_800_000_000, uzunVadeliYuk: 1_400_000_000, ozkaynaklar: 5_080_000_000),
            FinancialStock(code: "SERNT",  donenVarliklar: 5_840_000_000, duranVarliklar:  7_700_000_000, toplamVarliklar: 13_540_000_000, kisaVadeliYuk: 4_600_000_000, uzunVadeliYuk: 1_800_000_000, ozkaynaklar: 7_140_000_000),
            FinancialStock(code: "USAK",   donenVarliklar: 6_090_000_000, duranVarliklar:  6_460_000_000, toplamVarliklar: 12_550_000_000, kisaVadeliYuk: 4_200_000_000, uzunVadeliYuk: 1_600_000_000, ozkaynaklar: 6_750_000_000),
            FinancialStock(code: "KLSER",  donenVarliklar: 9_270_000_000, duranVarliklar: 11_240_000_000, toplamVarliklar: 20_510_000_000, kisaVadeliYuk: 7_200_000_000, uzunVadeliYuk: 2_800_000_000, ozkaynaklar: 10_510_000_000),
            FinancialStock(code: "EGPRO",  donenVarliklar: 9_870_000_000, duranVarliklar:  8_780_000_000, toplamVarliklar: 18_650_000_000, kisaVadeliYuk: 6_800_000_000, uzunVadeliYuk: 2_400_000_000, ozkaynaklar: 9_450_000_000),
            FinancialStock(code: "QUAGR",  donenVarliklar: 10_480_000_000, duranVarliklar: 10_670_000_000, toplamVarliklar: 21_150_000_000, kisaVadeliYuk: 7_600_000_000, uzunVadeliYuk: 3_000_000_000, ozkaynaklar: 10_550_000_000),
            FinancialStock(code: "BIENY",  donenVarliklar: 13_460_000_000, duranVarliklar: 14_020_000_000, toplamVarliklar: 27_480_000_000, kisaVadeliYuk: 9_800_000_000, uzunVadeliYuk: 3_600_000_000, ozkaynaklar: 14_080_000_000),
        ]),
        FinancialSectorGroup(name: "Kimya, Petrol", stocks: [
            FinancialStock(code: "AYGAZ",  donenVarliklar:  8_240_000_000, duranVarliklar:  5_670_000_000, toplamVarliklar: 13_910_000_000, kisaVadeliYuk:  3_400_000_000, uzunVadeliYuk: 1_100_000_000, ozkaynaklar:  9_410_000_000),
            FinancialStock(code: "TUPRS",  donenVarliklar: 48_200_000_000, duranVarliklar: 31_800_000_000, toplamVarliklar: 80_000_000_000, kisaVadeliYuk: 28_000_000_000, uzunVadeliYuk: 12_000_000_000, ozkaynaklar: 40_000_000_000),
            FinancialStock(code: "PETKM",  donenVarliklar: 12_500_000_000, duranVarliklar: 18_300_000_000, toplamVarliklar: 30_800_000_000, kisaVadeliYuk:  9_200_000_000, uzunVadeliYuk:  5_800_000_000, ozkaynaklar: 15_800_000_000),
            FinancialStock(code: "GUBRF",  donenVarliklar:  6_100_000_000, duranVarliklar:  4_200_000_000, toplamVarliklar: 10_300_000_000, kisaVadeliYuk:  3_100_000_000, uzunVadeliYuk:  1_800_000_000, ozkaynaklar:  5_400_000_000),
        ]),
        FinancialSectorGroup(name: "Metal Ana Sanayi", stocks: [
            FinancialStock(code: "EREGL",   donenVarliklar: 42_000_000_000, duranVarliklar: 38_000_000_000, toplamVarliklar: 80_000_000_000, kisaVadeliYuk: 18_000_000_000, uzunVadeliYuk:  8_000_000_000, ozkaynaklar: 54_000_000_000),
            FinancialStock(code: "KRDMD",   donenVarliklar: 15_300_000_000, duranVarliklar: 12_200_000_000, toplamVarliklar: 27_500_000_000, kisaVadeliYuk:  7_400_000_000, uzunVadeliYuk:  3_200_000_000, ozkaynaklar: 16_900_000_000),
            FinancialStock(code: "ISDMR",   donenVarliklar: 32_100_000_000, duranVarliklar: 28_400_000_000, toplamVarliklar: 60_500_000_000, kisaVadeliYuk: 14_200_000_000, uzunVadeliYuk:  7_800_000_000, ozkaynaklar: 38_500_000_000),
            FinancialStock(code: "CEMAS",   donenVarliklar:  4_800_000_000, duranVarliklar:  6_200_000_000, toplamVarliklar: 11_000_000_000, kisaVadeliYuk:  3_600_000_000, uzunVadeliYuk:  2_100_000_000, ozkaynaklar:  5_300_000_000),
        ]),
        FinancialSectorGroup(name: "Çimento, Beton, Cam", stocks: [
            FinancialStock(code: "AKCNS",  donenVarliklar:  9_800_000_000, duranVarliklar: 12_400_000_000, toplamVarliklar: 22_200_000_000, kisaVadeliYuk:  4_200_000_000, uzunVadeliYuk:  2_600_000_000, ozkaynaklar: 15_400_000_000),
            FinancialStock(code: "CIMSA",  donenVarliklar:  7_600_000_000, duranVarliklar: 10_200_000_000, toplamVarliklar: 17_800_000_000, kisaVadeliYuk:  3_400_000_000, uzunVadeliYuk:  2_100_000_000, ozkaynaklar: 12_300_000_000),
            FinancialStock(code: "TRKCM",  donenVarliklar: 12_300_000_000, duranVarliklar: 18_700_000_000, toplamVarliklar: 31_000_000_000, kisaVadeliYuk:  5_800_000_000, uzunVadeliYuk:  4_200_000_000, ozkaynaklar: 21_000_000_000),
            FinancialStock(code: "SISE",   donenVarliklar: 28_500_000_000, duranVarliklar: 42_100_000_000, toplamVarliklar: 70_600_000_000, kisaVadeliYuk: 12_400_000_000, uzunVadeliYuk:  8_600_000_000, ozkaynaklar: 49_600_000_000),
        ]),
    ]
}

#Preview {
    SectoralAnalysisView()
}
