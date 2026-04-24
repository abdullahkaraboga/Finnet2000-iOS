import SwiftUI

struct CompareView: View {
    @StateObject private var viewModel = CompareViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                NavigationHeaderView()
                ScrollView {
                    VStack(spacing: 24) {
                        // 🔹 Dropdown alanı
                        pickerSection
                        
                        if let result = viewModel.compareResult {
                            RadarChartSection(result: result)
                        }

                        // 🔹 Risk Parametreleri
                        if let result = viewModel.compareResult {
                            RiskParametersSection(result: result, leftKey: viewModel.selectedCode1, rightKey: viewModel.selectedCode2)
                        }

                        // 🔹 Getiriler
                        if let result = viewModel.compareResult {
                            ReturnsSection(result: result, leftKey: viewModel.selectedCode1, rightKey: viewModel.selectedCode2)
                        }

                        // 🔹 Finansal Tablolar
                        if let result = viewModel.compareResult {
                            FinancialTablesSection(result: result, leftKey: viewModel.selectedCode1, rightKey: viewModel.selectedCode2)
                        }

                        // 🔹 Finansal Analiz
                        if let result = viewModel.compareResult {
                            FinancialAnalysisSection(result: result, leftKey: viewModel.selectedCode1, rightKey: viewModel.selectedCode2)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemBackground))
                .overlay(loadingOverlay)
                .alert("Hata", isPresented: Binding(
                    get: { viewModel.error != nil },
                    set: { if !$0 { viewModel.clearError() } }
                )) {
                    Button("Tamam") { viewModel.clearError() }
                } message: {
                    Text(viewModel.error?.errorDescription ?? "")
                }
                .onAppear {
                    if viewModel.stocks.isEmpty { viewModel.loadStocks() }
                }
                .onChange(of: viewModel.selectedCode1) { _ in
                    viewModel.fetchCompareIfReady()
                }
                .onChange(of: viewModel.selectedCode2) { _ in
                    viewModel.fetchCompareIfReady()
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Bölümler

extension CompareView {
    // Picker alanı
    private var pickerSection: some View {
        HStack(spacing: 12) {
            stockPicker(title: "1. Hisse", selection: $viewModel.selectedCode1)
            stockPicker(title: "2. Hisse", selection: $viewModel.selectedCode2)
        }
    }

    private func stockPicker(title: String, selection: Binding<String?>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Picker(title, selection: selection) {
                ForEach(viewModel.stocks) { stock in
                    Text(stock.code).tag(stock.code as String?)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
        }
        .frame(maxWidth: .infinity)
    }

    // Loading
    private var loadingOverlay: some View {
        Group {
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.3).ignoresSafeArea()
                    ProgressView("Yükleniyor…")
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                }
            }
        }
    }
}
