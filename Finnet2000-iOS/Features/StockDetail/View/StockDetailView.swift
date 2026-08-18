import SwiftUI

// MARK: - StockDetailView

struct StockDetailView: View {
    let stockCode: String
    @StateObject private var viewModel = StockDetailViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = "Özet"
    @State private var selectedSubTab = ""
    @State private var showAlarm = false
    @State private var navigateToMatriksBridge = false

    private let tabs = ["Özet", "Finansallar", "Oranlar", "Sektörel Analiz"]
    private let subTabs: [String: [String]] = [
        "Finansallar":     ["Bilanço", "Gelir Tablosu", "Nakit Akım"],
        "Oranlar":         ["Likidite", "Karlılık", "Maliyet", "Piyasa Çarpanları", "Büyüme", "Finansal Yapı", "Faaliyet Etkinliği"],
        "Sektörel Analiz": ["Finansallar", "Oranlar", "Getiri"]
    ]

    var body: some View {
        ZStack(alignment: .top) {
            Color.sdAppBackground
                .ignoresSafeArea()
            VStack(spacing: 0) {
                stockHeader
                stockTabBar
                if let subs = subTabs[selectedTab] {
                    stockSubTabBar(subs)
                }
                stockContent
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.22), value: selectedTab)
                    .animation(.easeInOut(duration: 0.22), value: selectedSubTab)
            }
            // Fixed bottom bar
            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: 0) {
                    Divider()
                    Button {
                        navigateToMatriksBridge = true
                    } label: {
                        Text("Al / Sat")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.sdGreen, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 28)
                    .background(Color.sdPrimaryBackground)
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .overlay {
            ZStack {
                // overlay removed – using .sheet instead
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showAlarm) {
            AlarmOlusturSheet(isPresented: $showAlarm)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
        .navigationDestination(isPresented: $navigateToMatriksBridge) {
            MatriksBridgeView(
                stockSymbol: viewModel.symbol,
                stockName: viewModel.company,
                stockPrice: viewModel.price,
                stockChange: viewModel.change,
                stockDate: viewModel.date,
                postAuthDestination: .orderEntry
            )
        }
        .onChange(of: selectedTab) { _, newTab in
            selectedSubTab = subTabs[newTab]?.first ?? ""
        }
        .onAppear {
            viewModel.fetch(stockCode: stockCode)
        }
    }

    // MARK: - Header

    private var stockHeader: some View {
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.primary)
                        .frame(width: 40, height: 40)
                        .background(Color.sdPrimaryBackground,
                                    in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
                Spacer()
                HStack(spacing: 2) {
                    Button { navigateToMatriksBridge = true } label: {
                        sdNavButton("doc.text")
                    }
                    .buttonStyle(.plain)
                    sdNavButton("heart")
                    Button { showAlarm = true } label: {
                        sdNavButton("bell")
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .background(Color.sdPrimaryBackground)


            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.sdBlue)
                    .frame(width: 44, height: 44)
                    .overlay {
                        Text("F")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                    }
                VStack(alignment: .leading, spacing: 3) {
                    Text(viewModel.symbol)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Color.primary)
                    Text(viewModel.company)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.secondary)
                        .lineLimit(1)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 3) {
                    Text(viewModel.price)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.primary)
                    Text(viewModel.change)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.sdGreen)
                    Text(viewModel.date)
                        .font(.system(size: 10))
                        .foregroundStyle(Color.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 16)
        }.background(Color.sdPrimaryBackground)

    }

    private func sdNavButton(_ systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(Color.primary)
            .frame(width: 40, height: 40)
            .background(Color.sdPrimaryBackground,
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - Tab Bar

    private var stockTabBar: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.22)) { selectedTab = tab }
                } label: {
                    VStack(spacing: 0) {
                        Text(tab)
                            .font(.system(size: 14, weight: selectedTab == tab ? .semibold : .regular))
                            .foregroundStyle(selectedTab == tab ? Color.primary : Color.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                        Rectangle()
                            .fill(selectedTab == tab ? Color.sdGreen : Color.clear)
                            .frame(height: 2)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .background(Color.sdPrimaryBackground)
        .overlay(alignment: .bottom) { Divider() }
    }

    // MARK: - Sub Tab Bar

    private func stockSubTabBar(_ subs: [String]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(subs, id: \.self) { sub in
                    Button {
                        withAnimation(.easeInOut(duration: 0.22)) { selectedSubTab = sub }
                    } label: {
                        VStack(spacing: 0) {
                            Text(sub)
                                .font(.system(size: 13, weight: selectedSubTab == sub ? .semibold : .regular))
                                .foregroundStyle(selectedSubTab == sub ? Color.sdGreen : Color.secondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            Rectangle()
                                .fill(selectedSubTab == sub ? Color.sdGreen : Color.clear)
                                .frame(height: 2)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
        .background(Color.sdPrimaryBackground)
        .overlay(alignment: .bottom) { Divider() }
    }

    // MARK: - Content

    @ViewBuilder
    private var stockContent: some View {
        if selectedTab == "Finansallar" {
            finansallarContent
        } else if selectedTab == "Oranlar" {
            oranlarContent
        } else if selectedTab == "Sektörel Analiz" {
            sektorelAnalizContent
        } else {
            ozetContent
        }
    }

    // MARK: - Özet Content

    private var ozetContent: some View {
        ScrollView(showsIndicators: false) {
            if viewModel.isLoading {
                ProgressView("Yükleniyor...")
                    .padding(.top, 50)
            } else {
                VStack(alignment: .leading, spacing: 22) {
                    sectionCard("Beşgen Grafik") {
                        SDRadarChart(entries: SDData.radarEntries)
                            .frame(height: 240)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 10)
                    }
                    sectionCard("Fiyat Grafiği") {
                        SDLineChart(points: viewModel.pricePoints)
                            .frame(height: 160)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 14)
                    }
                    sectionCard("Getiriler") {
                        sdMetricsTable(
                            headers: ["", "Günlük", "Haftalık", "Aylık", "Yıllık"],
                            rows: viewModel.returnsRows
                        )
                    }
                    sectionCard("Hareketli Ortalamalar") {
                        sdMetricsTable(
                            headers: ["", "20MA", "50MA", "100MA", "200MA"],
                            rows: viewModel.movingAvgRows
                        )
                    }
                    sectionCard("Momentum İndikatörleri") {
                        sdMetricsTable(
                            headers: ["", "RSI", "STOK", "MACD", "STOKORT"],
                            rows: viewModel.momentumRows
                        )
                    }
                    sectionCard("Hangi Fonlarda Var?") {
                        sdFundList()
                    }
                    sectionCard("Piyasa Çarpanları") {
                        sdPairList(viewModel.multiplesRows, headers: ("Oran", "Değer"))
                    }
                    sectionCard("Özet Bilanço") {
                        sdPairList(viewModel.balanceRows, headers: ("Kalem", "Değer"))
                    }
                    if !viewModel.incomeRows.isEmpty {
                        sectionCard("Özet Gelir Tablosu") {
                            sdPairList(viewModel.incomeRows, headers: ("Kalem", "Değer"))
                        }
                    }
                    if !viewModel.sectoralRows.isEmpty {
                        sectionCard("Özet Sektörel Analiz") {
                            sdPairList(viewModel.sectoralRows, headers: ("Hisse", viewModel.sectoralValueHeader))
                        }
                    }
                    if !viewModel.pairTradeRows.isEmpty {
                        sectionCard("Pair Trade") {
                            sdPairList(viewModel.pairTradeRows, headers: ("Hisse", "Değer"))
                        }
                    }
                    if !viewModel.partnershipRows.isEmpty {
                        sectionCard("Ortaklık Yapısı") {
                            sdMetricsTable(
                                headers: ["İsim", "Sermaye", "Oran"],
                                rows: viewModel.partnershipRows
                            )
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 16)
                .padding(.bottom, 96)
            }
        }
        .background(Color.sdAppBackground)
    }

    // MARK: - Finansallar Content

    @ViewBuilder
    private var finansallarContent: some View {
        if selectedSubTab == "Gelir Tablosu" {
            gelirTablosuView
        } else if selectedSubTab == "Nakit Akım" {
            nakitAkimView
        } else {
            bilancoView
        }
    }

    private var bilancoView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                sectionCard("Bilanço") {
                    sdFinancialTable(periods: SDData.financialPeriods, rows: SDData.bilancoRows)
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 16)
            .padding(.bottom, 96)
        }
        .background(Color.sdAppBackground)
    }

    private var gelirTablosuView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                sectionCard("Gelir Tablosu") {
                    sdFinancialTable(periods: SDData.financialPeriods, rows: SDData.gelirTablosuRows)
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 16)
            .padding(.bottom, 96)
        }
        .background(Color.sdAppBackground)
    }

    private var nakitAkimView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                sectionCard("Nakit Akım") {
                    sdFinancialTable(periods: SDData.annualPeriods, rows: SDData.nakitAkimRows)
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 16)
            .padding(.bottom, 96)
        }
        .background(Color.sdAppBackground)
    }

    // MARK: - Oranlar Content

    @ViewBuilder
    private var oranlarContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                if viewModel.isLoading {
                    ProgressView("Yükleniyor...")
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if viewModel.errorMessage != nil && viewModel.ratiosData == nil {
                    ContentUnavailableView(
                        "Yüklenemedi",
                        systemImage: "exclamationmark.triangle",
                        description: Text(viewModel.errorMessage ?? "Oranlar yüklenirken hata oluştu.")
                    )
                } else {
                    let rows = viewModel.ratioRows(for: selectedSubTab)
                    if rows.isEmpty {
                        ContentUnavailableView(
                            "Veri Bulunmuyor",
                            systemImage: "tray",
                            description: Text("Bu kategori için oran verisi bulunmuyor.")
                        )
                    } else {
                        sectionCard("\(selectedSubTab) Oranları") {
                            sdMetricsTable(
                                headers: ["Oran", viewModel.symbol, "Sektör Ort.", "Medyan"],
                                rows: rows
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 16)
            .padding(.bottom, 96)
        }
        .background(Color.sdAppBackground)
    }

    // MARK: - Sektörel Analiz Content

    @ViewBuilder
    private var sektorelAnalizContent: some View {
        if viewModel.isLoading {
            ProgressView("Yükleniyor...")
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 50)
        } else if viewModel.errorMessage != nil && viewModel.sectoralAnalysisData == nil {
            ContentUnavailableView(
                "Yüklenemedi",
                systemImage: "exclamationmark.triangle",
                description: Text(viewModel.errorMessage ?? "Sektörel analiz yüklenirken hata oluştu.")
            )
        } else {
            if selectedSubTab == "Oranlar" {
                sektorOranlarView
            } else if selectedSubTab == "Getiri" {
                sektorGetiriView
            } else {
                sektorFinansallarView
            }
        }
    }

    private var sektorFinansallarView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                if let data = viewModel.sectoralAnalysisData?.financials {
                    let bilanco = viewModel.buildSectoralTable(from: data.balanceSheet, isCurrency: true)
                    if !bilanco.rows.isEmpty {
                        sectionCard("Bilanço") {
                            sdMetricsTable(headers: bilanco.headers, rows: bilanco.rows, firstColWidth: 45)
                        }
                    }
                    
                    let gelirTablosu = viewModel.buildSectoralTable(from: data.incomeStatement, isCurrency: true)
                    if !gelirTablosu.rows.isEmpty {
                        sectionCard("Gelir Tablosu") {
                            sdMetricsTable(headers: gelirTablosu.headers, rows: gelirTablosu.rows, firstColWidth: 45)
                        }
                    }
                    
                    let nakitAkim = viewModel.buildSectoralTable(from: data.cashFlowStatement, isCurrency: true)
                    if !nakitAkim.rows.isEmpty {
                        sectionCard("Nakit Akım") {
                            sdMetricsTable(headers: nakitAkim.headers, rows: nakitAkim.rows, firstColWidth: 45)
                        }
                    }
                } else {
                    ContentUnavailableView("Veri Bulunamadı", systemImage: "tray")
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 16)
            .padding(.bottom, 96)
        }
        .background(Color.sdAppBackground)
    }

    private var sektorOranlarView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                if let ratios = viewModel.sectoralAnalysisData?.ratios {
                    let table = viewModel.buildSectoralTable(from: ratios)
                    if !table.rows.isEmpty {
                        sectionCard("Sektörel Oranlar") {
                            sdMetricsTable(headers: table.headers, rows: table.rows, firstColWidth: 45)
                        }
                    } else {
                        ContentUnavailableView("Veri Bulunamadı", systemImage: "tray")
                    }
                } else {
                    ContentUnavailableView("Veri Bulunamadı", systemImage: "tray")
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 16)
            .padding(.bottom, 96)
        }
        .background(Color.sdAppBackground)
    }

    private var sektorGetiriView: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                if let returns = viewModel.sectoralAnalysisData?.returns {
                    let table = viewModel.buildSectoralTable(from: returns)
                    if !table.rows.isEmpty {
                        sectionCard("Sektörel Getiriler") {
                            sdMetricsTable(headers: table.headers, rows: table.rows, firstColWidth: 45)
                        }
                    } else {
                        ContentUnavailableView("Veri Bulunamadı", systemImage: "tray")
                    }
                } else {
                    ContentUnavailableView("Veri Bulunamadı", systemImage: "tray")
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 16)
            .padding(.bottom, 96)
        }
        .background(Color.sdAppBackground)
    }

    // MARK: - Helpers

    @ViewBuilder
    private func sdFinancialTable(periods: [String], rows: [(String, [String])]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text("Kalem")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                        .frame(width: 148, alignment: .leading)
                    ForEach(periods, id: \.self) { period in
                        Text(period)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.secondary)
                            .frame(width: 80, alignment: .trailing)
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                Divider().padding(.horizontal, 12)
                ForEach(rows.indices, id: \.self) { ri in
                    HStack(spacing: 0) {
                        Text(rows[ri].0)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.primary)
                            .frame(width: 148, alignment: .leading)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        ForEach(rows[ri].1.indices, id: \.self) { ci in
                            Text(rows[ri].1[ci])
                                .font(.system(size: 11))
                                .foregroundStyle(rows[ri].1[ci].hasPrefix("-") ? Color.sdRed : Color.primary)
                                .frame(width: 80, alignment: .trailing)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 11)
                    if ri < rows.count - 1 { Divider().padding(.horizontal, 12) }
                }
            }
        }
    }

    private func sectionCard<C: View>(_ title: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(Color.primary)
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.secondary.opacity(0.7))
            }
            content()
                .background(Color.sdPrimaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.secondary.opacity(0.12), lineWidth: 1)
                )
        }
    }

    private func sdActionButton(_ title: String, color: Color, action: @escaping () -> Void = {}) -> some View {
        Button(action: action) {
        Text(title)
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(color, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func sdMetricsTable(headers: [String], rows: [[String]], firstColWidth: CGFloat = 100) -> some View {
        let colWidth: CGFloat = 90
        let rowHeight: CGFloat = 44
        
        HStack(spacing: 0) {
            // FIXED FIRST COLUMN
            VStack(spacing: 0) {
                // Header
                Text(headers.isEmpty ? "" : headers[0])
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .frame(width: firstColWidth, alignment: .leading)
                    .frame(height: 32, alignment: .bottom)
                    .padding(.bottom, 10)
                
                Divider()
                
                // Rows
                ForEach(rows.indices, id: \.self) { ri in
                    let val = rows[ri].isEmpty ? "" : rows[ri][0]
                    Text(val)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(sdCellColor(val, col: 0))
                        .frame(width: firstColWidth, alignment: .leading)
                        .frame(height: rowHeight)
                        .minimumScaleFactor(0.7)
                        .lineLimit(2)
                    
                    if ri < rows.count - 1 { Divider() }
                }
            }
            .padding(.leading, 12)
            
            // SCROLLABLE REST OF THE COLUMNS
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Header Row
                    HStack(spacing: 4) {
                        if headers.count > 1 {
                            ForEach(1..<headers.count, id: \.self) { ci in
                                Text(headers[ci])
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(Color.secondary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .truncationMode(.tail)
                                    .frame(width: colWidth, alignment: .center)
                                    .frame(height: 32, alignment: .bottom)
                            }
                        }
                    }
                    .padding(.bottom, 10)
                    .padding(.trailing, 12)
                    
                    Divider()
                    
                    // Value Rows
                    ForEach(rows.indices, id: \.self) { ri in
                        HStack(spacing: 4) {
                            if rows[ri].count > 1 {
                                ForEach(1..<rows[ri].count, id: \.self) { ci in
                                    let val = rows[ri][ci]
                                    Text(val)
                                        .font(.system(size: 11, weight: .regular))
                                        .foregroundStyle(sdCellColor(val, col: ci))
                                        .frame(width: colWidth, alignment: .center)
                                        .frame(height: rowHeight)
                                        .minimumScaleFactor(0.7)
                                        .lineLimit(1)
                                }
                            }
                        }
                        .padding(.trailing, 12)
                        
                        if ri < rows.count - 1 { Divider() }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func sdCellColor(_ val: String, col: Int) -> Color {
        guard col > 0 else { return Color.primary }
        if val.hasPrefix("%-") || val.hasPrefix("-") { return Color.sdRed }
        if val == "Sat" { return Color.sdRed }
        if val == "Al"  { return Color.sdGreen }
        if val.hasPrefix("%") { return Color.sdGreen }
        return Color.primary
    }

    @ViewBuilder
    private func sdFundList() -> some View {
        VStack(spacing: 0) {
            HStack {
                Text("Fon")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Spacer()
                HStack(spacing: 4) {
                    Text("Oran")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            Divider().padding(.horizontal, 12)
            ForEach(viewModel.funds.indices, id: \.self) { i in
                HStack {
                    Text(viewModel.funds[i].0)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.primary)
                    Spacer()
                    Text(viewModel.funds[i].1)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.primary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                if i < viewModel.funds.count - 1 { Divider().padding(.horizontal, 12) }
            }
        }
    }

    @ViewBuilder
    private func sdPairList(_ rows: [(String, String)], headers: (String, String)) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(headers.0)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Spacer()
                Text(headers.1)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            Divider().padding(.horizontal, 12)
            ForEach(rows.indices, id: \.self) { i in
                HStack {
                    Text(rows[i].0)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.primary)
                    Spacer()
                    Text(rows[i].1)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.primary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                if i < rows.count - 1 { Divider().padding(.horizontal, 12) }
            }
        }
    }
}

// MARK: - Color Palette

private extension Color {
    static let sdDark       = Color(red: 0.11, green: 0.11, blue: 0.12)
    static let sdGreen      = Color(red: 0.18, green: 0.72, blue: 0.40)
    static let sdRed        = Color(red: 0.85, green: 0.11, blue: 0.18)
    static let sdBlue       = Color(red: 0.11, green: 0.39, blue: 0.78)
    static let sdPink       = Color(red: 1.00, green: 0.38, blue: 0.58)
    static let sdChartGreen = Color(red: 0.30, green: 0.79, blue: 0.49)

    static let sdAppBackground = Color(uiColor: .secondarySystemGroupedBackground)
    static let sdPrimaryBackground = Color(uiColor: .systemBackground)
}

// MARK: - Mock Data

private enum SDData {
    static let symbol  = "KTLEV"
    static let company = "Karşılaşmayan Faa. Fin."
    static let price   = "119,58₺"
    static let change  = "%4,44"
    static let date    = "29/04/2025"

    static let radarEntries: [SDRadarEntry] = [
        SDRadarEntry(
            values: [0.70, 0.65, 0.55, 0.68, 0.60],
            color: Color(red: 0.38, green: 0.28, blue: 0.72),
            fillOpacity: 0.35
        ),
        SDRadarEntry(
            values: [0.87, 0.80, 0.90, 0.84, 0.75],
            color: Color(red: 0.18, green: 0.72, blue: 0.40),
            fillOpacity: 0.0
        )
    ]

    static let pricePoints: [Double] = [
        12, 15, 14, 18, 16, 20, 22, 19, 25, 28,
        26, 30, 35, 38, 36, 42, 45, 50, 55, 52,
        58, 65, 70, 75, 80, 85, 90, 95, 100, 105,
        108, 112, 115, 118
    ]

    static let returnsRows: [[String]] = [
        ["KTLEV", "%4,44",  "%6,76",  "%60,87", "%1,55"],
        ["XU100", "%-0,13", "%-0,17", "%12,70", "%55,14"]
    ]

    static let movingAvgRows: [[String]] = [
        ["Fark",  "%24,29", "%65,26", "%132,89", "%267,87"],
        ["Değer", "88,91",  "66,87",  "47,55",   "30,04"]
    ]

    static let momentumRows: [[String]] = [
        ["Durum", "Sat",   "Sat",   "Al",   "-"],
        ["Değer", "92,12", "96,50", "9,58", "90,20"]
    ]

    static let funds: [(String, String)] = [
        ("SLG",  "3,43"), ("R0İ1", "4,20"), ("KYA",  "4,24"),
        ("KİS",  "4,36"), ("KCL",  "4,38"), ("YİİK", "4,41"),
        ("PPİ",  "4,70"), ("KİİC", "5,52"), ("İLN",  "5,66"),
        ("TLZ",  "6,07")
    ]

    static let multiplesRows: [(String, String)] = [
        ("Firma Değeri / FAVÖK", "16,42"),
        ("PD / DD",              "30,15"),
        ("Fiyat Kazanç",         "26,53")
    ]

    static let balanceRows: [(String, String)] = [
        ("Özkaynaklar",   "12,40Mi ₺"),
        ("Net Borç",      "8,20Mi ₺"),
        ("Toplam Varlık", "24,60Mi ₺")
    ]

    // Financial Statements
    static let financialPeriods = ["2022/12", "2023/12", "2024/03", "2024/09", "2024/12"]
    static let annualPeriods    = ["2020/12", "2021/12", "2022/12", "2023/12", "2024/12"]

    static let bilancoRows: [(String, [String])] = [
        ("Dönen Varlıklar",   ["1,2Mi", "2,4Mi", "3,1Mi", "4,2Mi", "5,8Mi"]),
        ("Duran Varlıklar",   ["8,4Mi", "9,1Mi", "9,8Mi", "11,2Mi", "12,4Mi"]),
        ("Toplam Varlık",     ["9,6Mi", "11,5Mi", "12,9Mi", "15,4Mi", "18,2Mi"]),
        ("KV Yükümlülükler",  ["0,8Mi", "1,2Mi", "1,5Mi", "2,1Mi", "2,8Mi"]),
        ("UV Yükümlülükler",  ["1,4Mi", "2,2Mi", "2,8Mi", "3,6Mi", "3,0Mi"]),
        ("Özkaynaklar",       ["7,4Mi", "8,1Mi", "8,6Mi", "9,7Mi", "12,4Mi"])
    ]

    static let gelirTablosuRows: [(String, [String])] = [
        ("Net Satışlar",  ["3,2Mi", "6,8Mi", "1,9Mi", "5,8Mi", "8,4Mi"]),
        ("Brüt Kar",      ["1,4Mi", "3,1Mi", "0,9Mi", "2,7Mi", "3,9Mi"]),
        ("FAVÖK",         ["1,1Mi", "2,4Mi", "0,7Mi", "2,1Mi", "3,1Mi"]),
        ("Faaliyet Karı", ["0,9Mi", "2,0Mi", "0,6Mi", "1,8Mi", "2,7Mi"]),
        ("Net Kar",       ["0,7Mi", "1,6Mi", "0,5Mi", "1,4Mi", "2,1Mi"])
    ]

    static let nakitAkimRows: [(String, [String])] = [
        ("İşletme Faal.",    ["0,9Mi", "2,1Mi", "1,5Mi", "2,8Mi", "3,4Mi"]),
        ("Yatırım Faal.",    ["-0,4Mi", "-0,8Mi", "-0,6Mi", "-1,2Mi", "-1,5Mi"]),
        ("Finansman Faal.",  ["-0,2Mi", "-0,3Mi", "-0,4Mi", "-0,6Mi", "-0,8Mi"]),
        ("Dönem Sonu Nakit", ["0,4Mi", "1,2Mi", "1,8Mi", "2,6Mi", "3,4Mi"])
    ]

    // Sektörel Analiz mocks removed
}

// MARK: - Radar Chart

private struct SDRadarEntry: Identifiable {
    let id = UUID()
    let values: [Double]
    let color: Color
    let fillOpacity: Double
}

private struct SDRadarChart: View {
    let entries: [SDRadarEntry]
    private let labels     = ["Volatilite", "VRD", "Getiri", "Sharpe", "Risk Değeri"]
    private let gridLevels: [CGFloat] = [0.25, 0.5, 0.75, 1.0]

    var body: some View {
        GeometryReader { geo in
            let size   = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = size * 0.35
            ZStack {
                radarGrid(center: center, radius: radius)
                radarAxes(center: center, radius: radius)
                radarSeries(center: center, radius: radius)
                radarLabels(center: center, radius: radius)
            }
        }
    }

    @ViewBuilder private func radarGrid(center: CGPoint, radius: CGFloat) -> some View {
        ZStack {
            ForEach(gridLevels, id: \.self) { level in
                SDRadarPolygon(values: Array(repeating: level, count: 5))
                    .stroke(Color(red: 0.82, green: 0.82, blue: 0.85), lineWidth: 1)
                    .frame(width: radius * 2, height: radius * 2)
                    .position(center)
            }
        }
    }

    @ViewBuilder private func radarAxes(center: CGPoint, radius: CGFloat) -> some View {
        ZStack {
            ForEach(0..<5, id: \.self) { i in
                Path { path in
                    path.move(to: center)
                    path.addLine(to: radarPt(i, radius, center))
                }
                .stroke(Color(red: 0.82, green: 0.82, blue: 0.85), lineWidth: 1)
            }
        }
    }

    @ViewBuilder private func radarSeries(center: CGPoint, radius: CGFloat) -> some View {
        ZStack {
            ForEach(entries) { entry in
                ZStack {
                    SDRadarPolygon(values: entry.values.map { CGFloat($0) })
                        .fill(entry.color.opacity(entry.fillOpacity))
                        .frame(width: radius * 2, height: radius * 2)
                        .position(center)
                    SDRadarPolygon(values: entry.values.map { CGFloat($0) })
                        .stroke(entry.color, lineWidth: 2)
                        .frame(width: radius * 2, height: radius * 2)
                        .position(center)
                }
            }
        }
    }

    @ViewBuilder private func radarLabels(center: CGPoint, radius: CGFloat) -> some View {
        ZStack {
            ForEach(labels.indices, id: \.self) { i in
                Text(labels[i])
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color(red: 0.25, green: 0.25, blue: 0.27))
                    .position(radarPt(i, radius + 26, center))
            }
        }
    }

    private func radarPt(_ index: Int, _ radius: CGFloat, _ center: CGPoint) -> CGPoint {
        let angle = (Double(index) / 5.0) * .pi * 2 - .pi / 2
        return CGPoint(
            x: center.x + CGFloat(cos(angle)) * radius,
            y: center.y + CGFloat(sin(angle)) * radius
        )
    }
}

private struct SDRadarPolygon: Shape {
    let values: [CGFloat]

    func path(in rect: CGRect) -> Path {
        guard !values.isEmpty else { return Path() }
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        var path = Path()
        for (i, value) in values.enumerated() {
            let angle = (Double(i) / Double(values.count)) * .pi * 2 - .pi / 2
            let pt = CGPoint(
                x: center.x + CGFloat(cos(angle)) * radius * value,
                y: center.y + CGFloat(sin(angle)) * radius * value
            )
            if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Line Chart

private struct SDLineChart: View {
    let points: [Double]

    var body: some View {
        GeometryReader { geo in
            let w     = geo.size.width
            let h     = geo.size.height
            let maxV  = (points.max() ?? 120) * 1.04
            let minV  = max((points.min() ?? 0) * 0.96, 0)
            let range = max(maxV - minV, 1)
            let plotW = w - 34
            let plotH = h - 20

            ZStack(alignment: .topLeading) {
                ForEach(0..<7, id: \.self) { i in
                    let y = CGFloat(i) / 6.0 * plotH
                    Path { p in
                        p.move(to: CGPoint(x: 0, y: y))
                        p.addLine(to: CGPoint(x: plotW, y: y))
                    }
                    .stroke(
                        Color(red: 0.88, green: 0.88, blue: 0.90),
                        style: StrokeStyle(lineWidth: 1, dash: [3, 3])
                    )
                }

                Path { path in
                    for (i, val) in points.enumerated() {
                        let x = plotW * CGFloat(i) / CGFloat(max(points.count - 1, 1))
                        let y = plotH - CGFloat(val - minV) / CGFloat(range) * plotH
                        if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                        else       { path.addLine(to: CGPoint(x: x, y: y)) }
                    }
                }
                .stroke(
                    Color.sdChartGreen,
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
                )

                VStack(spacing: 0) {
                    ForEach([120, 100, 80, 60, 40, 20, 0], id: \.self) { val in
                        Text("\(val)")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(Color(red: 0.40, green: 0.72, blue: 0.56))
                            .frame(height: plotH / 6, alignment: .top)
                    }
                }
                .offset(x: plotW + 4, y: 0)

                HStack(spacing: 0) {
                    ForEach(["04/23","04/25","05/05","10/03","11/25","15/04","06/10"], id: \.self) { label in
                        Text(label)
                            .font(.system(size: 8, weight: .medium))
                            .foregroundStyle(Color(red: 0.48, green: 0.48, blue: 0.50))
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(width: plotW)
                .offset(y: plotH + 4)
            }
        }
    }
}

#Preview {
    StockDetailView(stockCode: "ASELS")
}
