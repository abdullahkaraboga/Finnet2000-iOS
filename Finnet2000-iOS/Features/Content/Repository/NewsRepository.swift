import Foundation

protocol ContentRepositoryProtocol {
	func fetchNews() async throws -> [NewsItem]
	func fetchArticles() async throws -> [ArticleItem]
	func fetchVideos() async throws -> [VideoItem]
}

final class NewsRepository: ContentRepositoryProtocol {
	private let base: String
	private let session: URLSession

	init(
		base: String = AppConfig.apiBaseURL + AppConfig.Endpoints.contentsBasePath,
		session: URLSession = .shared
	) {
		self.base = base
		self.session = session
	}

	func fetchNews() async throws -> [NewsItem] {
		let url = URL(string: "\(base)/GetNewsList")!
		let (data, _) = try await session.data(from: url)
		return try JSONDecoder().decode([NewsItem].self, from: data)
	}

	func fetchArticles() async throws -> [ArticleItem] {
		let url = URL(string: "\(base)/GetArticleContents")!
		let (data, _) = try await session.data(from: url)
		return try JSONDecoder().decode([ArticleItem].self, from: data)
	}

	func fetchVideos() async throws -> [VideoItem] {
		let url = URL(string: "\(base)/GetVideoContents")!
		let (data, _) = try await session.data(from: url)
		return try JSONDecoder().decode([VideoItem].self, from: data)
	}
}
