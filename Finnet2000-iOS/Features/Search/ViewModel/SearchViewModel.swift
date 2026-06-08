import Foundation
import Combine

@MainActor
final class SearchViewModel: ObservableObject {

    // MARK: - Published State

    @Published private(set) var stocks: [FilteredStockItem] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    // Client-side search query
    @Published var query: String = ""

    // MARK: - Computed

    var filteredStocks: [FilteredStockItem] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return stocks }
        return stocks.filter {
            $0.code.localizedCaseInsensitiveContains(trimmed) ||
            $0.name.localizedCaseInsensitiveContains(trimmed)
        }
    }

    // MARK: - Dependencies

    private let repository: SearchRepositoryProtocol

    init(repository: SearchRepositoryProtocol = SearchRepository()) {
        self.repository = repository
    }

    // MARK: - Actions

    /// API'den filtrelenmiş hisseleri çeker. defaultRequest=false ile gerçek filtre, true ile varsayılan liste.
    func loadStocks(filterRequest: FilterRequest = FilterRequest(), defaultRequest: Bool = false) {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        Task {
            defer { isLoading = false }
            do {
                stocks = try await repository.fetchFilteredStocks(request: filterRequest, defaultRequest: defaultRequest)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
