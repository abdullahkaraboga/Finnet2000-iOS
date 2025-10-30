// ContentsAPIService.swift
import Foundation

final class ContentsAPIService {
    static let shared = ContentsAPIService()
    private init() {}

    private let base = "https://api.finnet2000.com/api/Contents"

    private var jsonDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        // ISO8601 bazı yanıtlar milisaniyeli, bazıları milisaniyesiz gelebiliyor.
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let str = try container.decode(String.self)
            if let d = isoFormatter.date(from: str) {
                return d
            }
            // milisaniyesiz fallback
            let fallback = ISO8601DateFormatter()
            fallback.formatOptions = [.withInternetDateTime]
            if let d2 = fallback.date(from: str) {
                return d2
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid ISO8601 date: \(str)")
        }
        return decoder
    }

    func fetchNews() async throws -> [NewsItem] {
        let url = URL(string: "\(base)/GetNewsList")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([NewsItem].self, from: data)
    }

    func fetchArticles() async throws -> [ArticleItem] {
        let url = URL(string: "\(base)/GetArticleContents")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([ArticleItem].self, from: data)
    }

    func fetchVideos() async throws -> [VideoItem] {
        let url = URL(string: "\(base)/GetVideoContents")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([VideoItem].self, from: data)
    }
}
