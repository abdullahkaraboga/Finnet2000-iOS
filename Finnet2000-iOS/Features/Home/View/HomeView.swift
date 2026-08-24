// HomePageScreen.swift
// iOS - SwiftUI versiyonu

import Charts
import Combine
import SwiftUI

// MARK: - Identifiable extensions for API models

extension RobofundPortfolio: Identifiable {
  public var id: Int { portfolioId }
}

extension StockStat: Identifiable {
  public var id: String { code }
}

extension DailyIndex: Identifiable {
  public var id: String { code }
}

extension CurrencyPrice: Identifiable {
  public var id: String { code }
}

extension AnnualGraph: Identifiable {
  public var id: String { code }
}

extension CurrencyPriceGroup: Identifiable {
  public var id: String { assetType }
}



// MARK: - Formatters

func formatCurrency(_ value: Double) -> String {
  value.compactCurrencyString()
}

func formatRatio(_ value: Double) -> String {
  let formatted = String(format: "%.2f", abs(value))
  return (value < 0 ? "-" : "%") + formatted
}

func formatDate(_ dateString: String) -> String {
  return dateString.f2000Formatted
}

// MARK: - HomePageScreen (Ana ekran)

struct HomePageScreen: View {
  @Environment(\.scenePhase) private var scenePhase
  @StateObject private var viewModel: HomeViewModel
  @StateObject private var liveDataVM = StockLiveDataViewModel()

  init(viewModelFactory: @escaping @MainActor () -> HomeViewModel) {
    _viewModel = StateObject(wrappedValue: viewModelFactory())
  }

  init(viewModel: HomeViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }

  var body: some View {
    ZStack {
      if viewModel.isLoading {
        Color(.systemBackground).ignoresSafeArea()
        ProgressView()
          .progressViewStyle(CircularProgressViewStyle(tint: .midGreen))
          .scaleEffect(1.5)
      } else if let data = viewModel.data {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    DarkHeaderView(contents: data.contents ?? [], liveStocks: liveDataVM.stocks)
                    VStack(spacing: 0) {
                        RoboSepetlerView(portfolios: data.robofundResponse ?? [])
                            .padding(.horizontal, 16)
                        LineChartView(annualGraphInfo: data.annualGraphInfo ?? [])
                            .padding(.horizontal, 16)
                        StockMarketTodayView(dailyIndexInfo: data.dailyIndexInfo ?? [])
                            .padding(.horizontal, 16)
                        if let stockStatsDetail = data.stockStatsDetail {
                            MostChangedStocksView(stockStatsDetail: stockStatsDetail)
                                .padding(.horizontal, 16)
                            MostTransactionStocksView(stockStatsDetail: stockStatsDetail)
                                .padding(.horizontal, 16)
                        }
                        CurrencyPriceInfoView(currencyPriceInfo: data.currencyPriceInfo ?? [], scrollViewProxy: proxy)
                            .padding(.horizontal, 16)
                        Spacer().frame(height: 80)
                    }
                }
            }
        }
      } else if let error = viewModel.errorMessage {
        VStack(spacing: 12) {
          Text("Veri alınamadı.")
            .foregroundColor(.secondary)
          Text(error)
            .font(.system(size: 12))
            .foregroundColor(.red)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
          Button("Tekrar Dene") { viewModel.fetch() }
            .foregroundColor(.midGreen)
        }
      }
    }
    .task { viewModel.fetch() }
    .onAppear { liveDataVM.connect() }
    .onDisappear { liveDataVM.disconnect() }
    .onChange(of: scenePhase) { _, newPhase in
      switch newPhase {
      case .active:
        liveDataVM.connect()
      case .background:
        liveDataVM.disconnect()
      case .inactive:
        break
      @unknown default:
        break
      }
    }
  }
}

// MARK: - DarkHeaderView

struct DarkHeaderView: View {
  let contents: [ContentItem]
  let liveStocks: [String: StockData]
  @State private var currentPage: Int = 0

