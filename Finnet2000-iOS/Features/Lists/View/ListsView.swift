import SwiftUI

struct ListsView: View {
    @StateObject private var viewModel = ListsViewModel()
    @State private var selectedTab: Int = 0
    @State private var stockSort: ListSortOrder = .gainers
    @State private var fundSort: ListSortOrder = .gainers
    @State private var showCreatePortfolio = false

    private var sortedStocks: [FavouriteStock] {
        switch stockSort {
        case .gainers:      return viewModel.stocks.sorted { $0.return > $1.return }
        case .losers:       return viewModel.stocks.sorted { $0.return < $1.return }
        case .alphabetical: return viewModel.stocks.sorted { $0.code < $1.code }
        case .date:         return viewModel.stocks
        }
    }

    private var sortedFunds: [FavouriteRobofund] {
        switch fundSort {
        case .gainers:      return viewModel.robofunds.sorted { $0.return > $1.return }
        case .losers:       return viewModel.robofunds.sorted { $0.return < $1.return }
        case .alphabetical: return viewModel.robofunds.sorted { $0.robofundCode < $1.robofundCode }
        case .date:         return viewModel.robofunds
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Üstte Tab Bar
            Picker("Tabs", selection: $selectedTab) {
                Text("Takip Listem").tag(0)
                Text("Portföylerim").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()

            // MARK: - İçerik
            Group {
                if selectedTab == 0 {
                    favouritesTab
                } else {
                    portfoliosTab
                }
            }
            .animation(.easeInOut, value: selectedTab)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            if viewModel.stocks.isEmpty && viewModel.robofunds.isEmpty {
                viewModel.loadFavourites()
            }
            if viewModel.portfolios.isEmpty {
                viewModel.loadPortfolios()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showCreatePortfolio) {
            CreatePortfolioSheet(isPresented: $showCreatePortfolio)
        }
    }

    // MARK: - Favoriler Tab
    private var favouritesTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if viewModel.isLoading {
                    ProgressView("Favoriler yükleniyor…")
                        .padding()
                } else if let error = viewModel.errorMessage {
                    VStack {
                        Text(error)
                            .foregroundColor(.red)
                        Button("Tekrar Dene") {
                            viewModel.loadFavourites()
                        }
                    }
                } else {
                    // MARK: - Hisseler
                    if !viewModel.stocks.isEmpty {
                        ListSectionHeader(title: "Hisselerim", icon: "chart.line.uptrend.xyaxis", sortOrder: $stockSort)
                        
                        ForEach(sortedStocks) { stock in
                            NavigationLink { StockDetailMockView() } label: {
                                HStack {
                                    AsyncImage(url: URL(string: stock.logoPath)) { image in
                                        image.resizable()
                                    } placeholder: {
                                        Color.gray.opacity(0.3)
                                    }
                                    .frame(width: 40, height: 40)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))

                                    VStack(alignment: .leading) {
                                        Text(stock.code)
                                            .font(.headline)
                                        Text(stock.name)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()

                                    VStack(alignment: .trailing) {
                                        Text(stock.price.compactCurrencyString())
                                            .font(.headline)
                                        Text(String(format: "%.2f%%", stock.return))
                                            .font(.subheadline)
                                            .foregroundColor(stock.return >= 0 ? .green : .red)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                            }
                            .buttonStyle(.plain)
                            Divider().padding(.leading, 56)
                        }
                    }

                    // MARK: - Robofonlar
                    if !viewModel.robofunds.isEmpty {
                        ListSectionHeader(title: "Robofonlarım", icon: "cpu", sortOrder: $fundSort)
                        
                        ForEach(sortedFunds) { fund in
                            HStack {
                                AsyncImage(url: URL(string: fund.logoPath)) { image in
                                    image.resizable()
                                } placeholder: {
                                    Color.gray.opacity(0.3)
                                }
                                .frame(width: 40, height: 40)
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                                VStack(alignment: .leading) {
                                    Text(fund.robofundCode)
                                        .font(.headline)
                                    Text(fund.robofundName)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Text(String(format: "%.2f%%", fund.return))
                                    .font(.headline)
                                    .foregroundColor(fund.return >= 0 ? .green : .red)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            Divider().padding(.leading, 56)
                        }
                    }

                    if viewModel.stocks.isEmpty && viewModel.robofunds.isEmpty {
                        Text("Henüz favoriniz yok.")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
            }
        }
    }

    // MARK: - Portföyler Tab
    private var portfoliosTab: some View {
        Group {
            if viewModel.isLoadingPortfolios {
                ProgressView("Portföyler yükleniyor…")
                    .padding()
            } else if let error = viewModel.errorMessagePortfolios {
                VStack {
                    Text(error)
                        .foregroundColor(.red)
                    Button("Tekrar Dene") {
                        viewModel.loadPortfolios()
                    }
                }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Portföylerim header — hisselerim bandı ile aynı yükseklik
                        HStack(spacing: 8) {
                            Image(systemName: "briefcase")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.secondary)
                            Text("Portföylerim")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.secondary)
                            Spacer()
                            Button {
                                showCreatePortfolio = true
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 13, weight: .semibold))
                                    Text("Yeni Portföy Ekle")
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                .foregroundColor(.midGreen)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))

                        if viewModel.portfolios.isEmpty {
                            Text("Henüz portföyünüz yok.")
                                .foregroundColor(.secondary)
                                .padding()
                        }

                        ForEach(viewModel.portfolios) { item in
                            NavigationLink {
                                PortfolioDetailView(detail: .mock)
                            } label: {
                                HStack(spacing: 14) {
                                    AsyncImage(url: URL(string: item.logoPath)) { image in
                                        image.resizable()
                                    } placeholder: {
                                        Color.gray.opacity(0.3)
                                    }
                                    .frame(width: 40, height: 40)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))

                                    VStack(alignment: .leading) {
                                        Text(item.portfolioName)
                                            .font(.headline)
                                        Text("Oluşturma: \(formattedDate(item.createDate))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()

                                    VStack(alignment: .trailing) {
                                        Text(String(format: "%.2f₺", item.dailyValue))
                                            .font(.headline)
                                        Text(String(format: "%.2f%%", item.dailyReturn))
                                            .font(.subheadline.bold())
                                            .foregroundColor(item.dailyReturn >= 0 ? .midGreen : .red)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                            }
                            .buttonStyle(.plain)

                            Divider().padding(.leading, 56)
                        }
                    }
                }
            }
        }
    }

