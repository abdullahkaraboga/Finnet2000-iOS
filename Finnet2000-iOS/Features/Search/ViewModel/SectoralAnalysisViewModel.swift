import Foundation
import Combine

@MainActor
final class SectoralAnalysisViewModel: ObservableObject {
    @Published private(set) var sectors: [SectorRow] = []
    @Published private(set) var sectorList: [SectorListItem] = []
    @Published private(set) var sectorDetail: SectorAnalysisDetailData?
    @Published private(set) var isLoading = false
    @Published private(set) var isDetailLoading = false
    @Published private(set) var errorMessage: String?
    
    private let repository: SectoralAnalysisRepositoryProtocol
    
    init(repository: SectoralAnalysisRepositoryProtocol = SectoralAnalysisRepository()) {
        self.repository = repository
    }
    
    func loadSectors() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        Task {
            defer { isLoading = false }
            do {
                async let fetchSectors = repository.fetchSectors()
                async let fetchSectorList = repository.fetchSectorList()
                
                let (sectorsResponse, sectorListResponse) = try await (fetchSectors, fetchSectorList)
                self.sectors = self.mapToSectorRows(sectorsResponse.data)
                self.sectorList = sectorListResponse.data

            } catch {
                print("Sector fetch error: \(error)")
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func loadSectorDetail(sectorName: String) {
        guard !isDetailLoading else { return }
        isDetailLoading = true
        errorMessage = nil
        
        Task {
            defer { isDetailLoading = false }
            do {
                let response = try await repository.fetchSectorDetail(sectorName: sectorName)
                self.sectorDetail = response.data
            } catch {
                print("Sector detail fetch error: \(error)")
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func mapToSectorRows(_ data: [String: [SectorIndicator]]) -> [SectorRow] {
        var rows: [SectorRow] = []
        for (sectorName, indicators) in data {
            var aktifKarlilik: Double = 0
            var pdDd: Double = 0
            var fdFavok: Double = 0
            var roic: Double = 0
            var ozserKarlilik: Double = 0
            var fiyatKazanc: Double = 0
            
            for indicator in indicators {
                let val = indicator.value ?? 0
                switch indicator.name {
                case "Aktif Karlılık": aktifKarlilik = val
                case "PD / DD": pdDd = val
                case "Firma Değeri / FAVÖK": fdFavok = val
                case "ROIC": roic = val
                case "Özsermaye Karlılığı": ozserKarlilik = val
                case "Fiyat Kazanç": fiyatKazanc = val
                default: break
                }
            }
            
            let row = SectorRow(
                sektor: sectorName,
                aktifKarlilik: aktifKarlilik,
                pdDd: pdDd,
                fdFavok: fdFavok,
                roic: roic,
                ozserKarlilik: ozserKarlilik,
                fiyatKazanc: fiyatKazanc
            )
            rows.append(row)
        }
        return rows.sorted { $0.sektor < $1.sektor }
    }
}
