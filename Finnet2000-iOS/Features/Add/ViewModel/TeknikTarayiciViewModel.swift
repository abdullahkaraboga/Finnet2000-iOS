import Foundation
import Combine

@MainActor
final class TeknikTarayiciViewModel: ObservableObject {
    @Published private(set) var rows: [TeknikScannerResponseItem] = []
    
    // Filter Choices
    @Published private(set) var nationalIndices: [(id: Int, name: String)] = []
    @Published private(set) var sectoralIndices: [(id: Int, name: String)] = []
    @Published private(set) var sectors: [(id: Int, name: String)] = []
    
    // Selected Filter States
    @Published var selectedNationalIndices: Set<Int> = []
    @Published var selectedSectoralIndices: Set<Int> = []
    @Published var selectedSectors: Set<Int> = []
    
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    private let repository: TeknikTarayiciRepositoryProtocol
    
    init(repository: TeknikTarayiciRepositoryProtocol = TeknikTarayiciRepository()) {
        self.repository = repository
    }
    
    func loadSignals(analysisType: Int) {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        Task {
            defer { isLoading = false }
            do {
                let request = TeknikScannerRequest(
                    nationalIndicesIds: Array(selectedNationalIndices),
                    sectoralIndicesIds: Array(selectedSectoralIndices),
                    sectorIds: Array(selectedSectors),
                    analysisType: analysisType
                )
                self.rows = try await repository.fetchIndicatorSignals(request: request)
            } catch {
                print("TeknikScanner fetch error: \(error)")
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func loadChoices() {
        guard nationalIndices.isEmpty && sectoralIndices.isEmpty && sectors.isEmpty else { return }
        Task {
            do {
                let response = try await repository.fetchSignalStocksChoices()
                
                // Helper to map and sort dictionary safely
                func mapAndSort(_ dict: [String: String]?) -> [(id: Int, name: String)] {
                    guard let dict = dict else { return [] }
                    return dict.compactMap { key, value in
                        if let id = Int(key) {
                            return (id: id, name: value)
                        }
                        return nil
                    }.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
                }
                
                self.nationalIndices = mapAndSort(response.nationalIndices)
                self.sectoralIndices = mapAndSort(response.sectoralIndices)
                self.sectors = mapAndSort(response.sectors)
            } catch {
                print("Choices fetch error: \(error)")
            }
        }
    }
}