    private func formattedDate(_ isoString: String) -> String {
        return isoString.f2000Formatted
    }
}

// MARK: - Sort Order

enum ListSortOrder: CaseIterable, Equatable {
    case gainers, losers, alphabetical, date
}

// MARK: - Section Header

struct ListSectionHeader: View {
    let title: String
    let icon: String
    var sortOrder: Binding<ListSortOrder>? = nil

    private let finnetGreen = Color(red: 0.18, green: 0.72, blue: 0.40)

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.secondary)
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.secondary)
            Spacer()
            if let sort = sortOrder {
                sortButtons(sort)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
    }

    private func sortButtons(_ sort: Binding<ListSortOrder>) -> some View {
        HStack(spacing: 2) {
            ForEach(ListSortOrder.allCases, id: \.self) { order in
                let isSelected = sort.wrappedValue == order
                Button { withAnimation(.easeInOut(duration: 0.15)) { sort.wrappedValue = order } } label: {
                    sortIcon(order)
                        .foregroundColor(isSelected ? finnetGreen : .secondary)
                        .frame(width: 30, height: 26)
                        .background(
                            RoundedRectangle(cornerRadius: 7)
                                .fill(isSelected ? finnetGreen.opacity(0.18) : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.trailing, 4)
    }

    @ViewBuilder
    private func sortIcon(_ order: ListSortOrder) -> some View {
        switch order {
        case .gainers:
            Image(systemName: "arrow.up")
                .font(.system(size: 13, weight: .semibold))
        case .losers:
            Image(systemName: "arrow.down")
                .font(.system(size: 13, weight: .semibold))
        case .alphabetical:
            Text("AZ")
                .font(.system(size: 11, weight: .bold))
        case .date:
            Image(systemName: "calendar")
                .font(.system(size: 13, weight: .semibold))
        }
    }
}

// MARK: - Create Portfolio Sheet

struct CreatePortfolioSheet: View {
    @Binding var isPresented: Bool
    @State private var portfolioName = ""
    @State private var targetAmount = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Portföy Oluştur")
                .font(.title2.bold())
                .padding(.top, 8)

            TextField("Portföyünüze isim verin", text: $portfolioName)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

            TextField("Hedef Belirleyin (İsteğe Bağlı)", text: $targetAmount)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

            Button {
                isPresented = false
            } label: {
                Text("Oluştur")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.midGreen)
                    .cornerRadius(30)
            }
            .padding(.top, 8)
            .disabled(portfolioName.trimmingCharacters(in: .whitespaces).isEmpty)

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 48)
        .presentationDetents([.height(280)])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    ListsView()
}
