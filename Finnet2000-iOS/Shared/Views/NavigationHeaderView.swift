import SwiftUI

struct NavigationHeaderView: View {
	var onMenuTap: (() -> Void)? = nil
	var onNotificationTap: (() -> Void)? = nil
	var onSearchTap: (() -> Void)? = nil

	var body: some View {
		HStack(spacing: 16) {
			headerButton(systemName: "line.3.horizontal", action: onMenuTap)

			Spacer()

			Image("finnet2000_logo_dark")
				.resizable()
				.scaledToFit()
                .frame(width: 100, height: 40).padding(.leading,42)

			Spacer()

			HStack(spacing: 8) {
				headerButton(systemName: "bell.fill", action: onNotificationTap)
				headerButton(systemName: "magnifyingglass", action: onSearchTap)
			}
		}
		.padding(.horizontal, 16)
		.padding(.top, 10)
		.padding(.bottom, 12)
		.background(.clear)
		.frame(maxWidth: .infinity)
	}

	private func headerButton(systemName: String, action: (() -> Void)?) -> some View {
		Button(action: { action?() }) {
			Image(systemName: systemName)
				.font(.system(size: 20, weight: .semibold))
				.foregroundStyle(Color.primary)
				.frame(width: 45, height: 45)
		}
		.buttonStyle(.plain)
	}
}
