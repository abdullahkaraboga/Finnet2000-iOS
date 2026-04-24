// StockListItem.swift
import Foundation

struct StockListItem: Decodable, Identifiable, Hashable, Sendable {
    let code: String
    let logoPath: String

    var id: String { code }

    private enum CodingKeys: String, CodingKey {
        case code
        case logoPath
    }

    // Ensure Decodable conformance is not actor-isolated
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try container.decode(String.self, forKey: .code)
        self.logoPath = try container.decode(String.self, forKey: .logoPath)
    }
}
