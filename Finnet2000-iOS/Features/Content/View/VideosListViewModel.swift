// VideosListViewModel.swift
import Foundation
import Combine

@MainActor
final class VideosListViewModel: ObservableObject {
    @Published var items: [VideoItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let result = try await ContentsAPIService.shared.fetchVideos()
                self.items = result.sorted { ($0.publishedAt ?? .distantPast) > ($1.publishedAt ?? .distantPast) }
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }
}
