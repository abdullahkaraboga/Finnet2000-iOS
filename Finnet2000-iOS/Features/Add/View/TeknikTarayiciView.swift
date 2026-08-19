import SwiftUI

// Mock data removed in favor of API

// MARK: - View

struct TeknikTarayiciView: View {
    @Namespace private var animation
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = TeknikTarayiciViewModel()
    @State private var selectedTab: ScanTab = .al
    @State private var showFilterSheet = false
    
    @State private var hOffset: CGFloat = 0
    @State private var hOffsetAtDragStart: CGFloat = 0

    enum ScanTab: Hashable { case al, sat }

    private let columns: [(header: String, keyPath: KeyPath<TeknikScannerResponseItem, String?>, width: CGFloat)] = [
        ("MA5",       \TeknikScannerResponseItem.ma5Signal, 80),
        ("MA5>20",    \TeknikScannerResponseItem.ma5To20Signal, 90),
        ("MA20>50",   \TeknikScannerResponseItem.ma20To50Signal, 90),
        ("RSI",       \TeknikScannerResponseItem.rsiSignal, 80),
        ("RSI AA/AS", \TeknikScannerResponseItem.rsiAAorAS, 90),
        ("CCI",       \TeknikScannerResponseItem.cciSignal, 80),
        ("CCI AA/AS", \TeknikScannerResponseItem.cciAAorAS, 90),
        ("MACD",      \TeknikScannerResponseItem.macdSignal, 80),
    ]

    private var rows: [TeknikScannerResponseItem] {
        viewModel.rows
    }
    
    private let fixedColWidth: CGFloat = 80
    private var numericTotalWidth: CGFloat {
        columns.map(\.width).reduce(0, +) + 16
    }
    private var numericVisibleWidth: CGFloat {
        UIScreen.main.bounds.width - fixedColWidth
    }
    private var maxHOffset: CGFloat {
        max(0, numericTotalWidth - numericVisibleWidth)
    }

    // MARK: Body

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                segmentedControl
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)

                tableContainer
            }
            .padding(.bottom, 80)

            floatingFilterButton
        }
        .navigationTitle("Teknik Tarayıcı")
        .navigationBarTitleDisplayMode(.inline)
        .transparentNavigationBar()
        .sheet(isPresented: $showFilterSheet) {
            TeknikFilterSheet(viewModel: viewModel, onApply: {
                viewModel.loadSignals(analysisType: selectedTab == .al ? 0 : 1)
            })
        }
        .onAppear {
            viewModel.loadChoices()
            viewModel.loadSignals(analysisType: selectedTab == .al ? 0 : 1)
        }
        .onChange(of: selectedTab) { newTab in
            viewModel.loadSignals(analysisType: newTab == .al ? 0 : 1)
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground).opacity(0.3))
            }
        }
    }

    // MARK: - Segmented Control

    private var segmentedControl: some View {
        Picker("Sinyal Türü", selection: $selectedTab) {
            Text("AL Sinyalleri").tag(ScanTab.al)
            Text("SAT Sinyalleri").tag(ScanTab.sat)
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Table

    private var tableContainer: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                Section {
                    ForEach(Array(rows.enumerated()), id: \.element.id) { idx, row in
                        tableRow(row, idx: idx)
                        Divider()
                    }
                } header: {
                    tableHeader
                }
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 5)
                .onChanged { value in
                    guard abs(value.translation.width) > abs(value.translation.height) else { return }
                    let proposed = hOffsetAtDragStart - value.translation.width
                    hOffset = max(0, min(proposed, maxHOffset))
                }
                .onEnded { _ in
                    hOffsetAtDragStart = hOffset
                }
        )
    }

    private var tableHeader: some View {
        HStack(spacing: 0) {
            Text("Kod")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.primary)
                .frame(width: fixedColWidth - 12, alignment: .leading)
                .padding(.leading, 12)
                .frame(width: fixedColWidth)

            HStack(spacing: 0) {
                ForEach(columns.indices, id: \.self) { i in
                    Text(columns[i].header)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(width: columns[i].width, alignment: .center)
                        .multilineTextAlignment(.center)
                }
                Spacer(minLength: 16)
            }
            .offset(x: -hOffset)
            .frame(width: numericVisibleWidth, alignment: .leading)
            .clipped()
        }
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
        .overlay(alignment: .bottom) { Divider() }
    }

    private func tableRow(_ row: TeknikScannerResponseItem, idx: Int) -> some View {
        HStack(spacing: 0) {
            Text(row.code)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)
                .frame(width: fixedColWidth - 12, alignment: .leading)
                .padding(.leading, 12)
                .frame(width: fixedColWidth)

            HStack(spacing: 0) {
                ForEach(columns.indices, id: \.self) { i in
                    let value = row[keyPath: columns[i].keyPath] ?? "-"
                    Text(value)
                        .font(.system(size: 13, weight: signalWeight(value)))
                        .foregroundColor(signalColor(value))
                        .frame(width: columns[i].width, alignment: .center)
                }
                Spacer(minLength: 16)
            }
            .offset(x: -hOffset)
            .frame(width: numericVisibleWidth, alignment: .leading)
            .clipped()
        }
        .padding(.vertical, 14)
        .background(idx % 2 == 1 ? Color(.systemGray6).opacity(0.5) : Color(.systemBackground))
    }

    // MARK: - Floating Filter Button

    private var floatingFilterButton: some View {
        Button {
            showFilterSheet = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.system(size: 17, weight: .semibold))
                Text("Endeks/Sektör Filtrele")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(Color.midGreen)
            .clipShape(Capsule())
            .shadow(color: Color.midGreen.opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .padding(.bottom, 24)
    }
}

