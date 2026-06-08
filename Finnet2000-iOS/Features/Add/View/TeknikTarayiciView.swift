import SwiftUI

// MARK: - Model

struct TeknikScannerRow: Identifiable {
    let id = UUID()
    let code: String
    let ma5Signal: String
    let ma5To20Signal: String
    let ma20Signal: String
    let rsiSignal: String
    let macdSignal: String
    let bollingerSignal: String
}

// MARK: - Signal Display

private func signalColor(_ value: String) -> Color {
    let lower = value.lowercased()
    if lower == "al" { return Color.midGreen }
    if lower == "sat" { return Color.red }
    return .secondary
}

private func signalWeight(_ value: String) -> Font.Weight {
    let lower = value.lowercased()
    if lower == "al" || lower == "sat" { return .semibold }
    return .regular
}

// MARK: - Mock Data

private enum TeknikMockData {
    static let alRows: [TeknikScannerRow] = [
        TeknikScannerRow(code: "GEDZA", ma5Signal: "-",   ma5To20Signal: "AL",  ma20Signal: "AL",  rsiSignal: "-",   macdSignal: "AL",  bollingerSignal: "-"),
        TeknikScannerRow(code: "OTKAR", ma5Signal: "-",   ma5To20Signal: "-",   ma20Signal: "-",   rsiSignal: "AL",  macdSignal: "-",   bollingerSignal: "AL"),
        TeknikScannerRow(code: "AKCNS", ma5Signal: "AL",  ma5To20Signal: "-",   ma20Signal: "AL",  rsiSignal: "-",   macdSignal: "-",   bollingerSignal: "-"),
        TeknikScannerRow(code: "BMSTL", ma5Signal: "AL",  ma5To20Signal: "-",   ma20Signal: "-",   rsiSignal: "AL",  macdSignal: "AL",  bollingerSignal: "-"),
        TeknikScannerRow(code: "MAALT", ma5Signal: "AL",  ma5To20Signal: "-",   ma20Signal: "-",   rsiSignal: "-",   macdSignal: "AL",  bollingerSignal: "-"),
        TeknikScannerRow(code: "RYSAS", ma5Signal: "AL",  ma5To20Signal: "-",   ma20Signal: "AL",  rsiSignal: "AL",  macdSignal: "-",   bollingerSignal: "-"),
        TeknikScannerRow(code: "ADEL",  ma5Signal: "sat", ma5To20Signal: "sat", ma20Signal: "-",   rsiSignal: "AL",  macdSignal: "-",   bollingerSignal: "AL"),
        TeknikScannerRow(code: "ATEKS", ma5Signal: "sat", ma5To20Signal: "sat", ma20Signal: "-",   rsiSignal: "AL",  macdSignal: "-",   bollingerSignal: "-"),
        TeknikScannerRow(code: "BINBN", ma5Signal: "sat", ma5To20Signal: "sat", ma20Signal: "AL",  rsiSignal: "-",   macdSignal: "-",   bollingerSignal: "-"),
        TeknikScannerRow(code: "DZGYO", ma5Signal: "sat", ma5To20Signal: "AL",  ma20Signal: "-",   rsiSignal: "AL",  macdSignal: "AL",  bollingerSignal: "-"),
        TeknikScannerRow(code: "YGGYO", ma5Signal: "sat", ma5To20Signal: "SAT", ma20Signal: "-",   rsiSignal: "-",   macdSignal: "-",   bollingerSignal: "AL"),
    ]

