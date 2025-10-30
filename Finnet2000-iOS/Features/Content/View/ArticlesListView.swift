// ArticlesListView.swift
import SwiftUI

struct ArticlesListView: View {
    @StateObject private var viewModel = ArticlesListViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Makaleler yükleniyor…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 12) {
                    Text(error).foregroundColor(.red)
                    Button("Tekrar Dene") { viewModel.load() }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.items.isEmpty {
                Text("Gösterilecek makale bulunamadı.")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(viewModel.items) { item in
                    ArticleRowView(item: item)
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

struct ArticleRowView: View {
    let item: ArticleItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: URL(string: item.thumbnailPath ?? "")) { img in
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

                if let desc = item.description, !desc.isEmpty {
                    Text(desc)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }

                if let d = item.publishedAt {
                    Text(d.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 6)
    }
}
