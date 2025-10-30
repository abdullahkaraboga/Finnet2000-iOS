// NewsListView.swift
import SwiftUI

struct NewsListView: View {
    @StateObject private var viewModel = NewsListViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Haberler yükleniyor…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 12) {
                    Text(error).foregroundColor(.red)
                    Button("Tekrar Dene") { viewModel.load() }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.items.isEmpty {
                Text("Gösterilecek haber bulunamadı.")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(viewModel.items) { item in
                    NewsRowView(item: item)
                }
                .listStyle(.plain)
            }
        }
        .onAppear {
            if viewModel.items.isEmpty {
                viewModel.load()
            }
        }
    }
}

struct NewsRowView: View {
    let item: NewsItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: URL(string: item.coverImagePath)) { img in
                img.resizable().scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 90, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Text(item.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)

                HStack(spacing: 8) {
                    if let d = item.date {
                        Text(d.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text("•")
                        .foregroundStyle(.secondary)
                    Text("\(item.readingTime) dk")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 6)
    }
}
