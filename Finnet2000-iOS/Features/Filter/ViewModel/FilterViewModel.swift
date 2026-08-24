import Foundation
import Combine

@MainActor
class FilterViewModel: ObservableObject {
    @Published var filterChoices: FilterChoicesResponse?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // Selections
    @Published var selectedMarkets: Set<Int> = []
    @Published var selectedIndices: Set<Int> = []
    @Published var selectedSectors: Set<Int> = []
    
    // Range Filters Dictionary: Key is usually the ID of the ratio/financial or a custom string for hardcoded ones
    @Published var rangeFilters: [String: (min: String, max: String)] = [:]
    
    func fetchChoices() async {
        guard filterChoices == nil else { return }
        isLoading = true
        errorMessage = nil
        do {
            let response = try await FilterRepository.shared.fetchFilterChoices()
            self.filterChoices = response
        } catch {
            self.errorMessage = "Filtre seçenekleri yüklenemedi: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func toggleMarket(_ id: Int) {
        if selectedMarkets.contains(id) {
            selectedMarkets.remove(id)
        } else {
            selectedMarkets.insert(id)
        }
    }
    
    func toggleIndex(_ id: Int) {
        if selectedIndices.contains(id) {
            selectedIndices.remove(id)
        } else {
            selectedIndices.insert(id)
        }
    }
    
    func toggleSector(_ id: Int) {
        if selectedSectors.contains(id) {
            selectedSectors.remove(id)
        } else {
            selectedSectors.insert(id)
        }
    }
    
    func getRange(for key: String) -> (min: String, max: String) {
        return rangeFilters[key] ?? ("", "")
    }
    
    func updateRangeMin(for key: String, min: String) {
        var current = getRange(for: key)
        current.min = min
        rangeFilters[key] = current
    }
    
    func updateRangeMax(for key: String, max: String) {
        var current = getRange(for: key)
        current.max = max
        rangeFilters[key] = current
    }
    
    func clearFilters() {
        selectedMarkets.removeAll()
        selectedIndices.removeAll()
        selectedSectors.removeAll()
        rangeFilters.removeAll()
    }
}
