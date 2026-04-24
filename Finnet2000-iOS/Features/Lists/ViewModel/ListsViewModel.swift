import Foundation
import Combine
import Alamofire

@MainActor
final class ListsViewModel: ObservableObject {
    // Favoriler
    @Published var stocks: [FavouriteStock] = []
    @Published var robofunds: [FavouriteRobofund] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // Portföyler
    @Published var portfolios: [UserPortfolio] = []
    @Published var isLoadingPortfolios: Bool = false
    @Published var errorMessagePortfolios: String?

    private let repository = ListsRepository()

    func loadFavourites() {
        isLoading = true
        errorMessage = nil

        repository.getFavouriteList { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                switch result {
                case .success(let data):
                    self.stocks = data.stocks
                    self.robofunds = data.robofunds
                case .failure(let error):
                    // 401 → interceptor sessionDidExpire ile yönetir; kullanıcıya gösterme
                    if let statusCode = error.responseCode, statusCode == 401 { return }
                    self.errorMessage = "Veriler alınamadı: \(error.localizedDescription)"
                }
            }
        }
    }

    func loadPortfolios() {
        isLoadingPortfolios = true
        errorMessagePortfolios = nil

        repository.getUserPortfolios { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoadingPortfolios = false

                switch result {
                case .success(let items):
                    self.portfolios = items
                case .failure(let error):
                    // 401 → interceptor sessionDidExpire ile yönetir; kullanıcıya gösterme
                    if let statusCode = error.responseCode, statusCode == 401 { return }
                    self.errorMessagePortfolios = "Portföyler alınamadı: \(error.localizedDescription)"
                }
            }
        }
    }
}

