import SwiftUI
import Charts

struct CompareView: View {
    @StateObject private var viewModel = CompareViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        // 🔹 Picker
                        pickerSection
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .padding(.bottom, 20)
                        contentSections
                    }
                    
                    .padding(.bottom, 24)
                }
                .background(Color(.systemBackground))
                .overlay(loadingOverlay)
                .alert("Hata", isPresented: Binding(
                    get: { viewModel.error != nil },
                    set: { if !$0 { viewModel.clearError() } }
                )) {
                    Button("Tamam") { viewModel.clearError() }
                } message: {
                    Text(viewModel.error?.errorDescription ?? "")
                }
                .onAppear {
                    if viewModel.stocks.isEmpty { viewModel.loadStocks() }
                }
                .onChange(of: viewModel.selectedCode1) { _ in viewModel.fetchCompareIfReady() }
                .onChange(of: viewModel.selectedCode2) { _ in viewModel.fetchCompareIfReady() }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Bölümler

extension CompareView {

    // MARK: Picker
    private var pickerSection: some View {
        HStack(alignment: .top, spacing: 12) {
            SearchableStockDropdown(slot: 1,
                                    selectedCode: $viewModel.selectedCode1,
                                    result: viewModel.compareResult,
                                    stocks: viewModel.stocks)
                .zIndex(1) // Usually first item gets hidden by second, so base zIndex 1 is safe but dynamic zIndex inside handles it.
            
            SearchableStockDropdown(slot: 2,
                                    selectedCode: $viewModel.selectedCode2,
                                    result: viewModel.compareResult,
                                    stocks: viewModel.stocks)
                .zIndex(0)
        }
    }
    
    // MARK: Content Sections (extracted to help the compiler)
    private var contentSections: some View {
        Group {
            // 🔹 Picker (no picker content here; picker is above)

            if let result = viewModel.compareResult {
                RadarChartSection(result: result)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
            }

            // 🔹 Hisse Fiyatları Çift Çizgi Grafik
            if let result = viewModel.compareResult {
                PriceChartSection(result: result,
                                  leftKey: viewModel.selectedCode1,
                                  rightKey: viewModel.selectedCode2)
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }

            // 🔹 Risk Parametreleri
            if let result = viewModel.compareResult {
                RiskParametersSection(result: result, leftKey: viewModel.selectedCode1, rightKey: viewModel.selectedCode2)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
            }

            // 🔹 Getiriler
            if let result = viewModel.compareResult {
                ReturnsSection(result: result, leftKey: viewModel.selectedCode1, rightKey: viewModel.selectedCode2)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
            }

            // 🔹 Finansal Tablolar
            if let result = viewModel.compareResult {
                FinancialTablesSection(result: result, leftKey: viewModel.selectedCode1, rightKey: viewModel.selectedCode2)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
            }

            // 🔹 Finansal Analiz
            if let result = viewModel.compareResult {
                FinancialAnalysisSection(result: result, leftKey: viewModel.selectedCode1, rightKey: viewModel.selectedCode2)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
            }

            // 🔹 Hangi Fonlarda Var?
            if let result = viewModel.compareResult {
                FundsBarChartSection(result: result,
                                     leftKey: viewModel.selectedCode1,
                                     rightKey: viewModel.selectedCode2)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
            }
        }
    }
    
    // MARK: Loading Overlay
    private var loadingOverlay: some View {
        Group {
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.3).ignoresSafeArea()
                    ProgressView("Yükleniyor…")
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                }
            } else {
                EmptyView()
            }
        }
    }
}

// MARK: - Searchable Stock Dropdown
struct SearchableStockDropdown: View {
    let slot: Int
    @Binding var selectedCode: String?
    let result: CompareStocksResponse?
    let stocks: [StockListItem]
    
    @State private var isExpanded: Bool = false
    @State private var searchText: String = ""
    
