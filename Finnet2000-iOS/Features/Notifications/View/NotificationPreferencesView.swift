import SwiftUI

private let notifGreen = Color(red: 0.161, green: 0.749, blue: 0.451)

struct NotificationPreferencesView: View {

    @StateObject private var viewModel = NotificationPreferencesViewModel()
    @State private var alertInfo: NotificationAlertInfo? = nil
    @State private var showSavedToast: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                // MARK: - Category Sections
                ForEach(viewModel.categories.indices, id: \.self) { categoryIndex in
                    categorySection(categoryIndex: categoryIndex)
                }

                // MARK: - Save Button
                Button(action: {
                    viewModel.save()
                    withAnimation {
                        showSavedToast = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation { showSavedToast = false }
                    }
                }) {
                    Text("Kaydet")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(notifGreen)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Bildirim Tercihleri")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: { viewModel.selectAll() }) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                }
                Button(action: { viewModel.deselectAll() }) {
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                }
            }
        }
        .alert(item: $alertInfo) { info in
            Alert(
                title: Text(info.title),
                message: Text(info.message),
                dismissButton: .default(Text("Tamam"))
            )
        }
        .overlay(alignment: .bottom) {
            if showSavedToast {
                toastView
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 24)
            }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private func categorySection(categoryIndex: Int) -> some View {
        let category = viewModel.categories[categoryIndex]

        VStack(alignment: .leading, spacing: 0) {

            // Section Header
            HStack(spacing: 5) {
                Text(category.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)

                Button(action: {
                    alertInfo = NotificationAlertInfo(
                        title: category.title,
                        message: category.description
                    )
                }) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 13))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                }
                .buttonStyle(.plain)

                Spacer()
            }
            .padding(.horizontal, 32)
            .padding(.top, 22)
            .padding(.bottom, 7)

            // Items Card
            VStack(spacing: 0) {
                ForEach(category.items.indices, id: \.self) { itemIndex in
                    let item = category.items[itemIndex]
                    let isLast = itemIndex == category.items.count - 1

                    HStack(spacing: 6) {
                        Text(item.title)
                            .font(.system(size: 15))
                            .foregroundColor(.primary)

                        Button(action: {
                            alertInfo = NotificationAlertInfo(
                                title: item.title,
                                message: item.description
                            )
                        }) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 13))
                                .foregroundColor(Color(UIColor.tertiaryLabel))
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        Toggle("", isOn: $viewModel.categories[categoryIndex].items[itemIndex].isEnabled)
                            .labelsHidden()
                            .tint(notifGreen)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.categories[categoryIndex].items[itemIndex].isEnabled.toggle()
                    }

                    if !isLast {
                        Divider()
                            .padding(.leading, 16)
                    }
                }
            }
            .background(Color(UIColor.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.horizontal, 16)
        }
    }

    private var toastView: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(notifGreen)
            Text("Tercihleriniz kaydedildi")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        NotificationPreferencesView()
    }
}
