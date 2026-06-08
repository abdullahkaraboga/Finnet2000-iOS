// ArticlesListView.swift
import SwiftUI

struct ArticlesListView: View {
    @StateObject private var viewModel: ArticlesListViewModel

    init(viewModel: ArticlesListViewModel = DependencyContainer.shared.makeArticlesListViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

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
                    NavigationLink {
                        ArticleDetailMarkdownView(item: item)
                    } label: {
                        ArticleRowView(item: item)
                    }
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
                    Text(d.f2000Formatted)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 6)
    }
}

struct ArticleDetailMarkdownView: View {
    let item: ArticleItem

    @State private var isLoading = true
    @State private var renderedMarkdown: AttributedString?
    @State private var fallbackText: String?
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Makale yükleniyor…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage {
                VStack(spacing: 12) {
                    Text("İçerik açılamadı")
                        .font(.headline)
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Tekrar Dene") {
                        Task { await loadMarkdownContent() }
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if let publishedAt = item.publishedAt {
                            Text(publishedAt.f2000Formatted)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        if let renderedMarkdown {
                            Text(renderedMarkdown)
                                .textSelection(.enabled)
                        } else if let fallbackText {
                            Text(fallbackText)
                                .textSelection(.enabled)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                }
            }
        }
        .navigationTitle(item.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadMarkdownContent()
        }
    }

    private func loadMarkdownContent() async {
        isLoading = true
        errorMessage = nil

        guard let contentURL = resolvedContentURL(from: item.contentPath) else {
            errorMessage = "Geçersiz içerik adresi"
            isLoading = false
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: contentURL)
            let rawMarkdown = String(decoding: data, as: UTF8.self)

            if let parsed = try? AttributedString(
                markdown: rawMarkdown,
                options: AttributedString.MarkdownParsingOptions(
                    interpretedSyntax: .full,
                    failurePolicy: .returnPartiallyParsedIfPossible
                )
            ) {
                renderedMarkdown = parsed
                fallbackText = nil
            } else {
                renderedMarkdown = nil
                fallbackText = rawMarkdown
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func resolvedContentURL(from rawPath: String) -> URL? {
        if let absolute = URL(string: rawPath), absolute.scheme != nil {
            return absolute
        }

        if rawPath.hasPrefix("/") {
            return URL(string: "https://api.finnet2000.com\(rawPath)")
        }

        return URL(string: "https://api.finnet2000.com/\(rawPath)")
    }
}

#Preview {
    ArticlesListView()
}
