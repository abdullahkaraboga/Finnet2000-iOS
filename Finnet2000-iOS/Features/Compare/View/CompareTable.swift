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
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)

            Divider()

            // Rows
            ForEach(rows.indices, id: \.self) { rowIndex in
                HStack {
                    let row = rows[rowIndex]
                    ForEach(row.indices, id: \.self) { colIndex in
                        Text(row[colIndex])
                            .font(.system(size: 13))
                            .foregroundColor(colIndex == 0 ? .primary : .secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 12)
                Divider()
            }
        }
    }
}