    var filteredStocks: [StockListItem] {
        if searchText.isEmpty {
            return stocks
        } else {
            return stocks.filter { $0.code.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        let detail = selectedCode.flatMap { result?[$0] }
        let accentColor: Color = slot == 1 ? Color(red: 0.22, green: 0.47, blue: 0.80) : Color.midGreen
        
        VStack(spacing: 6) {
            ZStack(alignment: .top) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(accentColor.opacity(0.25))
                                .frame(width: 40, height: 40)
                            if let logo = detail?.logo, let url = URL(string: logo) {
                                AsyncImage(url: url) { img in
                                    img.resizable().scaledToFit()
                                } placeholder: {
                                    Text(selectedCode?.prefix(1).uppercased() ?? "F")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .frame(width: 32, height: 32)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                            } else {
                                Text(selectedCode?.prefix(1).uppercased() ?? "F")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }

                        Text(selectedCode ?? "\(slot). Hisse")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(1)

                        Spacer(minLength: 0)

                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                
                if isExpanded {
                    VStack(spacing: 0) {
                        // Search bar
                        TextField("Ara...", text: $searchText)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .padding(12)
                        
                        // List
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 0) {
                                ForEach(filteredStocks) { stock in
                                    Button {
                                        selectedCode = stock.code
                                        withAnimation {
                                            isExpanded = false
                                            searchText = ""
                                        }
                                    } label: {
                                        Text(stock.code)
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.black)
                                            .padding(.vertical, 14)
                                            .padding(.horizontal, 16)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 250)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                    .offset(y: 65)
                }
            }
            .zIndex(isExpanded ? 100 : 0) // Important to float above sibling cards

            if let name = detail?.name {
                Text(name)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            } else {
                Text(" ") // Keeps layout stable
                    .font(.system(size: 12))
            }
        }
        .frame(maxWidth: .infinity)
        .zIndex(isExpanded ? 100 : 0) // Apply to parent container too for HStack z-ordering
    }
}

// MARK: - PriceChartSection

struct PriceChartSection: View {
    let result: CompareStocksResponse
    let leftKey: String?
    let rightKey: String?

    private var leftColor: Color { Color(red: 0.40, green: 0.72, blue: 0.95) }
    private var rightColor: Color { Color.midGreen }

    var body: some View {
        let left  = (result.keys.contains(leftKey  ?? "") ? leftKey  : result.keys.first)  ?? ""
        let right = (result.keys.contains(rightKey ?? "") ? rightKey : result.keys.dropFirst().first) ?? ""

        let leftPrices  = result[left]?.datePriceList
        let rightPrices = result[right]?.datePriceList

        guard let lp = leftPrices, !lp.dates.isEmpty,
              let rp = rightPrices, !rp.dates.isEmpty else { return AnyView(EmptyView()) }

        return AnyView(
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Hisse Fiyatları")
                        .font(.system(size: 17, weight: .bold))
                    Image(systemName: "info.circle")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }

                if #available(iOS 16.0, *) {
                    dualLineChart(left: left, right: right, lp: lp, rp: rp)
                } else {
                    Text("Grafik iOS 16+ gerektirir.")
                        .foregroundColor(.secondary)
                }
            }
        )
    }

    @available(iOS 16.0, *)
    private func dualLineChart(left: String, right: String,
                               lp: DateValueList, rp: DateValueList) -> some View {
        // Precompute safe indices and values to keep the Chart builder simple
        let leftCount = min(lp.dates.count, lp.values.count)
        let rightCount = min(rp.dates.count, rp.values.count)
        let leftIndices: [Int] = Array(0..<leftCount)
        let rightIndices: [Int] = Array(0..<rightCount)

        return VStack(spacing: 0) {
            Chart {
                // Left series
                ForEach(leftIndices, id: \.self) { i in
                    let y = lp.values[i]
                    LineMark(
                        x: .value("Tarih", i),
                        y: .value(left, y),
                        series: .value("Hisse", left)
                    )
                    .foregroundStyle(leftColor)
                    .interpolationMethod(.catmullRom)
                }
                // Right series
                ForEach(rightIndices, id: \.self) { i in
                    let y = rp.values[i]
                    LineMark(
                        x: .value("Tarih", i),
                        y: .value(right, y),
                        series: .value("Hisse", right)
                    )
                    .foregroundStyle(rightColor)
                    .interpolationMethod(.catmullRom)
                }
            }
            .chartXAxis {
                let desiredTickCount = 6
                let tickStride = max(1, leftCount / desiredTickCount)
                let ticks: [Int] = stride(from: 0, to: leftCount, by: tickStride).map { $0 }
                AxisMarks(values: ticks) { v in
                    if let idx = v.as(Int.self), idx < leftCount {
                        let label = lp.dates[idx]
                        AxisValueLabel(String(label.prefix(5)))
                            .font(.system(size: 9))
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in AxisValueLabel().font(.system(size: 10)) }
            }
        .frame(height: 260)
            .padding(.horizontal, 4)

            Divider()
                .padding(.top, 8)

            // Legend
            HStack(spacing: 20) {
                legendItem(color: leftColor,  label: left)
                legendItem(color: rightColor, label: right)
            }
            .padding(.top, 8)
        }
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 18, height: 3)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    CompareView()
}

