// NewsItem.swift
import Foundation

struct NewsItem: Codable, Identifiable {
    let newsId: Int
    let newsDate: String
    let title: String
    let description: String
    let contentPath: String
    let coverImagePath: String
    let type: String
    let readingTime: Int
    let newsServiceId: Int?

    var id: Int { newsId }

    var date: Date? {
        ISO8601DateFormatter.f2000.date(from: newsDate)
    }
}

extension ISO8601DateFormatter {
    static let f2000: ISO8601DateFormatter = {
        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return fmt
    }()
}
