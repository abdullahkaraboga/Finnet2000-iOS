import Foundation
import Combine
import OSLog

@MainActor
final class StockLiveDataViewModel: ObservableObject {
    @Published var stockList: [StockData] = []
    @Published var stocks: [String: StockData] = [:]
    
    private let wsManager = StockWebSocketManager()
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Finnet2000", category: "StockLiveDataViewModel")
    
    init() {
        loadCachedData()
        setupBindings()
    }
    
    private func setupBindings() {
        wsManager.$stocks
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stocksDict in
                guard let self = self else { return }
                
                // Update our array based on the latest dictionary from the manager.
                // We'll preserve the existing order for items already in the list,
                // and append any new ones.
                
                var updatedList = self.stockList
                for (symbol, newStock) in stocksDict {
                    if let index = updatedList.firstIndex(where: { $0.symbol == symbol }) {
                        updatedList[index] = newStock
                    } else {
                        updatedList.append(newStock)
                    }
                }
                
                
                self.stockList = updatedList
                self.stocks = stocksDict
                self.saveToCache(list: updatedList)
            }
            .store(in: &cancellables)
    }
    
    private func loadCachedData() {
        guard let data = UserDefaults.standard.data(forKey: "cachedStockList") else { return }
        do {
            let cachedList = try JSONDecoder().decode([StockData].self, from: data)
            self.stockList = cachedList
            logger.debug("Cache loaded successfully with \(cachedList.count) items.")
        } catch {
            logger.error("Cache loading error: \(error.localizedDescription)")
        }
    }
    
    private func saveToCache(list: [StockData]) {
        do {
            let data = try JSONEncoder().encode(list)
            UserDefaults.standard.set(data, forKey: "cachedStockList")
        } catch {
            logger.error("Cache saving error: \(error.localizedDescription)")
        }
    }
    
    func connect() {
        Task {
            await StockLiveDataManager.shared.loginAndConnect(wsManager: wsManager)
        }
    }
    
    func disconnect() {
        wsManager.disconnect()
    }
    
    deinit {
        Task { @MainActor [wsManager] in
            wsManager.disconnect()
        }
    }
}
