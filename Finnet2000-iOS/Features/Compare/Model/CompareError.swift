
//
//  CompareError.swift
//  Finnet2000-iOS
//
//  Created by Karaboğa on 10/31/25.
//

import Foundation

/// Hata yönetimi için özel domain hataları
enum CompareError: LocalizedError {
    case networkError(String)
    case decodingError(String)
    case emptyResponse
    case sameStocksSelected
    case unauthorized  // 401 — session interceptor tarafından yönetilir, kullanıcıya gösterilmez
    case unknown

    var errorDescription: String? {
        switch self {
        case .networkError(let msg): return "Ağ hatası: \(msg)"
        case .decodingError(let msg): return "Veri çözümlenemedi: \(msg)"
        case .emptyResponse: return "Boş yanıt alındı."
        case .sameStocksSelected: return "Aynı hisse kodları seçilemez."
        case .unauthorized: return nil
        case .unknown: return "Bilinmeyen bir hata oluştu."
        }
    }
}
