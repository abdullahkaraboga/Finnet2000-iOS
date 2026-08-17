import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()

    var body: some View {
        VStack(spacing: 0) {
            // MARK: Search Bar
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Hisse ara (kod veya isim)", text: $viewModel.query)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                if !viewModel.query.isEmpty {
                    Button {
                        viewModel.query = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 8)

            // MARK: Content
            if viewModel.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if let error = viewModel.errorMessage {
                ContentUnavailableView(
                    "Yüklenemedi",
                    systemImage: "wifi.slash",
                    description: Text(error)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.filteredStocks.isEmpty {
                ContentUnavailableView(
                    "Sonuç bulunamadı",
                    systemImage: "magnifyingglass",
                    description: Text("Farklı bir hisse kodu veya ismi ile tekrar arayın.")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(viewModel.filteredStocks) { stock in
                    NavigationLink { StockDetailView(stockCode: stock.code) } label: {
                        SearchStockRow(stock: stock)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Arama")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.black)
        .toolbarBackground(.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .task {
            viewModel.loadStocks(defaultRequest: true)
        }
    }
}

// MARK: - Stock Row

private struct SearchStockRow: View {
    let stock: FilteredStockItem

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: stock.logoPath)) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 40, height: 40)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(stock.code)
                    .font(.headline)
                Text(stock.name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(stock.price.compactCurrencyString())
                    .font(.headline)
                Text(stock.value.compactString())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SearchView()
}

