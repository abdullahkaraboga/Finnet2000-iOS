
import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {

    @Published var data: HomePageResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let repository: HomeRepositoryProtocol
    private var fetchTask: Task<Void, Never>?

    init(repository: HomeRepositoryProtocol = HomeRepository()) {
        self.repository = repository
    }

    func fetch() {
        guard !isLoading else { return }
        fetchTask?.cancel()
        fetchTask = Task {
            isLoading = true
            defer { isLoading = false }

            do {
                data = try await repository.fetchHomePage(currency: "TRY")
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
