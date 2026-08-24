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

struct IndicatorValue {
    let value: Double
    let isPercentage: Bool?
}

struct DynamicFinancialStock: Identifiable {
    let id = UUID()
    let code: String
    var values: [String: IndicatorValue]
}

// MARK: - SectoralAnalysisView

struct SectoralAnalysisView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SectoralAnalysisViewModel()
    @State private var selectedTab: SATab = .genelBakis
    @State private var sortCol: SortCol = .aktifKarlilik
    @State private var ascending = true
    @State private var hOffset: CGFloat = 0
    @State private var hOffsetAtDragStart: CGFloat = 0
    // Sektörel Analiz tab state
    @State private var saSubTab: SASubTab = .finansallar
    @State private var finSubTab: FinSubTab = .bilanco
    @State private var selectedSector: SectorListItem?
    @State private var showingSectorPicker: Bool = false
    @State private var sectorSearchText: String = ""
    @State private var sHOffset: CGFloat = 0
    @State private var sHOffsetAtStart: CGFloat = 0
    @State private var dynamicSortCol: String? = nil
    @State private var stockSortAscending: Bool = true
    
    @State private var oranlarSubTab: OranlarSubTab = .likidite
    @State private var getiriRiskSubTab: GetiriRiskSubTab = .getiri
    @State private var teknikSubTab: TeknikSubTab = .indikatorler

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
        case degerleme    = "Değerleme"
    }

    enum FinSubTab: String, CaseIterable {
        case bilanco      = "Bilanço"
        case gelirTablosu = "Gelir Tablosu"
        case nakitAkim    = "Nakit Akım"
    }
    
    enum OranlarSubTab: String, CaseIterable {
        case likidite = "Likidite"
        case karlilik = "Karlılık"
        case maliyet = "Maliyet"
        case piyasa = "Piyasa Çarpanları"
        case buyume = "Büyüme"
        case finansalYapi = "Finansal Yapı"
        case faaliyet = "Faaliyet Etkinliği"
    }

    enum GetiriRiskSubTab: String, CaseIterable {
        case getiri = "Getiri"
        case risk = "Risk"
    }

    enum TeknikSubTab: String, CaseIterable {
        case indikatorler = "İndikatörler"
        case destekDirenc = "Destek-Direnç Seviyeleri"
        case betaZSkor = "Beta ve Z-Skor"
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
        let colsCount = CGFloat(dynamicHeaders.count)
        return max(0, colsCount * stockColW + 12 - sNumericVisible)
    }
    
    private var dynamicHeaders: [String] {
        return fetchedDynamicData.headers
    }
    
    private var dynamicStocks: [DynamicFinancialStock] {
        return fetchedDynamicData.stocks
    }
    
    private var fetchedDynamicData: (headers: [String], stocks: [DynamicFinancialStock]) {
        guard let detail = viewModel.sectorDetail else { return ([], []) }
        
        var tabData: [String: [SectorIndicator]]? = nil
        
        switch saSubTab {
        case .finansallar:
            tabData = detail.financials?[finSubTab.rawValue]
        case .oranlar:
            tabData = detail.ratios?[oranlarSubTab.rawValue]
        case .getiriRisk:
            if getiriRiskSubTab == .getiri {
                tabData = detail.return
            } else {
                tabData = detail.risk
            }
        case .teknikAnaliz:
            tabData = detail.technicalAnalysis?[teknikSubTab.rawValue]
        case .degerleme:
            tabData = detail.valuation
        }
        
        guard let data = tabData else { return ([], []) }
        
        let headers = Array(data.keys).sorted()
        var stocksDict: [String: DynamicFinancialStock] = [:]
        
        for code in detail.stockCodes {
            stocksDict[code] = DynamicFinancialStock(code: code, values: [:])
        }
        
        for (indicatorName, indicators) in data {
            for ind in indicators {
                stocksDict[ind.name]?.values[indicatorName] = IndicatorValue(value: ind.value ?? 0, isPercentage: ind.isPercentage)
            }
        }
        
        let stocks = stocksDict.values.sorted { $0.code < $1.code }
        return (headers, stocks)
    }

    private var sortedRows: [SectorRow] {
        viewModel.sectors.sorted {
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
            tabBar

            if selectedTab == .genelBakis {
                genelBakisTab
            } else {
                sektorelAnalizTab
            }
        }
        .navigationTitle("Sektörel Analiz")
        .navigationBarTitleDisplayMode(.inline)
        .transparentNavigationBar()
        .background(Color(.systemBackground).ignoresSafeArea())
        .onAppear {
            viewModel.loadSectors()
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground).opacity(0.3))
            }
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

    private var filteredSectors: [SectorListItem] {
        viewModel.sectorList.filter { sectorSearchText.isEmpty || $0.ad.localizedCaseInsensitiveContains(sectorSearchText) }
    }

    private var sektorelAnalizTab: some View {
        VStack(spacing: 0) {
            saSubTabBar
            
            ZStack(alignment: .top) {
                // Main content
                VStack(spacing: 0) {
                    // Space for dropdown selector
                    Color.clear.frame(height: 54)
                    
                    switch saSubTab {
                    case .finansallar:
                        VStack(spacing: 0) {
                            genericSubTabBar(selectedTab: $finSubTab)
                            dynamicTableView
                        }
                    case .oranlar:
                        VStack(spacing: 0) {
                            genericSubTabBar(selectedTab: $oranlarSubTab)
                            dynamicTableView
                        }
                    case .getiriRisk:
                        VStack(spacing: 0) {
                            genericSubTabBar(selectedTab: $getiriRiskSubTab)
                            dynamicTableView
                        }
                    case .teknikAnaliz:
                        VStack(spacing: 0) {
                            genericSubTabBar(selectedTab: $teknikSubTab)
                            dynamicTableView
                        }
                    case .degerleme:
                        dynamicTableView
                    }
                }
                
                // Tap backdrop
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
                
                // Dropdown
                if showingSectorPicker {
                    sectorDropdown
                        .padding(.top, 54)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        .transition(.opacity.combined(with: .scale(scale: 0.97, anchor: .top)))
                }
            }
        }
        .onAppear {
            if selectedSector == nil, let first = viewModel.sectorList.first {
                selectedSector = first
            }
        }
        .onChange(of: viewModel.sectorList) { newList in
            if selectedSector == nil {
                selectedSector = newList.first
            }
        }
        .onChange(of: selectedSector) { newSector in
            if let sector = newSector {
                viewModel.loadSectorDetail(sectorName: sector.ad)
            }
        }
    }

    private var saSubTabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 28) {
                ForEach(SASubTab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { saSubTab = tab }
                    } label: {
                        VStack(spacing: 0) {
                            Text(tab.rawValue)
                                .font(.system(size: 16, weight: saSubTab == tab ? .bold : .medium))
                                .foregroundColor(saSubTab == tab ? .primary : .secondary)
                                .padding(.vertical, 16)
                            
                            Rectangle()
                                .fill(saSubTab == tab ? Color.midGreen : Color.clear)
                                .frame(height: 3)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
        .background(Color(.systemBackground))
        .overlay(alignment: .bottom) { Divider() }
    }

    private func genericSubTabBar<T: RawRepresentable & Hashable & CaseIterable>(
        selectedTab: Binding<T>
    ) -> some View where T.RawValue == String {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 28) {
                ForEach(Array(T.allCases), id: \.self) { tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) { selectedTab.wrappedValue = tab }
                    } label: {
                        Text(tab.rawValue)
                            .font(.system(size: 15, weight: selectedTab.wrappedValue == tab ? .bold : .medium))
                            .foregroundColor(selectedTab.wrappedValue == tab ? Color.midGreen : .secondary)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
        .background(Color(.systemBackground))
        .overlay(alignment: .bottom) { Divider() }
    }

    private var dynamicTableView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                Divider()
                stockTableHeader
                let stocks = sortedStocks(dynamicStocks)
                if viewModel.isDetailLoading {
                    ProgressView()
                        .padding(.top, 40)
                } else if stocks.isEmpty {
                    Text("Veri bulunamadı")
                        .foregroundColor(.secondary)
                        .padding(.top, 40)
                } else {
                    ForEach(Array(stocks.enumerated()), id: \.element.id) { idx, stock in
                        Divider()
                        stockTableRow(stock, idx: idx, headers: dynamicHeaders)
                    }
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var sectorSelectorCard: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                    showingSectorPicker.toggle()
                    if !showingSectorPicker { sectorSearchText = "" }
                }
            } label: {
                HStack {
                    Text(selectedSector?.ad ?? "Sektör Seçiniz")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: showingSectorPicker ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.midGreen)
                }
                .padding(.horizontal, 16)
                .frame(height: 54)
                .background(Color(.systemBackground))
            }
            .buttonStyle(.plain)
            
            if !showingSectorPicker {
                Divider()
            }
        }
    }

    private var sectorDropdown: some View {
        VStack(spacing: 0) {
            TextField("Ara...", text: $sectorSearchText)
                .font(.system(size: 15))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(filteredSectors, id: \.id) { sector in
                        Button {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                selectedSector = sector
                                showingSectorPicker = false
                                sectorSearchText = ""
                                sHOffset = 0
                                sHOffsetAtStart = 0
                                dynamicSortCol = nil
                                stockSortAscending = true
                            }
                        } label: {
                            Text(sector.ad)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.bottom, 8)
            }
            .frame(maxHeight: 320)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray5), lineWidth: 1)
                )
        )
        .padding(.horizontal, 12)
        .padding(.top, 12)
    }



    private var stockTableHeader: some View {
        let headers = dynamicHeaders
        return HStack(spacing: 0) {
            Text("Hisse")
                .font(.system(size: 13, weight: .bold))
                .frame(width: hisseWidth - 12, alignment: .leading)
                .padding(.leading, 12)
                .frame(width: hisseWidth)
            HStack(spacing: 0) {
                ForEach(headers, id: \.self) { header in
                    stockHeaderCell(header, width: stockColW)
                }
                Spacer(minLength: 12)
            }
            .offset(x: -sHOffset)
            .frame(width: sNumericVisible, alignment: .leading)
            .clipped()
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }

    private func stockHeaderCell(_ title: String, width: CGFloat) -> some View {
        Button {
            if dynamicSortCol == title { stockSortAscending.toggle() }
            else { dynamicSortCol = title; stockSortAscending = true }
        } label: {
            HStack(alignment: .center, spacing: 3) {
                stockSortIcon(active: dynamicSortCol == title)
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

    private func stockTableRow(_ stock: DynamicFinancialStock, idx: Int, headers: [String]) -> some View {
        HStack(spacing: 0) {
            Text(stock.code)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.primary)
                .frame(width: hisseWidth - 12, alignment: .leading)
                .padding(.leading, 12)
                .frame(width: hisseWidth)
            HStack(spacing: 0) {
                ForEach(headers, id: \.self) { header in
                    Text(formatIndicator(stock.values[header]))
                        .frame(width: stockColW, alignment: .trailing)
                }
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

    private func sortedStocks(_ stocks: [DynamicFinancialStock]) -> [DynamicFinancialStock] {
        guard let sortCol = dynamicSortCol else {
            return stocks.sorted { $0.code < $1.code }
        }
        return stocks.sorted {
            let l = $0.values[sortCol]?.value ?? 0
            let r = $1.values[sortCol]?.value ?? 0
            return stockSortAscending ? l < r : l > r
        }
    }
    
    private func formatIndicator(_ ind: IndicatorValue?) -> String {
        guard let ind = ind else { return "-" }
        if ind.isPercentage == true {
            return fmtPercent(ind.value)
        } else if saSubTab == .finansallar {
            return fmtMoney(ind.value)
        } else {
            return fmtDecimal(ind.value)
        }
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
        v.compactCurrencyString()
    }
}

// MARK: - Mock Data

// Mock Data for SectoralAnalysizView was removed since it is now populated via API


#Preview {
    SectoralAnalysisView()
}
