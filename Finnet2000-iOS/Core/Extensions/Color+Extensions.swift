//
//  Color+Extensions.swift
//  Finnet2000-iOS
//
//  Created by Karaboğa on 10/31/25.
//

import SwiftUI

extension Color {
    static let midGreen = Color(light: UIColor(red: 0.18, green: 0.72, blue: 0.40, alpha: 1.0),
                                dark: UIColor(red: 0.22, green: 0.80, blue: 0.45, alpha: 1.0))
    
    static let signalAl = Color(light: UIColor(red: 0.18, green: 0.72, blue: 0.40, alpha: 1.0),
                                 dark: UIColor(red: 0.22, green: 0.80, blue: 0.45, alpha: 1.0))
    
    static let signalSat = Color(light: UIColor.systemRed,
                                 dark: UIColor(red: 1.0, green: 0.35, blue: 0.35, alpha: 1.0))

    static let appBackground = Color(UIColor.systemGroupedBackground)
    static let primaryBackground = Color(UIColor.systemBackground)
    static let secondaryBackground = Color(UIColor.secondarySystemGroupedBackground)

    init(light: UIColor, dark: UIColor) {
        self.init(UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }
}