    static let satRows: [TeknikScannerRow] = [
        TeknikScannerRow(code: "AKMGY", ma5Signal: "-",   ma5To20Signal: "-",   ma20Signal: "-",   rsiSignal: "-",   macdSignal: "-",   bollingerSignal: "-"),
        TeknikScannerRow(code: "BRMEN", ma5Signal: "-",   ma5To20Signal: "-",   ma20Signal: "SAT", rsiSignal: "-",   macdSignal: "-",   bollingerSignal: "-"),
        TeknikScannerRow(code: "CELHA", ma5Signal: "-",   ma5To20Signal: "-",   ma20Signal: "-",   rsiSignal: "SAT", macdSignal: "-",   bollingerSignal: "-"),
        TeknikScannerRow(code: "DUNYH", ma5Signal: "-",   ma5To20Signal: "-",   ma20Signal: "-",   rsiSignal: "-",   macdSignal: "SAT", bollingerSignal: "-"),
        TeknikScannerRow(code: "AHGAZ", ma5Signal: "SAT", ma5To20Signal: "-",   ma20Signal: "SAT", rsiSignal: "-",   macdSignal: "-",   bollingerSignal: "-"),
        TeknikScannerRow(code: "AKHAN", ma5Signal: "SAT", ma5To20Signal: "sat", ma20Signal: "-",   rsiSignal: "SAT", macdSignal: "-",   bollingerSignal: "-"),
        TeknikScannerRow(code: "AKSA",  ma5Signal: "SAT", ma5To20Signal: "-",   ma20Signal: "-",   rsiSignal: "-",   macdSignal: "SAT", bollingerSignal: "-"),
        TeknikScannerRow(code: "ALFAS", ma5Signal: "SAT", ma5To20Signal: "-",   ma20Signal: "SAT", rsiSignal: "-",   macdSignal: "-",   bollingerSignal: "SAT"),
        TeknikScannerRow(code: "ALKIM", ma5Signal: "SAT", ma5To20Signal: "sat", ma20Signal: "-",   rsiSignal: "SAT", macdSignal: "SAT", bollingerSignal: "-"),
        TeknikScannerRow(code: "ANELE", ma5Signal: "SAT", ma5To20Signal: "-",   ma20Signal: "-",   rsiSignal: "-",   macdSignal: "-",   bollingerSignal: "SAT"),
        TeknikScannerRow(code: "ARDYZ", ma5Signal: "SAT", ma5To20Signal: "-",   ma20Signal: "SAT", rsiSignal: "-",   macdSignal: "-",   bollingerSignal: "-"),
        TeknikScannerRow(code: "ASTOR", ma5Signal: "SAT", ma5To20Signal: "-",   ma20Signal: "-",   rsiSignal: "SAT", macdSignal: "-",   bollingerSignal: "-"),
        TeknikScannerRow(code: "ATATP", ma5Signal: "SAT", ma5To20Signal: "-",   ma20Signal: "-",   rsiSignal: "-",   macdSignal: "SAT", bollingerSignal: "-"),
        TeknikScannerRow(code: "AYEN",  ma5Signal: "SAT", ma5To20Signal: "sat", ma20Signal: "SAT", rsiSignal: "-",   macdSignal: "-",   bollingerSignal: "-"),
        TeknikScannerRow(code: "BAKAB", ma5Signal: "SAT", ma5To20Signal: "-",   ma20Signal: "-",   rsiSignal: "SAT", macdSignal: "-",   bollingerSignal: "SAT"),
        TeknikScannerRow(code: "BIGEN", ma5Signal: "SAT", ma5To20Signal: "-",   ma20Signal: "SAT", rsiSignal: "-",   macdSignal: "-",   bollingerSignal: "-"),
    ]
}

// MARK: - View

