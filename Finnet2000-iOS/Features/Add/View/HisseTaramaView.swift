import SwiftUI

struct HisseTaramaView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMainTab: MainTab = .listeler
    @State private var selectedListeTab: ListeSubTab = .listelerim

    enum MainTab: String, CaseIterable {
        case listeler  = "Listeler"
        case tarayici  = "Tarayıcı"
    }

    enum ListeSubTab: String, CaseIterable {
        case listelerim    = "Listelerim"
        case ornekListeler = "Örnek Listeler"
    }

    var body: some View {
        VStack(spacing: 0) {
            navBar
            mainTabBar

            if selectedMainTab == .listeler {
                listeSubTabBar
                listeContent
            } else {
                tarayiciContent
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarHidden(true)
    }

    // MARK: - Navigation Bar

    private var navBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)

            Spacer()

            Text("Hisse Tarama")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)

            Spacer()

            Button {} label: {
                Image(systemName: "info.circle")
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .background(Color.black.ignoresSafeArea(edges: .top))
    }

    // MARK: - Main Tab Bar

    private var mainTabBar: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.18)) { selectedMainTab = tab }
                } label: {
                    VStack(spacing: 0) {
                        Text(tab.rawValue)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                        Rectangle()
                            .fill(selectedMainTab == tab ? Color.midGreen : Color.clear)
                            .frame(height: 2)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .background(Color(.systemBackground))
        .overlay(alignment: .bottom) { Divider() }
    }

    // MARK: - Liste Sub Tab Bar

    private var listeSubTabBar: some View {
        HStack(spacing: 0) {
            ForEach(ListeSubTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.18)) { selectedListeTab = tab }
                } label: {
                    VStack(spacing: 0) {
                        Text(tab.rawValue)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(selectedListeTab == tab ? Color.midGreen : .secondary)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                        Rectangle()
                            .fill(selectedListeTab == tab ? Color.midGreen : Color.clear)
                            .frame(height: 1.5)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .background(Color(.systemBackground))
        .overlay(alignment: .bottom) { Divider() }
    }

    // MARK: - Liste Content

    private var listeContent: some View {
        VStack {
            Spacer().frame(height: 32)
            newListButton
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Tarayıcı Content

    private var tarayiciContent: some View {
        VStack {
            Spacer().frame(height: 32)
            newListButton
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Shared

    private var newListButton: some View {
        Button {} label: {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .semibold))
                Text("Yeni Liste Oluştur")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(.primary)
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.midGreen, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HisseTaramaView()
}
