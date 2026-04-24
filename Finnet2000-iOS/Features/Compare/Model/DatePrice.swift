//
//  DatePrice.swift
//  Finnet2000-iOS
//
//  Created by Karaboğa on 10/31/25.
//

import Foundation

/// Günlük fiyat verileri (örneğin tarih-günlük fiyat grafiği için)
struct DatePrice: Decodable, Sendable {
    let date: String
    let close: Double

    private enum CodingKeys: String, CodingKey { case date, close }

    nonisolated init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        date = try c.decodeIfPresent(String.self, forKey: .date) ?? ""
        close = try c.decodeIfPresent(Double.self, forKey: .close) ?? 0.0
    }
}