  var body: some View {
    VStack(spacing: 0) {
      // Banner slider + dots
      ZStack {
          Color(.systemBackground)

        VStack(spacing: 10) {
          // Banner slider
          TabView(selection: $currentPage) {
            ForEach(Array(contents.enumerated()), id: \.offset) { index, item in
              BannerCardView(item: item)
                .tag(index)
            }
          }
          .tabViewStyle(.page(indexDisplayMode: .never))
          .frame(height: 210)
          .padding(.horizontal, 16)
          .padding(.top, 12)

          // Page dots
          HStack(spacing: 6) {
            ForEach(0..<contents.count, id: \.self) { index in
              Circle()
                .fill(
                  currentPage == index
                    ? Color.white
                    : Color.white.opacity(0.35)
                )
                .frame(
                  width: currentPage == index ? 8 : 6,
                  height: currentPage == index ? 8 : 6
                )
            }
          }
          .animation(.easeInOut(duration: 0.2), value: currentPage)
          .padding(.bottom, 14)
        }
      }

      // Ticker grid – WebSocket canlı data
      TickerGridView(liveStocks: liveStocks)
    }
  }
}

private struct BannerCardView: View {
  let item: ContentItem

  var body: some View {
    ZStack(alignment: .bottomLeading) {
      // Thumbnail resmi
      if let path = item.thumbnailPath, let url = URL(string: path) {
        AsyncImage(url: url) { phase in
          switch phase {
          case .success(let image):
            image.resizable().scaledToFill()
          default:
            Color(.systemGray5)
          }
        }
        .clipped()
      } else {
        LinearGradient(
          gradient: Gradient(colors: [Color.midGreen.opacity(0.25), Color.white]),
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
      }

      // Alt gradient + metin
      LinearGradient(
        gradient: Gradient(colors: [.black.opacity(0.7), .clear]),
        startPoint: .bottom,
        endPoint: .center
      )

      VStack(alignment: .leading, spacing: 4) {
        Text(item.title)
          .font(.system(size: 16, weight: .bold))
          .foregroundColor(.white)
          .lineLimit(2)

        if let desc = item.description {
          Text(desc)
            .font(.system(size: 12))
            .foregroundColor(.white.opacity(0.8))
            .lineLimit(2)
        }
      }
      .padding(14)
    }
    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
  }
}

private struct TickerGridView: View {
  let liveStocks: [String: StockData]

  /// Gösterilecek sembol sırası (ilk 8 indeks)
  private let displayCodes = Array(StockWebSocketManager.indexCodes.prefix(8))

  private var rows: [[String]] {
    stride(from: 0, to: displayCodes.count, by: 4).map {
      Array(displayCodes[$0..<min($0 + 4, displayCodes.count)])
    }
  }

  var body: some View {
    VStack(spacing: 8) {
      ForEach(Array(rows.enumerated()), id: \.offset) { rowIdx, row in
        HStack(spacing: 8) {
          ForEach(row, id: \.self) { code in
            LiveTickerItemView(code: code, data: liveStocks[code])
              .frame(maxWidth: .infinity)
          }
        }
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 16)
    .background(Color(.systemGray6))
  }
}

private struct LiveTickerItemView: View {
  let code: String
  let data: StockData?

  private var displayPrice: String {
    guard let last = data?.last else { return "-" }
    return last.compactString()
  }

  private var change: Double {
    guard let last = data?.last, let close = data?.dailyClose, close != 0 else { return 0 }
    return (last - close) / close * 100
  }

  private var isUp: Bool { change >= 0 }
  private var trendColor: Color { isUp ? .midGreen : Color.red }

  var body: some View {
    VStack(spacing: 0) {
      // Header Area
      Text(code)
        .font(.system(size: 11, weight: .bold))
        .foregroundColor(.primary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.primary.opacity(0.03))
      
      // Values Area
      VStack(spacing: 6) {
        Text(displayPrice)
          .font(.system(size: 13, weight: .bold))
          .foregroundColor(.primary)
          .lineLimit(1)
          .minimumScaleFactor(0.7)
          
        HStack(spacing: 2) {
          Image(systemName: isUp ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
            .font(.system(size: 8))
          Text(String(format: "%.2f%%", abs(change)))
            .font(.system(size: 11, weight: .semibold))
        }
        .foregroundColor(trendColor)
      }
      .padding(.vertical, 10)
      .frame(maxWidth: .infinity)
      .background(Color(.systemBackground))
    }
    .clipShape(RoundedRectangle(cornerRadius: 8))
    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
  }
}

// MARK: - RoboSepetlerView

struct RoboSepetlerView: View {
  let portfolios: [RobofundPortfolio]

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      MainPagesBigTitle("RoboSepetler")
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
          ForEach(portfolios) { portfolio in
            NavigationLink {
              RoboSepetDetailView(portfolioId: portfolio.portfolioId)
            } label: {
              RoboSepetCardView(portfolio: portfolio)
            }
            .buttonStyle(.plain)
          }
        }
        .padding(.vertical, 4)
      }
    }
    .padding(.vertical, 28)
  }
}

