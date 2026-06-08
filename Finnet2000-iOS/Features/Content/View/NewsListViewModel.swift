// NewsListViewModel.swift
import Foundation
import Combine

@MainActor
final class NewsListViewModel: ObservableObject {
    @Published var items: [NewsItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let repository: ContentRepositoryProtocol

    init(repository: ContentRepositoryProtocol = NewsRepository()) {
        self.repository = repository
    }

    func load() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let result = try await repository.fetchNews()
                self.items = result.sorted { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }
}
