import SwiftUI

struct TabBarView: View {
    @State private var selectedTab: TabItem = .home
    var onLogout: (() -> Void)? = nil

    var body: some View {
        TabView(selection: $selectedTab) {
            tabRoot {
                HomeView()
            }
                .tabItem { Label("Ana Sayfa", systemImage: "house.fill") }
                .tag(TabItem.home)

            tabRoot {
                NewsView()
            }
                .tabItem { Label("News", systemImage: "newspaper.fill") }
                .tag(TabItem.news)

            tabRoot {
                AddView()
            }
                .tabItem { Label("Menu", systemImage: "line.3.horizontal") }
                .tag(TabItem.add)

            tabRoot {
                ListsView()
            }
                .tabItem { Label("Lists", systemImage: "list.bullet.rectangle.fill") }
                .tag(TabItem.lists)

            tabRoot {
                CompareView()
            }
                .tabItem { Label("Compare", systemImage: "arrow.left.arrow.right") }
                .tag(TabItem.compare)
        }
        .tint(.blue)
    }

    private func tabRoot<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            NavigationHeaderView(
                onMenuTap: {
                    // Placeholder: side menu akışı bağlanacak.
                },
                onSearchTap: {
                    // Placeholder: global search akışı bağlanacak.
                }
            )
            content()
        }
        .edgesIgnoringSafeArea(.top)
    }
}

enum TabItem: Hashable {
    case home, news, add, lists, compare
}