struct RoboSepetCardView: View {
  let portfolio: RobofundPortfolio

  var trendColor: Color { portfolio.dailyReturn >= 0 ? .midGreen : .red }

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack(spacing: 8) {
        AsyncImage(url: URL(string: portfolio.logoPath)) { image in
          image.resizable().scaledToFill()
        } placeholder: {
          Image(systemName: "chart.bar.fill")
            .foregroundColor(.midGreen)
        }
        .frame(width: 32, height: 32)
        .clipShape(Circle())
        .background(Circle().fill(Color(.systemGray5)))

        VStack(alignment: .leading, spacing: 2) {
          Text(portfolio.code)
            .font(.system(size: 13, weight: .bold))
          Text(portfolio.name)
            .font(.system(size: 11))
            .foregroundColor(.secondary)
            .lineLimit(1)
        }
      }

      MiniLineChartView(prices: portfolio.weeklyReturnList, color: trendColor)
        .frame(height: 36)

      HStack {
        VStack(alignment: .leading, spacing: 2) {
          Text("Günlük")
            .font(.system(size: 10))
            .foregroundColor(.secondary)
          Text(formatRatio(portfolio.dailyReturn))
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(trendColor)
        }
        Spacer()
        VStack(alignment: .trailing, spacing: 2) {
          Text("Haftalık")
            .font(.system(size: 10))
            .foregroundColor(.secondary)
          Text(formatRatio(portfolio.weeklyReturn))
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(portfolio.weeklyReturn >= 0 ? .midGreen : .red)
        }
      }
    }
    .padding(12)
    .frame(width: 160)
    .background(Color(.systemGray6))
    .cornerRadius(12)
    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
  }
}

// MARK: - LineChartView

struct LineChartView: View {
  let annualGraphInfo: [AnnualGraph]
  @State private var lineIndex: Int = 0

  var assetNames: [String] { annualGraphInfo.map { $0.name } }

  var body: some View {
    VStack(spacing: 16) {
      HStack {
        MainPagesBigTitle("Değer Seçin")
        Spacer()
        AssetSelectionView(
          selectedIndex: $lineIndex,
          values: assetNames
        )
      }

      if let item = annualGraphInfo[safe: lineIndex] {
        LineChartCardView(
          price: item.price,
          dailyReturn: item.dailyReturn,
          prices: item.prices,
          dates: item.dates
        )
      }
    }
    .padding(.vertical, 28)
  }
}

struct LineChartCardView: View {
  let price: Double
  let dailyReturn: Double
  let prices: [Double]
  let dates: [String]

  var lineColor: Color { dailyReturn < 0 ? .pink : .midGreen }

  var body: some View {
    VStack(spacing: 0) {
      // Değer etiketi
      HStack {
        Text(formatCurrency(price))
          .font(.system(size: 20, weight: .bold))
          .foregroundColor(.primary)
        Spacer()
        HStack(spacing: 2) {
          Image(systemName: dailyReturn < 0 ? "arrowtriangle.down.fill" : "arrowtriangle.up.fill")
            .foregroundColor(lineColor)
            .font(.system(size: 14))
          Text(formatRatio(dailyReturn))
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(lineColor)
        }
      }
      .padding(12)
      .background(Color(.systemGray5))
      .cornerRadius(8)
      .padding(.bottom, 8)

      // Grafik
      if #available(iOS 16.0, *) {
        Chart {
          ForEach(Array(prices.enumerated()), id: \.offset) { index, value in
            LineMark(
              x: .value("Tarih", index),
              y: .value("Fiyat", value)
            )
            .foregroundStyle(lineColor)
            .interpolationMethod(.catmullRom)

            AreaMark(
              x: .value("Tarih", index),
              yStart: .value("Min", prices.min() ?? 0),
              yEnd: .value("Fiyat", value)
            )
            .foregroundStyle(
              LinearGradient(
                gradient: Gradient(colors: [lineColor.opacity(0.5), .clear]),
                startPoint: .top,
                endPoint: .bottom
              )
            )
            .interpolationMethod(.catmullRom)
          }
        }
        .chartXAxis(.hidden)
        .chartYAxis {
          AxisMarks(preset: .aligned, position: .leading) { value in
            AxisValueLabel()
              .font(.system(size: 10))
          }
        }
        .frame(height: 200)
        .padding(10)
      } else {
        SimpleLineChartView(prices: prices, lineColor: lineColor)
          .frame(height: 200)
          .padding(10)
      }
    }
    .background(Color(.systemGray6))
    .cornerRadius(12)
    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
  }
}

