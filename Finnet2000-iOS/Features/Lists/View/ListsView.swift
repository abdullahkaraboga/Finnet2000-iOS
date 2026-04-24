import SwiftUI

struct ListsView: View {
    @StateObject private var viewModel = ListsViewModel()
    @State private var selectedTab: Int = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Üstte Tab Bar
                Picker("Tabs", selection: $selectedTab) {
                    Text("Favoriler").tag(0)
                    Text("Portföyler").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                Divider()

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
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Favoriler Tab
    private var favouritesTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
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
                        Text("📈 Hisselerim")
                            .font(.title3.bold())
                            .padding(.horizontal)
                        
                        ForEach(viewModel.stocks) { stock in
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
                                    Text(String(format: "%.2f ₺", stock.price))
                                        .font(.headline)
                                    Text(String(format: "%.2f%%", stock.return))
                                        .font(.subheadline)
                                        .foregroundColor(stock.return >= 0 ? .green : .red)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 6)
                        }
                    }

                    // MARK: - Robofonlar
                    if !viewModel.robofunds.isEmpty {
                        Text("🤖 Robofonlarım")
                            .font(.title3.bold())
                            .padding(.horizontal)
                        
                        ForEach(viewModel.robofunds) { fund in
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
                            .padding(.horizontal)
                            .padding(.vertical, 6)
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
            } else if viewModel.portfolios.isEmpty {
                Text("Henüz portföyünüz yok.")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                List(viewModel.portfolios) { item in
                    HStack(spacing: 12) {
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
                            Text(String(format: "%.2f%%", item.dailyReturn))
                                .font(.subheadline.bold())
                                .foregroundColor(item.dailyReturn >= 0 ? .green : .red)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
    }

    private func formattedDate(_ isoString: String) -> String {
        if let date = ISO8601DateFormatter().date(from: isoString) {
            let df = DateFormatter()
            df.dateStyle = .medium
            df.timeStyle = .short
            return df.string(from: date)
        }
        return isoString
    }
}
