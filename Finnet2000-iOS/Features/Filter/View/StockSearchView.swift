import SwiftUI

struct StockSearchView: View {
    @State private var searchText = ""
    @State private var searchResults = ["AKBNK", "GARAN", "TUPRS", "THYAO", "PETKM", "ISCTR", "KCHOL", "SASA", "EREGL", "BIMAS"]
    
    var onAdd: (String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            searchBar
                .padding([.horizontal, .top])
            
            Divider()
                .padding(.top, 10)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(searchResults, id: \.self) { stock in
                        StockRow(stockCode: stock, fullName: "\(stock) - Hisse Senedi Adı") {
                            onAdd(stock)
                        }
                        Divider()
                            .padding(.leading)
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Hisse Ekle")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Hisse Kodu Ara", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(8)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
}

fileprivate struct StockRow: View {
    let stockCode: String
    let fullName: String
    let onAdd: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading) {
                Text(stockCode)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(fullName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onAdd) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .contentShape(Rectangle()) // Makes the whole row tappable if needed
    }
}

struct StockSearchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StockSearchView(onAdd: { stock in
                print("\(stock) eklendi.")
            })
            .preferredColorScheme(.dark)
        }
    }
}