// iOS 15 fallback için basit çizgi grafik
struct SimpleLineChartView: View {
  let prices: [Double]
  let lineColor: Color

  var body: some View {
    GeometryReader { geo in
      let minVal = prices.min() ?? 0
      let maxVal = prices.max() ?? 1
      let range = maxVal - minVal == 0 ? 1 : maxVal - minVal
      let w = geo.size.width
      let h = geo.size.height
      let step = w / Double(max(prices.count - 1, 1))

      Path { path in
        for (i, price) in prices.enumerated() {
          let x = Double(i) * step
          let y = h - (price - minVal) / range * h
          if i == 0 {
            path.move(to: CGPoint(x: x, y: y))
          } else {
            path.addLine(to: CGPoint(x: x, y: y))
          }
        }
      }
      .stroke(lineColor, lineWidth: 2.5)
    }
  }
}

// MARK: - StockMarketToday

struct StockMarketTodayView: View {
  let dailyIndexInfo: [DailyIndex]
  @State private var showSheet = false

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      MainPagesBigTitle("Borsada Bugün")
      HStack(spacing: 8) {
        ForEach(dailyIndexInfo.prefix(3)) { index in
          StockMarketItemView(index: index)
            .frame(maxWidth: .infinity)
        }
      }
      Button(action: { showSheet = true }) {
        Text("Hepsini Gör")
          .font(.system(size: 14, weight: .semibold))
          .foregroundColor(.midGreen)
          .frame(maxWidth: .infinity)
      }
      .padding(.top, 4)
    }
    .sheet(isPresented: $showSheet) {
      DailyIndexTableSheet(dailyIndexInfo: dailyIndexInfo)
    }
  }
}

struct StockMarketItemView: View {
  let index: DailyIndex

  var trendColor: Color { index.dailyReturn >= 0 ? .midGreen : .pink }

  var body: some View {
    VStack(alignment: .center, spacing: 4) {
      // Header
      HStack {
        Text(index.indexName)
          .font(.system(size: 13, weight: .bold))
        Spacer()
        Image(systemName: index.dailyReturn >= 0 ? "arrow.up.right" : "arrow.down.right")
          .foregroundColor(trendColor)
          .font(.system(size: 12))
      }
      // Fiyat
      Text(formatCurrency(index.price))
        .font(.system(size: 13))
        .foregroundColor(trendColor)
      // Değişim
      Text(formatRatio(index.dailyReturn))
        .font(.system(size: 13))
        .foregroundColor(trendColor)
      // Mini grafik
      MiniLineChartView(prices: index.weeklyPriceList, color: trendColor)
        .frame(height: 40)
    }
    .padding(.horizontal, 10)
    .padding(.vertical, 10)
    .background(Color(.systemGray6))
    .cornerRadius(8)
  }
}

struct MiniLineChartView: View {
  let prices: [Double]
  let color: Color

  var body: some View {
    GeometryReader { geo in
      let minVal = prices.min() ?? 0
      let maxVal = prices.max() ?? 1
      let range = maxVal - minVal == 0 ? 1 : maxVal - minVal
      let w = geo.size.width
      let h = geo.size.height
      let step = w / Double(max(prices.count - 1, 1))

      Path { path in
        for (i, price) in prices.enumerated() {
          let x = Double(i) * step
          let y = h - ((price - minVal) / range) * h
          if i == 0 {
            path.move(to: CGPoint(x: x, y: y))
          } else {
            path.addLine(to: CGPoint(x: x, y: y))
          }
        }
      }
      .stroke(color, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
    }
  }
}

struct DailyIndexTableSheet: View {
  let dailyIndexInfo: [DailyIndex]
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationView {
      List(dailyIndexInfo) { index in
        HStack {
          Text(index.indexName)
            .frame(maxWidth: .infinity, alignment: .leading)
          Text(formatCurrency(index.price))
            .frame(maxWidth: .infinity, alignment: .center)
          Text(formatRatio(index.dailyReturn))
            .foregroundColor(index.dailyReturn >= 0 ? .midGreen : .red)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .font(.system(size: 14))
      }
      .navigationTitle("Tüm Endeksler")
      .navigationBarItems(trailing: Button("Kapat") { dismiss() })
    }
  }
}

// MARK: - MostChangedStocks

struct MostChangedStocksView: View {
  let stockStatsDetail: StockStatsDetail
  @State private var selectedIndex: Int = 0

