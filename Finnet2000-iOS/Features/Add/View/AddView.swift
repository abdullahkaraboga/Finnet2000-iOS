import SwiftUI

struct AddView: View {
    private let menuItems: [(title: String, icon: String)] = [
        ("Filtreleme", "line.3.horizontal.decrease.circle"),
        ("Sektörel Analiz", "chart.pie"),
        ("Teknik Tarayıcı", "magnifyingglass.circle"),
    ]

    var body: some View {
        NavigationStack {
            List {
                ForEach(menuItems, id: \.title) { item in
                    NavigationLink(destination: EmptyView()) {
                        HStack(spacing: 14) {
                            Image(systemName: item.icon)
                                .foregroundStyle(.blue)
                                .frame(width: 28)
                            Text(item.title)
                                .font(.body)
                            Spacer()
                                .foregroundStyle(.secondary)
                                .font(.caption.weight(.semibold))
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                }
            }
            .listStyle(.insetGrouped)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
