import Foundation
import Combine

@MainActor
final class CompareViewModel: ObservableObject {

    // MARK: - Published State
    @Published var stocks: [StockListItem] = []
    @Published var selectedCode1: String?
    @Published var selectedCode2: String?
    @Published var compareResult: CompareStocksResponse?
    @Published var isLoading: Bool = false
    @Published var error: CompareError?

    // MARK: - Dependencies
    private let repository = ComparisonRepository()

    // MARK: - Computed Properties
    var canCompare: Bool {
        guard let a = selectedCode1, let b = selectedCode2 else { return false }
        return !a.isEmpty && !b.isEmpty && a != b
    }

    // MARK: - Actions

    /// Hisse listesini yükler ve ilk iki hisseyi varsayılan olarak seçer
    func loadStocks() {
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                stocks = try await repository.fetchStockList().sorted { $0.code < $1.code }
                if selectedCode1 == nil { selectedCode1 = stocks.first?.code }
                if selectedCode2 == nil, stocks.count > 1 { selectedCode2 = stocks[1].code }
                fetchCompareIfReady()
            } catch CompareError.unauthorized {
                // 401: sessionDidExpire bildirimi ile yönetilir.
            } catch let err as CompareError {
                self.error = err
            } catch {
                self.error = .unknown
            }
        }
    }

    /// Eğer iki hisse seçildiyse karşılaştırma verisini getirir
    func fetchCompareIfReady() {
        guard canCompare, let a = selectedCode1, let b = selectedCode2 else { return }
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                compareResult = try await repository.fetchCompareStocks(first: a, second: b)
            } catch CompareError.unauthorized {
                // 401: interceptor refresh denedi, başarısız olduysa sessionDidExpire
                // bildirimi gönderildi → kullanıcı login ekranına yönlendirilir.
                // Burada hata alert'i göstermiyoruz.
                compareResult = nil
            } catch let err as CompareError {
                self.error = err
                compareResult = nil
            } catch {
                self.error = .unknown
                compareResult = nil
            }
        }
    }

    /// Manuel karşılaştırma (örneğin butona bağlamak için)
    func compareSelected() {
        fetchCompareIfReady()
    }

    /// Hataları temizler
    func clearError() {
        error = nil
    }
}
