import Foundation
import Combine
import Alamofire

@MainActor
final class PortfolioDetailViewModel: ObservableObject {
    @Published var detail: PortfolioDetailResponse?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let repository = ListsRepository()
    
    func fetchPortfolioDetail(portfolioId: Int) {
        isLoading = true
        errorMessage = nil
        
        repository.getPortfolioDetail(portfolioId: portfolioId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let apiResponse):
                    // toPortfolioDetailResponse methodu API response'u display model'e dönüştürür
                    self.detail = apiResponse.toPortfolioDetailResponse(portfolioId: portfolioId)
                case .failure(let error):
                    if let statusCode = error.responseCode, statusCode == 401 {
                        // 401 interceptor tarafından ele alınır
                        return
                    }
                    self.errorMessage = "Portföy detayı alınamadı: \(error.localizedDescription)"
                }
            }
        }
    }
}
