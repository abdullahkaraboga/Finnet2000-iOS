@MainActor
final class HomeViewModel: ObservableObject {

    @Published var data: HomePageResponse?
    @Published var isLoading = false

    private let repository = HomeRepository()

    func fetch() {
        Task {
            isLoading = true
            defer { isLoading = false }

            do {
                data = try await repository.fetchHomePage()
            } catch {
                print(error)
            }
        }
    }
}