struct TeknikTarayiciView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: ScanTab = .al
    @State private var hOffset: CGFloat = 0
    @State private var hOffsetAtDragStart: CGFloat = 0
    @State private var showFilterSheet = false

    enum ScanTab { case al, sat }

    // MARK: Layout constants
    private let codeColW: CGFloat   = 80
    private let signalColW: CGFloat = 110

    private let columns: [(header: String, keyPath: KeyPath<TeknikScannerRow, String>)] = [
        ("ma5Signal",        \TeknikScannerRow.ma5Signal),
        ("ma5To20Signal",    \TeknikScannerRow.ma5To20Signal),
        ("ma20Signal",       \TeknikScannerRow.ma20Signal),
        ("RSI Sinyal",       \TeknikScannerRow.rsiSignal),
        ("MACD Sinyal",      \TeknikScannerRow.macdSignal),
        ("Bollinger Sinyal", \TeknikScannerRow.bollingerSignal),
    ]

    private var totalScrollableWidth: CGFloat {
        CGFloat(columns.count) * signalColW
    }

    private var visibleScrollWidth: CGFloat {
        UIScreen.main.bounds.width - codeColW
    }

    private var maxHOffset: CGFloat {
        max(0, totalScrollableWidth - visibleScrollWidth)
    }

    private var rows: [TeknikScannerRow] {
        selectedTab == .al ? TeknikMockData.alRows : TeknikMockData.satRows
    }

    // MARK: Body

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                navBar
                segmentedControl
                tableContent
            }
            .background(Color(.systemBackground))

            floatingFilterButton
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showFilterSheet) {
            FilterSheetPlaceholder()
        }
    }

    // MARK: - Navigation Bar

    private var navBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)

            Spacer()

            Text("Teknik Tarayıcı")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)

            Spacer()

            Button {} label: {
                Image(systemName: "info.circle")
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .background(Color.black.ignoresSafeArea(edges: .top))
    }

    // MARK: - Segmented Control

    private var segmentedControl: some View {
        HStack(spacing: 0) {
            segmentButton(tab: .al,
                          iconName: "dollarsign",
                          label: "AL")
            segmentButton(tab: .sat,
                          iconName: "arrow.down.arrow.up",
                          label: "Sat")
        }
        .padding(4)
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }

    private func segmentButton(tab: ScanTab, iconName: String, label: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                selectedTab = tab
                hOffset = 0
                hOffsetAtDragStart = 0
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: iconName)
                    .font(.system(size: 14, weight: .semibold))
                Text(label)
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(selectedTab == tab ? .primary : .secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                selectedTab == tab
                    ? RoundedRectangle(cornerRadius: 9, style: .continuous).fill(Color.midGreen.opacity(0.35))
                    : nil
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Table

    private var tableContent: some View {
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
        .padding(.bottom, 80)
    }

    private var tableHeader: some View {
        HStack(spacing: 0) {
            // Fixed code column header
            HStack(spacing: 3) {
                Text("code")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.primary)
            }
            .frame(width: codeColW - 12, alignment: .leading)
            .padding(.leading, 12)
            .frame(width: codeColW)

            // Scrollable signal column headers
            HStack(spacing: 0) {
                ForEach(columns.indices, id: \.self) { i in
                    Text(columns[i].header)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .frame(width: signalColW, alignment: .leading)
                        .padding(.leading, 4)
                }
            }
            .offset(x: -hOffset)
            .frame(width: visibleScrollWidth, alignment: .leading)
            .clipped()
        }
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
        .overlay(alignment: .bottom) { Divider() }
    }

    private func tableRow(_ row: TeknikScannerRow, idx: Int) -> some View {
        HStack(spacing: 0) {
            // Fixed code column
            Text(row.code)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)
                .frame(width: codeColW - 12, alignment: .leading)
                .padding(.leading, 12)
                .frame(width: codeColW)

            // Scrollable signal columns
            HStack(spacing: 0) {
                ForEach(columns.indices, id: \.self) { i in
                    let value = row[keyPath: columns[i].keyPath]
                    Text(value)
                        .font(.system(size: 13, weight: signalWeight(value)))
                        .foregroundColor(signalColor(value))
                        .frame(width: signalColW, alignment: .leading)
                        .padding(.leading, 4)
                }
            }
            .offset(x: -hOffset)
            .frame(width: visibleScrollWidth, alignment: .leading)
            .clipped()
        }
        .padding(.vertical, 12)
        .background(idx % 2 == 1 ? Color(.systemGray6).opacity(0.5) : Color(.systemBackground))
    }

    // MARK: - Floating Filter Button

    private var floatingFilterButton: some View {
        Button {
            showFilterSheet = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "arrow.up.arrow.down.square")
                    .font(.system(size: 17, weight: .semibold))
                Text("Endeks/Sektör Filtrele")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(.primary)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(Color(.systemBackground))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.midGreen, lineWidth: 1.5))
            .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .padding(.bottom, 24)
    }
}

// MARK: - Filter Sheet Placeholder

private struct FilterSheetPlaceholder: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Endeks") {
                    Text("BIST 30")
                    Text("BIST 50")
                    Text("BIST 100")
                    Text("BIST Tümü")
                }
                Section("Sektör") {
                    Text("Bankacılık")
                    Text("Teknoloji")
                    Text("Perakende")
                    Text("Enerji")
                    Text("Sanayi")
                }
            }
            .navigationTitle("Endeks/Sektör Filtrele")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Uygula") { dismiss() }
                        .foregroundColor(Color.midGreen)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    TeknikTarayiciView()
}
