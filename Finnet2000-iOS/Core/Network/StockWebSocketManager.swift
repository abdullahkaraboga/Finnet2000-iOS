import Foundation
import Combine
import OSLog
import Starscream

// MARK: - StockWebSocketManager

/// Starscream tabanlı WebSocket yöneticisi.
/// URLSession'ın katı handshake kuralları yerine Starscream kullanır (OkHttp gibi esnek).
@MainActor
final class StockWebSocketManager: ObservableObject {

    // MARK: - Logger

    private static let log = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Finnet2000", category: "WebSocket")

    private func wsLog(_ msg: String) {
        Self.log.debug("\(msg, privacy: .public)")
        print("[WS] \(msg)")
    }

    // MARK: - Constants

    static let indexCodes: [String] = [
        "XU100", "XU050", "XU030", "XUTUM", "XUSIN", "XBANK", "XTMTU", "XUTEK",
        "XU500", "XKTUM", "XK100", "XK050", "XK030", "XSRDK", "XSD25", "XKTMT",
        "XUHIZ", "XELKT", "XULAS", "XTRZM", "XTCRT", "XILTM", "XGIDA", "XMESY",
        "XUMAL", "XSGRT", "XFINK", "XHOLD", "XGMYO", "XBLSM", "XYORT", "XSPOR"
    ]

    private static let wsURLString = "wss://api.finnet2000.com/live_data/ws"
    private static let reconnectBaseDelaySeconds: Double = 1
    private static let reconnectMaxDelaySeconds: Double = 30

    // MARK: - Published state

    @Published private(set) var stocks: [String: StockData] = [:]
    @Published private(set) var isConnected: Bool = false
    @Published private(set) var lastError: String?

    // MARK: - Private

    private var socket: WebSocket?
    private var reconnectTask: Task<Void, Never>?
    private var userInitiatedDisconnect = false
    private var reconnectAttempt = 0
    private var messageCount = 0
    private var connectTime: Date?

    // MARK: - Lifecycle

    func connect() {
        userInitiatedDisconnect = false
        reconnectTask?.cancel()
        reconnectTask = nil

        if ((socket?.connect()) != nil) == true {
            wsLog("connect() atlandı: zaten bağlı")
            return
        }

        wsLog("connect() başlatıldı")
        openSocket()
    }

    func disconnect() {
        wsLog("disconnect() çağrıldı (kullanıcı isteği)")
        userInitiatedDisconnect = true
        reconnectTask?.cancel()
        reconnectTask = nil
        socket?.disconnect()
        socket = nil
        isConnected = false
    }

    // MARK: - Private

    private func openSocket() {
        guard let url = URL(string: Self.wsURLString) else { return }
        wsLog("Socket açılıyor → URL: \(Self.wsURLString)")

        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        if let accessToken = TokenManager.shared.accessToken, !accessToken.isEmpty {
            request.setValue("Access-Token, \(accessToken)", forHTTPHeaderField: "Sec-WebSocket-Protocol")
        } else {
            request.setValue("Access-Token", forHTTPHeaderField: "Sec-WebSocket-Protocol")
        }

        let ws = WebSocket(request: request)
        ws.delegate = self
        socket = ws
        connectTime = Date()
        lastError = nil
        ws.connect()
    }

    private func sendSubscribe() {
        let message = StockSubscribeMessage(codes: Self.indexCodes)
        guard let data = try? JSONEncoder().encode(message),
              let text = String(data: data, encoding: .utf8) else {
            wsLog("HATA: Subscribe mesajı encode edilemedi")
            return
        }
        wsLog("Subscribe gönderiliyor → \(text)")
        socket?.write(string: text)
    }

    private func processMessage(text: String) {
        messageCount += 1
        wsLog("Mesaj #\(messageCount) alındı → \(text)")

        guard let data = text.data(using: .utf8) else { return }

        if let stock = try? JSONDecoder().decode(StockData.self, from: data) {
            applyStock(stock, rawText: text)
            return
        }

        if let stockArray = try? JSONDecoder().decode([StockData].self, from: data) {
            stockArray.forEach { applyStock($0, rawText: text) }
            return
        }

        if let object = try? JSONSerialization.jsonObject(with: data),
           let extractedStocks = extractStocks(from: object),
           !extractedStocks.isEmpty {
            extractedStocks.forEach { applyStock($0, rawText: text) }
            return
        }

        wsLog("HATA: JSON parse başarısız → ham: \(text)")
    }

