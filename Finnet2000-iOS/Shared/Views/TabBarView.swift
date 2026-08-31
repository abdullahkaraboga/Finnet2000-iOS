import SwiftUI

struct TabBarView: View {
    private let dependencyContainer: DependencyContainer
    @State private var selectedTab: TabItem = .home
    @State private var isDrawerPresented = false
    @State private var isSearchActive = false
    @State private var navigateToAgreements = false
    @State private var navigateToNotifications = false
    @State private var navigateToNotificationsInbox = false
    @State private var navigateToAccountInfo = false
    @State private var navigateToPriceAlarms = false
    @State private var navigateToMatriksBridge = false
    @AppStorage("isDarkModeEnabled") private var isDarkModeEnabled = false
    var onLogout: (() -> Void)?

    init(dependencyContainer: DependencyContainer = .shared, onLogout: (() -> Void)? = nil) {
        self.dependencyContainer = dependencyContainer
        self.onLogout = onLogout
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .leading) {
                TabView(selection: $selectedTab) {
                    tabRoot {
                        HomeView(viewModel: dependencyContainer.makeHomeViewModel())
                    }
                        .tabItem { Label("Ana Sayfa", systemImage: "house.fill") }
                        .tag(TabItem.home)

                    tabRoot {
                        NewsView()
                    }
                        .tabItem { Label("Haberler", systemImage: "newspaper.fill") }
                        .tag(TabItem.news)

                    tabRoot {
                        AddView()
                    }
                        .tabItem { Label("Tarayıcı", systemImage: "line.3.horizontal") }
                        .tag(TabItem.add)

                    tabRoot {
                        ListsView()
                    }
                        .tabItem { Label("Listeler", systemImage: "list.bullet.rectangle.fill") }
                        .tag(TabItem.lists)

                    tabRoot {
                        CompareView()
                    }
                        .tabItem { Label("Karşılaştır", systemImage: "arrow.left.arrow.right") }
                        .tag(TabItem.compare)
                }
                .tint(.blue)
                .disabled(isDrawerPresented)
                .animation(nil, value: selectedTab)

                if isDrawerPresented {
                    Color.black.opacity(0.18)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .onTapGesture {
                            closeDrawer()
                        }

                    SideDrawerView(
                        isPresented: $isDrawerPresented,
                        isDarkModeEnabled: $isDarkModeEnabled,
                        onLogout: onLogout,
                        onAccountInfoTap: { navigateToAccountInfo = true },
                        onAgreementsTap: { navigateToAgreements = true },
                        onNotificationsTap: { navigateToNotifications = true },
                        onPriceAlarmsTap: { navigateToPriceAlarms = true },
                        onMatriksBridgeTap: { navigateToMatriksBridge = true }
                    )
                    .transition(.move(edge: .leading).combined(with: .opacity))
                }
            }
            .navigationDestination(isPresented: $isSearchActive) {
                SearchView()
            }
            .navigationDestination(isPresented: $navigateToAgreements) {
                UserAgreementsView()
            }
            .navigationDestination(isPresented: $navigateToAccountInfo) {
                AccountInfoView()
            }
            .navigationDestination(isPresented: $navigateToPriceAlarms) {
                PriceAlarmsView()
            }
            .navigationDestination(isPresented: $navigateToNotifications) {
                NotificationPreferencesView()
            }
            .navigationDestination(isPresented: $navigateToNotificationsInbox) {
                NotificationsInboxView()
            }
            .navigationDestination(isPresented: $navigateToMatriksBridge) {
                MatriksBridgeView(postAuthDestination: .tradeMenu)
            }
        }
        .animation(.interactiveSpring(response: 0.32, dampingFraction: 0.84), value: isDrawerPresented)
        .preferredColorScheme(isDarkModeEnabled ? .dark : .light)
        .toolbar(.hidden, for: .navigationBar)
    }

    private func tabRoot<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            NavigationHeaderView(
                onMenuTap: {
                    isDrawerPresented = true
                },
                onNotificationTap: {
                    navigateToNotificationsInbox = true
                },
                onSearchTap: {
                    isSearchActive = true
                }
            )
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func closeDrawer() {
        isDrawerPresented = false
    }
}

enum TabItem: Hashable, CaseIterable {
    case home, news, add, lists, compare

    var title: String {
        switch self {
        case .home:
            return "Ana Sayfa"
        case .news:
            return "Haberler"
        case .add:
            return "Tarayıcı"
        case .lists:
            return "Listelerim"
        case .compare:
            return "Karşılaştırma"
        }
    }

    var subtitle: String {
        switch self {
        case .home:
            return "Piyasa özeti ve canlı akış"
        case .news:
            return "Güncel finans içerikleri"
        case .add:
            return "Filtreleme ve keşif"
        case .lists:
            return "Takip ettiğiniz hisseler"
        case .compare:
            return "Şirketleri yan yana inceleyin"
        }
    }

    var systemImage: String {
        switch self {
        case .home:
            return "house.fill"
        case .news:
            return "newspaper.fill"
        case .add:
            return "line.3.horizontal.decrease.circle.fill"
        case .lists:
            return "list.bullet.rectangle.portrait.fill"
        case .compare:
            return "arrow.left.arrow.right.circle.fill"
        }
    }
}

