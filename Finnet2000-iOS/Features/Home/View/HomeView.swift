
import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            Text("🏠 Home")
                .font(.largeTitle.bold())
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
