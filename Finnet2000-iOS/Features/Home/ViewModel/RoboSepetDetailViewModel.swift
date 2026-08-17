import Foundation
import Combine
import Alamofire

@MainActor
final class RoboSepetDetailViewModel: ObservableObject {
    @Published var detail: RoboSepetDetailResponse?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let repository = HomeRepository()
    
    func fetchRoboSepetDetail(portfolioId: Int) {
        isLoading = true
        errorMessage = nil
        
        repository.getRoboSepetDetail(portfolioId: portfolioId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let apiResponse):
                    self.detail = apiResponse
                case .failure(let error):
                    if let statusCode = error.responseCode, statusCode == 401 {
                        // 401 interceptor tarafından ele alınır
                        return
                    }
                    // For now, if the API call fails, we can fall back to the mock data for demonstration
                    // self.detail = .mock 
                    self.errorMessage = "RoboSepet detayı alınamadı: \(error.localizedDescription)"
                }
            }
        }
    }
}