  var body: some View {
    VStack(spacing: 16) {
      SlidingButtonView(
        options: ["En Çok Yükselen", "En Çok Düşen"],
        icons: ["arrow.up", "arrow.down"],
        selectedIndex: $selectedIndex
      )

      let stocks = selectedIndex == 0 ? stockStatsDetail.highest : stockStatsDetail.lowest

      VStack(spacing: 0) {
        // Başlık satırı
        HStack {
          Text("Hisse").frame(maxWidth: .infinity, alignment: .leading)
          Text("Önceki").frame(maxWidth: .infinity, alignment: .center)
          Text("Son").frame(maxWidth: .infinity, alignment: .center)
          Text("Değişim").frame(maxWidth: .infinity, alignment: .trailing)
        }
        .font(.system(size: 12, weight: .bold))
        .foregroundColor(.secondary)
        .padding(.vertical, 10)
        .padding(.horizontal, 12)

        Divider()

        ForEach(stocks.prefix(5)) { stat in
          HStack {
            Text(stat.code)
              .font(.system(size: 13, weight: .semibold))
              .frame(maxWidth: .infinity, alignment: .leading)
            Text(formatCurrency(stat.firstClosePrice))
              .font(.system(size: 13))
              .frame(maxWidth: .infinity, alignment: .center)
            Text(formatCurrency(stat.lastClosePrice))
              .font(.system(size: 13))
              .frame(maxWidth: .infinity, alignment: .center)
            Text(formatRatio(stat.dailyReturn))
              .font(.system(size: 13, weight: .semibold))
              .foregroundColor(stat.dailyReturn >= 0 ? .midGreen : .red)
              .frame(maxWidth: .infinity, alignment: .trailing)
          }
          .padding(.vertical, 12)
          .padding(.horizontal, 12)
          Divider()
        }
      }
      .background(Color(.systemGray6))
      .cornerRadius(10)
    }
    .padding(.vertical, 28)
    .animation(.easeInOut(duration: 0.3), value: selectedIndex)
  }
}

// MARK: - MostTransactionStocks

struct MostTransactionStocksView: View {
  let stockStatsDetail: StockStatsDetail
  @State private var typeIndex: Int = 0

  var body: some View {
    VStack(spacing: 16) {
      HStack {
        MainPagesBigTitle("En Çok İşlem Görenler")
        Spacer()
        AssetSelectionView(selectedIndex: $typeIndex, values: ["Hacim", "Adet"])
      }

      let stocks = typeIndex == 0 ? stockStatsDetail.mostVolumes : stockStatsDetail.mostAmounts

      VStack(spacing: 0) {
        // Başlık satırı
        HStack {
          Text("Hisse").frame(maxWidth: .infinity, alignment: .leading)
          Text(typeIndex == 0 ? "Hacim" : "Adet").frame(maxWidth: .infinity, alignment: .center)
          Text("Son").frame(maxWidth: .infinity, alignment: .center)
          Text("Değişim").frame(maxWidth: .infinity, alignment: .trailing)
        }
        .font(.system(size: 12, weight: .bold))
        .foregroundColor(.secondary)
        .padding(.vertical, 10)
        .padding(.horizontal, 12)

        Divider()

        ForEach(stocks.prefix(5)) { stat in
          HStack {
            Text(stat.code)
              .font(.system(size: 13, weight: .semibold))
              .frame(maxWidth: .infinity, alignment: .leading)
            Text(
              typeIndex == 0
                ? formatCurrency(stat.volume) : stat.amount.compactString(fractionDigits: 0)
            )
            .font(.system(size: 13))
            .frame(maxWidth: .infinity, alignment: .center)
            Text(formatCurrency(stat.lastClosePrice))
              .font(.system(size: 13))
              .frame(maxWidth: .infinity, alignment: .center)
            Text(formatRatio(stat.dailyReturn))
              .font(.system(size: 13, weight: .semibold))
              .foregroundColor(stat.dailyReturn >= 0 ? .midGreen : .red)
              .frame(maxWidth: .infinity, alignment: .trailing)
          }
          .padding(.vertical, 12)
          .padding(.horizontal, 12)
          Divider()
        }
      }
      .background(Color(.systemGray6))
      .cornerRadius(10)
    }
    .padding(.vertical, 28)
    .animation(.easeInOut(duration: 0.3), value: typeIndex)
  }
}

// MARK: - CurrencyPriceInfo

struct CurrencyPriceInfoView: View {
    let currencyPriceInfo: [CurrencyPriceGroup]
    var scrollViewProxy: ScrollViewProxy?
    @State private var selectedIndex: Int = 0
    private let bottomID = "CurrencyPriceInfoViewBottom"

