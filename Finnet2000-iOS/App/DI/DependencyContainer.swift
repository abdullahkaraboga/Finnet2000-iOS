import Foundation

final class DependencyContainer {
	static let shared = DependencyContainer()

	private init() {}

	lazy var authRepository: AuthRepositoryProtocol = AuthRepository()
	lazy var homeRepository: HomeRepositoryProtocol = HomeRepository()
	lazy var contentRepository: ContentRepositoryProtocol = NewsRepository()

	func makeAuthViewModel() -> AuthViewModel {
		AuthViewModel(repository: authRepository)
	}

	func makeHomeViewModel() -> HomeViewModel {
		HomeViewModel(repository: homeRepository)
	}

	func makeNewsListViewModel() -> NewsListViewModel {
		NewsListViewModel(repository: contentRepository)
	}

	func makeArticlesListViewModel() -> ArticlesListViewModel {
		ArticlesListViewModel(repository: contentRepository)
	}

	func makeVideosListViewModel() -> VideosListViewModel {
		VideosListViewModel(repository: contentRepository)
	}
}