    private func applyStock(_ stock: StockData, rawText: String) {
        if let symbol = stock.symbol, !symbol.isEmpty {
            wsLog("Parse OK → \(symbol) | last: \(stock.last.map { String($0) } ?? "nil") | dailyClose: \(stock.dailyClose.map { String($0) } ?? "nil")")
            stocks[symbol] = stock
        } else {
            wsLog("UYARI: Symbol nil/boş → JSON: \(rawText)")
        }
    }

    private func extractStocks(from object: Any) -> [StockData]? {
        if let stock = decodeStockData(from: object) { return [stock] }

        if let array = object as? [Any] {
            let decoded = array.compactMap { decodeStockData(from: $0) }
            return decoded.isEmpty ? nil : decoded
        }

        if let dict = object as? [String: Any] {
            for key in ["data", "Data", "payload", "Payload", "result", "Result", "message", "Message"] {
                if let nested = dict[key], let decoded = extractStocks(from: nested), !decoded.isEmpty {
                    return decoded
                }
            }
        }
        return nil
    }

    private func decodeStockData(from object: Any) -> StockData? {
        guard JSONSerialization.isValidJSONObject(object),
              let data = try? JSONSerialization.data(withJSONObject: object) else { return nil }
        return try? JSONDecoder().decode(StockData.self, from: data)
    }

    private func handleDisconnect(reason: String) {
        if userInitiatedDisconnect {
            wsLog("Bağlantı kapandı (kullanıcı isteği), reconnect yapılmayacak")
            isConnected = false
            return
        }

        let uptime = connectTime.map { Date().timeIntervalSince($0) }.map { String(format: "%.1f", $0) } ?? "?"
        wsLog("handleDisconnect — reason: \(reason) | uptime: \(uptime)s | toplam mesaj: \(messageCount)")
        lastError = reason
        isConnected = false
        socket = nil
        scheduleReconnect()
    }

    private func scheduleReconnect() {
        reconnectTask?.cancel()

        let delay = min(
            Self.reconnectMaxDelaySeconds,
            Self.reconnectBaseDelaySeconds * pow(2, Double(reconnectAttempt))
        )
        reconnectAttempt = min(reconnectAttempt + 1, 8)
        wsLog("\(String(format: "%.1f", delay)) saniye sonra yeniden bağlanılacak")

        reconnectTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            guard let self, !Task.isCancelled, !self.userInitiatedDisconnect else { return }
            self.wsLog("Yeniden bağlanıyor...")
            self.openSocket()
        }
    }
}

// MARK: - WebSocketDelegate

extension StockWebSocketManager: WebSocketDelegate {

    nonisolated func didReceive(event: WebSocketEvent, client: any WebSocketClient) {
        switch event {
        case .connected(let headers):
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.wsLog("Bağlantı kuruldu | headers: \(headers)")
                self.reconnectAttempt = 0
                self.isConnected = true
                self.lastError = nil
                self.sendSubscribe()
            }

        case .disconnected(let reason, let code):
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.wsLog("Bağlantı kapandı | reason: \(reason) | code: \(code)")
                self.handleDisconnect(reason: "disconnected: \(reason) (code: \(code))")
            }

        case .text(let text):
            Task { @MainActor [weak self] in
                self?.processMessage(text: text)
            }

        case .binary(let data):
            if let text = String(data: data, encoding: .utf8) {
                Task { @MainActor [weak self] in
                    self?.processMessage(text: text)
                }
            }

        case .error(let error):
            let desc = error?.localizedDescription ?? "unknown"
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.wsLog("HATA: \(desc)")
                self.handleDisconnect(reason: desc)
            }

        case .cancelled:
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.wsLog("Socket iptal edildi")
                self.handleDisconnect(reason: "cancelled")
            }

        case .ping, .pong, .viabilityChanged, .reconnectSuggested, .peerClosed:
            break
        }
    }
}
