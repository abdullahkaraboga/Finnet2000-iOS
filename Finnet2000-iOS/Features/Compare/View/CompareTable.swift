//
//  CompareTable.swift
//  Finnet2000-iOS
//
//  Created by Karaboğa on 10/31/25.
//
import SwiftUI

struct CompareTable: View {
    var columns: [String] = []
    var rows: [[String]] = []
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                ForEach(columns.indices, id: \.self) { idx in
                    Text(columns[idx])
                        .font(.caption.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.vertical, 6)
            .background(Color(.secondarySystemBackground))
            
            Divider()
            
            // Rows
            ForEach(rows.indices, id: \.self) { rowIndex in
                HStack {
                    let row = rows[rowIndex]
                    ForEach(row.indices, id: \.self) { colIndex in
                        Text(row[colIndex])
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.vertical, 6)
                Divider()
            }
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
    }
}

