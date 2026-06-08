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

    private var normalizedContentPath: String {
        contentPath.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// API sadece video ID dondugunde watch URL'sini uygulama tarafinda uretir.
    var youtubeWatchURL: URL? {
        guard let videoID = youtubeVideoID else { return nil }
        return URL(string: "https://www.youtube.com/watch?v=\(videoID)")
    }

    var youtubeVideoID: String? {
        let raw = normalizedContentPath
        if raw.isEmpty { return nil }

        // Yeni API cevabi sadece video ID olabiliyor.
        if !raw.contains("/") && !raw.contains(".") {
            return raw.count >= 6 ? raw : nil
        }

        if let url = URL(string: raw), let host = url.host?.lowercased() {
            if host.contains("youtu.be") {
                let id = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
                return id.isEmpty ? nil : id
            }

            if host.contains("youtube.com") {
                if url.path.contains("/embed/") {
                    let id = url.path.replacingOccurrences(of: "/embed/", with: "")
                        .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
                    return id.isEmpty ? nil : id
                }

                if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                   let id = components.queryItems?.first(where: { $0.name == "v" })?.value,
                   !id.isEmpty {
                    return id
                }
            }
        }

        return nil
    }

    // Thumbnail boş ise YouTube ID’den üret
    var resolvedThumbnailURL: URL? {
        if let thumb = thumbnailPath, let url = URL(string: thumb) {
            return url
        }
        if let videoID = youtubeVideoID {
            return URL(string: "https://img.youtube.com/vi/\(videoID)/hqdefault.jpg")
        }
        return nil
    }
}
