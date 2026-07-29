import SwiftUI

struct TransparentNavigationBar: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .toolbarBackground(.hidden, for: .navigationBar)
        } else {
            content
        }
    }
}

extension View {
    func transparentNavigationBar() -> some View {
        self.modifier(TransparentNavigationBar())
    }
}
