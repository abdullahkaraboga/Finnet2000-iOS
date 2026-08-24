import SwiftUI

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

struct FilterView: View {
    @StateObject private var viewModel = FilterViewModel()
    @Environment(\.dismiss) var dismiss
    
    // Hardcoded groupings for indices since API returns them flat
    private var ulusalCodes = ["XU100", "XU050", "XU030", "XUTUM", "XIKIU", "XKURY", "XYUZO", "XTUMY"]
    private var sektorelCodes = ["XUSIN", "XGIDA", "XTEKS", "XKAGT", "XKMYA", "XTAST", "XMANA", "XMESY"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Filtreler")
                    .font(.system(size: 22, weight: .bold))
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.green)
                }
            }
            .padding(20)
            .background(Color(.systemBackground))
            
            if viewModel.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if let error = viewModel.errorMessage {
                Spacer()
                Text(error).foregroundColor(.red).padding()
                Spacer()
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // TEMEL BİLGİ
                        FilterAccordion(title: "Temel Bilgi") {
                            VStack(alignment: .leading, spacing: 20) {
                                
                                // Ulusal Endeksler
                                FilterAccordion(title: "Ulusal Endeksler") {
                                    if let indices = viewModel.filterChoices?.indices {
                                        let ulusal = indices.filter { ulusalCodes.contains($0.code) }
                                        PaginatedChipGrid(items: ulusal, selectedIds: $viewModel.selectedIndices)
                                    } else {
                                        EmptyView()
                                    }
                                }
                                
                                // Sektörel Endeksler
                                FilterAccordion(title: "Sektörel Endeksler") {
                                    if let indices = viewModel.filterChoices?.indices {
                                        let sektorel = indices.filter { sektorelCodes.contains($0.code) }
                                        PaginatedChipGrid(items: sektorel, selectedIds: $viewModel.selectedIndices)
                                    } else {
                                        EmptyView()
                                    }
                                }
                                
                                // Sektörler
                                FilterAccordion(title: "Sektörler") {
                                    if let sectors = viewModel.filterChoices?.sectors {
                                        PaginatedChipGrid(items: sectors, selectedIds: $viewModel.selectedSectors, isWide: true)
                                    } else {
                                        EmptyView()
                                    }
                                }
                            }
                        }
                        
                        // GETİRİLER (Hardcoded)
                        FilterAccordion(title: "Getiriler") {
                            VStack(spacing: 12) {
                                MinMaxInputView(title: "Günlük", key: "getiri_gunluk", viewModel: viewModel)
                                MinMaxInputView(title: "Haftalık", key: "getiri_haftalik", viewModel: viewModel)
                            }
                        }
                        
                        // İNDİKATÖRLER (Hardcoded)
                        FilterAccordion(title: "İndikatörler") {
                            VStack(spacing: 12) {
                                MinMaxInputView(title: "RSI", key: "ind_rsi", viewModel: viewModel)
                                MinMaxInputView(title: "Hareketli Ort. Uzaklık (20)", key: "ind_ma20", viewModel: viewModel)
                            }
                        }
                        
                        // ORANLAR (API)
                        if let ratios = viewModel.filterChoices?.ratios {
                            ForEach(ratios, id: \.ratioType) { group in
                                FilterAccordion(title: group.ratioType) {
                                    VStack(spacing: 12) {
                                        ForEach(group.ratios) { ratio in
                                            MinMaxInputView(title: ratio.name, key: "ratio_\(ratio.id)", viewModel: viewModel)
                                        }
                                    }
                                }
                            }
                        }
                        
                    }
                    .padding(20)
                }
            }
            
            // Bottom Save Button
            VStack {
                Button {
                    // Kaydet işlemi
                    dismiss()
                } label: {
                    Text("Kaydet")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .padding(.top, 10)
                .background(Color(.systemBackground))
            }
        }
        .task {
            await viewModel.fetchChoices()
        }
    }
}

// MARK: - Components

struct FilterAccordion<Content: View>: View {
    let title: String
    @State private var isExpanded: Bool = true
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button {
                withAnimation { isExpanded.toggle() }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .bold))
                    Text(title)
                        .font(.system(size: 15, weight: .medium))
                    Spacer()
                }
                .foregroundColor(.primary)
            }
            
            if isExpanded {
                content
                    .padding(.leading, 12)
            }
        }
    }
}

struct PaginatedChipGrid: View {
    let items: [FilterItem]
    @Binding var selectedIds: Set<Int>
    var isWide: Bool = false
    
    var body: some View {
        let cols = [GridItem(.adaptive(minimum: isWide ? 160 : 65, maximum: isWide ? .infinity : 80), spacing: 8)]
        let chunkSize = isWide ? 6 : 10 // Wide chips take more space, fewer per page
        let chunks = items.chunked(into: chunkSize)
        
        if chunks.isEmpty {
            Text("Veri yok")
                .font(.caption)
                .foregroundColor(.secondary)
        } else {
            TabView {
                ForEach(0..<chunks.count, id: \.self) { idx in
                    LazyVGrid(columns: cols, spacing: 12) {
                        ForEach(chunks[idx]) { item in
                            ChipButton(item: item, isSelected: selectedIds.contains(item.id), useName: isWide) {
                                if selectedIds.contains(item.id) {
                                    selectedIds.remove(item.id)
                                } else {
                                    selectedIds.insert(item.id)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, 4)
                    .padding(.bottom, 40) // Make room for dots
                }
            }
            .frame(height: 160)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .onAppear {
                UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.green)
                UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.gray.opacity(0.3))
            }
        }
    }
}

struct ChipButton: View {
    let item: FilterItem
    let isSelected: Bool
    var useName: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(useName ? item.name : item.code)
                .font(.system(size: 12, weight: .medium))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.green : Color(.systemGray6))
                .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}

struct MinMaxInputView: View {
    let title: String
    let key: String
    @ObservedObject var viewModel: FilterViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .frame(maxWidth: .infinity, alignment: .center)
            
            HStack(spacing: 12) {
                TextField("Min", text: Binding(
                    get: { viewModel.getRange(for: key).min },
                    set: { viewModel.updateRangeMin(for: key, min: $0) }
                ))
                .keyboardType(.decimalPad)
                .padding(12)
                .background(Color(.systemBackground))
                .cornerRadius(8)
                
                TextField("Max", text: Binding(
                    get: { viewModel.getRange(for: key).max },
                    set: { viewModel.updateRangeMax(for: key, max: $0) }
                ))
                .keyboardType(.decimalPad)
                .padding(12)
                .background(Color(.systemBackground))
                .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
    }
}

