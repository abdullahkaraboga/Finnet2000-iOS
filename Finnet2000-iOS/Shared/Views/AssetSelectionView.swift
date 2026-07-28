//
//  AssetSelectionView.swift
//  Finnet2000-iOS
//
//  Created by Karaboğa on 10/31/25.
//

import SwiftUI

/// Açılır menü seçici (AssetSelectionView)
struct AssetSelectionView: View {
  @Binding var selectedIndex: Int
  let values: [String]

  var body: some View {
    Menu {
      ForEach(Array(values.enumerated()), id: \.offset) { i, val in
        Button(val) { selectedIndex = i }
      }
    } label: {
      HStack(spacing: 4) {
        Text(values[safe: selectedIndex] ?? "")
          .font(.system(size: 13, weight: .semibold))
          .foregroundColor(Color.midGreen)
        Image(systemName: "chevron.down")
          .font(.system(size: 11))
          .foregroundColor(Color.midGreen)
      }
      .padding(.horizontal, 10)
      .padding(.vertical, 6)
      .background(Color.midGreen.opacity(0.1))
      .cornerRadius(8)
    }
  }
}

// MARK: - Safe subscript

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
