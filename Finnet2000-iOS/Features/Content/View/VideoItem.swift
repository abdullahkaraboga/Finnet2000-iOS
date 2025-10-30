// VideoItem.swift
import Foundation

struct VideoItem: Codable, Identifiable {
    let date: String
    let type: String
    let title: String
    let description: String?
    let contentPath: String // YouTube ID olabilir
    let thumbnailPath: String?
    let androidTargetPath: String?
    let iosTargetPath: String?

    var id: String { "\(title)|\(contentPath)|\(date)" }

    var publishedAt: Date? {
        ISO8601DateFormatter.f2000.date(from: date) ?? {
            let fallback = ISO8601DateFormatter()
            fallback.formatOptions = [.withInternetDateTime]
            return fallback.date(from: date)
        }()
    }

    // Thumbnail boş ise YouTube ID’den üret
    var resolvedThumbnailURL: URL? {
        if let thumb = thumbnailPath, let url = URL(string: thumb) {
            return url
        }
        // contentPath bir YouTube video id’si ise
        if contentPath.count > 6 {
            return URL(string: "https://img.youtube.com/vi/\(contentPath)/hqdefault.jpg")
        }
        return nil
    }
}
