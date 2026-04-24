import SwiftUI

struct NavigationHeaderView: View {
	var onMenuTap: (() -> Void)? = nil
	var onSearchTap: (() -> Void)? = nil

	var body: some View {
		HStack(spacing: 16) {
			headerButton(systemName: "line.3.horizontal", action: onMenuTap)

			Spacer(minLength: 12)

			Text("finnet2000")
				.font(.system(size: 20, weight: .bold, design: .rounded))
				.foregroundStyle(Color.primary)
				.lineLimit(1)

			Spacer(minLength: 12)

			headerButton(systemName: "magnifyingglass", action: onSearchTap)
		}
		.padding(.horizontal, 16)
		.padding(.top, 10)
		.padding(.bottom, 12)
		.background(.ultraThinMaterial)
		.overlay(alignment: .bottom) {
			Divider()
		}
	}

	private func headerButton(systemName: String, action: (() -> Void)?) -> some View {
		Button(action: { action?() }) {
			Image(systemName: systemName)
				.font(.system(size: 18, weight: .semibold))
				.foregroundStyle(Color.primary)
				.frame(width: 40, height: 40)
				.background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
		}
		.buttonStyle(.plain)
	}
}
