// ArticleItem.swift
import Foundation

struct ArticleItem: Codable, Identifiable {
    let date: String
    let type: String
    let title: String
    let description: String?
    let contentPath: String
    let thumbnailPath: String?
    let androidTargetPath: String?
    let iosTargetPath: String?

    // Identifiable için stabil id üretimi (başlık + tarih)
    var id: String { "\(title)|\(date)" }

    var publishedAt: Date? {
        ISO8601DateFormatter.f2000.date(from: date) ?? {
            let fallback = ISO8601DateFormatter()
            fallback.formatOptions = [.withInternetDateTime]
            return fallback.date(from: date)
        }()
    }
}
