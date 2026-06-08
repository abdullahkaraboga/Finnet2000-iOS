import SwiftUI

struct NavigationHeaderView: View {
	var onMenuTap: (() -> Void)? = nil
	var onNotificationTap: (() -> Void)? = nil
	var onSearchTap: (() -> Void)? = nil

	var body: some View {
		HStack(spacing: 16) {
			headerButton(systemName: "line.3.horizontal", action: onMenuTap)

			Spacer(minLength: 12)

			Image("finnet2000_logo_light")
				.resizable()
				.scaledToFit()
				.frame(height: 45)

			Spacer(minLength: 12)

			HStack(spacing: 8) {
				headerButton(systemName: "bell.fill", action: onNotificationTap)
				headerButton(systemName: "magnifyingglass", action: onSearchTap)
			}
		}
		.padding(.horizontal, 16)
		.padding(.top, 10)
		.padding(.bottom, 12)
		.background(Color.black)
		.frame(maxWidth: .infinity)
	}

	private func headerButton(systemName: String, action: (() -> Void)?) -> some View {
		Button(action: { action?() }) {
			Image(systemName: systemName)
				.font(.system(size: 18, weight: .semibold))
				.foregroundStyle(Color.white)
				.frame(width: 40, height: 40)
				.background(Color.white.opacity(0.15), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
		}
		.buttonStyle(.plain)
	}
}
