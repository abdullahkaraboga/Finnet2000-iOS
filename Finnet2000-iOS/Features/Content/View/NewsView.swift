import SwiftUI

struct NewsView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("İçerik", selection: $selectedTab) {
                    Text("Haberler").tag(0)
                    Text("Videolar").tag(1)
                    Text("Makaleler").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top)

                Divider()

                Group {
                    switch selectedTab {
                    case 0:
                        NewsListView()
                    case 1:
                        VideosListView()
                    default:
                        ArticlesListView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