    init(currencyPriceInfo: [CurrencyPriceGroup], scrollViewProxy: ScrollViewProxy? = nil) {
        self.currencyPriceInfo = currencyPriceInfo
        self.scrollViewProxy = scrollViewProxy
    }

  /// Döviz grubunu öne alarak sıralar
  var sortedGroups: [CurrencyPriceGroup] {
    currencyPriceInfo.sorted { a, _ in
      a.assetType.localizedCaseInsensitiveContains("döviz")
        || a.assetType.localizedCaseInsensitiveContains("doviz")
    }
  }

  var tabTitles: [String] { sortedGroups.map { $0.assetType } }

  var body: some View {
    VStack(spacing: 8) {
      SlidingButtonView(
        options: tabTitles,
        icons: [],
        selectedIndex: $selectedIndex
      )

      if let group = sortedGroups[safe: selectedIndex] {
        VStack(spacing: 0) {
          // Başlık satırı
          HStack {
            Text("Endeks").frame(maxWidth: .infinity, alignment: .leading)
            Text("Fiyat").frame(maxWidth: .infinity, alignment: .center)
            Text("Tarih").frame(maxWidth: .infinity, alignment: .trailing)
          }
          .font(.system(size: 12, weight: .bold))
          .foregroundColor(.secondary)
          .padding(.vertical, 10)
          .padding(.horizontal, 12)

          Divider()

          ForEach(group.assetPrices) { asset in
            HStack {
              Text(asset.name)
                .font(.system(size: 13))
                .frame(maxWidth: .infinity, alignment: .leading)
              Text(formatCurrency(asset.price))
                .font(.system(size: 13))
                .frame(maxWidth: .infinity, alignment: .center)
              Text(formatDate(asset.date))
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            Divider()
          }
        }
        .background(Color(.systemGray6))
        .cornerRadius(10)
      }
        Color.clear.frame(height: 1, alignment: .bottom).id(bottomID)
    }
    .padding(.vertical, 28)
    .animation(.easeInOut(duration: 0.3), value: selectedIndex)
    .onChange(of: selectedIndex) { newIndex in
        if let proxy = scrollViewProxy {
            withAnimation {
                proxy.scrollTo(bottomID, anchor: .bottom)
            }
        }
    }
  }
}

// MARK: - Reusable Components

/// Büyük başlık
struct MainPagesBigTitle: View {
  let text: String
  init(_ text: String) { self.text = text }

  var body: some View {
    Text(text)
      .font(.system(size: 17, weight: .bold))
      .foregroundColor(.primary)
  }
}

/// Kayar sekme butonu (SlidingButtonView)
struct SlidingButtonView: View {
  let options: [String]
  let icons: [String]
  @Binding var selectedIndex: Int

  var body: some View {
    Picker("", selection: $selectedIndex) {
      ForEach(Array(options.enumerated()), id: \.offset) { i, option in
        if i < icons.count, !icons[i].isEmpty {
          Label(option, systemImage: icons[i]).tag(i)
        } else {
          Text(option).tag(i)
        }
      }
    }
    .pickerStyle(.segmented)
    .padding(.vertical, 4)
  }
}





// MARK: - Preview

struct HomePageScreen_Previews: PreviewProvider {
  static var previews: some View {
    HomePageScreen {
      HomeViewModel()
    }
  }
}

// MARK: - Backward compatibility alias

typealias HomeView = HomePageScreen