// MARK: - Signal Helpers

private func signalColor(_ value: String) -> Color {
    let lower = value.lowercased()
    if lower == "al" { return Color.signalAl }
    if lower == "sat" { return Color.signalSat }
    return .secondary
}

private func signalWeight(_ value: String) -> Font.Weight {
    let lower = value.lowercased()
    if lower == "al" || lower == "sat" { return .bold }
    return .regular
}

// MARK: - Filter Sheet

private struct TeknikFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TeknikTarayiciViewModel
    var onApply: () -> Void

    @State private var ulusalExpanded    = true
    @State private var sektorelExpanded  = true
    @State private var sektorlerExpanded = true
    
    @State private var ulusalPage    = 0
    @State private var sektorelPage  = 0
    @State private var sektorlerPage = 0

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Tarayıcıyı Filtrele")
                    .font(.system(size: 20, weight: .bold))
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 30, height: 30)
                        .background(Color(.systemGray6), in: Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 12)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    sectionView(
                        title: "Ulusal Endeksler",
                        items: viewModel.nationalIndices,
                        isExpanded: $ulusalExpanded,
                        currentPage: $ulusalPage,
                        selectedItems: $viewModel.selectedNationalIndices,
                        itemsPerRow: 4
                    )
                    sectionView(
                        title: "Sektörel Endeksler",
                        items: viewModel.sectoralIndices,
                        isExpanded: $sektorelExpanded,
                        currentPage: $sektorelPage,
                        selectedItems: $viewModel.selectedSectoralIndices,
                        itemsPerRow: 4
                    )
                    sectionView(
                        title: "Sektörler",
                        items: viewModel.sectors,
                        isExpanded: $sektorlerExpanded,
                        currentPage: $sektorlerPage,
                        selectedItems: $viewModel.selectedSectors,
                        itemsPerRow: 2,
                        rowsPerPage: 5
                    )
                }
                .padding(.bottom, 16)
            }

            // Kaydet button
            Button {
                onApply()
                dismiss()
            } label: {
                Text("Filtreyi Uygula")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.midGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .shadow(color: Color.midGreen.opacity(0.3), radius: 8, y: 4)
        }
        .background(Color(.systemBackground))
    }

    @ViewBuilder
    private func sectionView(
        title: String,
        items: [(id: Int, name: String)],
        isExpanded: Binding<Bool>,
        currentPage: Binding<Int>,
        selectedItems: Binding<Set<Int>>,
        itemsPerRow: Int,
        rowsPerPage: Int = 2
    ) -> some View {
        if items.isEmpty {
            EmptyView()
        } else {
            let itemsPerPage = itemsPerRow * rowsPerPage
            let pages = makePages(items: items, itemsPerPage: itemsPerPage)
            let totalDots = pages.count

            VStack(alignment: .leading, spacing: 0) {
                Button {
                    withAnimation(.easeInOut(duration: 0.22)) {
                        isExpanded.wrappedValue.toggle()
                    }
                } label: {
                HStack(spacing: 12) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded.wrappedValue ? 0 : -180))
                }
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .buttonStyle(.plain)

                if isExpanded.wrappedValue {
                    VStack(spacing: 12) {
                        TabView(selection: currentPage) {
                            ForEach(pages.indices, id: \.self) { pi in
                                chipPageView(items: pages[pi], selectedItems: selectedItems, itemsPerRow: itemsPerRow)
                                    .tag(pi)
                                    .padding(.horizontal, 20)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(height: chipGridHeight(
                            itemCount: pages.first?.count ?? 0,
                            itemsPerRow: itemsPerRow
                        ))

                        if totalDots > 1 {
                            pageDotsView(total: totalDots, current: currentPage.wrappedValue)
                                .padding(.bottom, 16)
                        } else {
                            Spacer().frame(height: 16)
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.98, anchor: .top)),
                        removal: .opacity
                    ))
                }
            }
        }
    }

    private func makePages(items: [(id: Int, name: String)], itemsPerPage: Int) -> [[(id: Int, name: String)]] {
        stride(from: 0, to: items.count, by: itemsPerPage).map {
            Array(items[$0..<min($0 + itemsPerPage, items.count)])
        }
    }

    @ViewBuilder
    private func chipPageView(items: [(id: Int, name: String)], selectedItems: Binding<Set<Int>>, itemsPerRow: Int) -> some View {
        let rows = stride(from: 0, to: items.count, by: itemsPerRow).map {
            Array(items[$0..<min($0 + itemsPerRow, items.count)])
        }
        VStack(alignment: .leading, spacing: 10) {
            ForEach(rows.indices, id: \.self) { ri in
                HStack(spacing: 8) {
                    ForEach(rows[ri], id: \.id) { item in
                        chipToggle(item, selectedItems: selectedItems)
                    }
                    Spacer(minLength: 0)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 3)
    }

    private func chipToggle(_ item: (id: Int, name: String), selectedItems: Binding<Set<Int>>) -> some View {
        Button {
            if selectedItems.wrappedValue.contains(item.id) {
                selectedItems.wrappedValue.remove(item.id)
            } else {
                selectedItems.wrappedValue.insert(item.id)
            }
        } label: {
            let isSelected = selectedItems.wrappedValue.contains(item.id)
            Text(item.name)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background {
                    if isSelected {
                        Capsule().fill(Color.midGreen)
                    } else {
                        Capsule().fill(Color(.systemGray6))
                    }
                }
                .overlay(
                    Capsule().stroke(isSelected ? Color.clear : Color.secondary.opacity(0.1), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func chipGridHeight(itemCount: Int, itemsPerRow: Int) -> CGFloat {
        guard itemCount > 0 else { return 44 }
        let rows = Int(ceil(Double(itemCount) / Double(itemsPerRow)))
        let chipH: CGFloat = 44
        let spacing: CGFloat = 10
        return CGFloat(rows) * chipH + CGFloat(max(0, rows - 1)) * spacing + 6
    }

    private func pageDotsView(total: Int, current: Int) -> some View {
        HStack(spacing: 6) {
            ForEach(0..<total, id: \.self) { i in
                Circle()
                    .fill(i == current ? Color.midGreen : Color(.systemGray4))
                    .frame(width: i == current ? 8 : 6, height: i == current ? 8 : 6)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: current)
            }
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    NavigationView {
        TeknikTarayiciView()
    }
    .preferredColorScheme(.dark)
}

#Preview {
    NavigationView {
        TeknikTarayiciView()
    }
    .preferredColorScheme(.light)
}
