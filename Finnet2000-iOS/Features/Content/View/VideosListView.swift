// VideosListView.swift
import SwiftUI
import WebKit

struct VideosListView: View {
    @StateObject private var viewModel: VideosListViewModel
    @State private var selectedItem: VideoItem?

    init(viewModel: VideosListViewModel = DependencyContainer.shared.makeVideosListViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Videolar yükleniyor…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Text(error).foregroundColor(.red)
                        Button("Tekrar Dene") { viewModel.load() }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.items.isEmpty {
                    Text("Gösterilecek video bulunamadı.")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(viewModel.items) { item in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedItem = item
                            }
                        } label: {
                            VideoRowView(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                    .listStyle(.plain)
                }
            }

            if let item = selectedItem {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedItem = nil
                        }
                    }

                CenteredVideoPopup(item: item) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedItem = nil
                    }
                }
                .transition(.scale(scale: 0.95).combined(with: .opacity))
            }
        }
        .onAppear {
            if viewModel.items.isEmpty {
                viewModel.load()
            }
        }
    }
}

struct VideoRowView: View {
    let item: VideoItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: item.resolvedThumbnailURL) { img in
                img.resizable().scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 120, height: 68)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                if let d = item.publishedAt {
                    Text(d.f2000Formatted)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(item.type)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
        .padding(.vertical, 6)
    }
}

struct VideoDetailPlayerView: View {
    let item: VideoItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let videoID = item.youtubeVideoID {
                    YouTubeWebView(videoID: videoID)
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                } else {
                    ContentUnavailableView(
                        "Video acilamadi",
                        systemImage: "play.rectangle",
                        description: Text("Gecerli bir YouTube video kimligi bulunamadi.")
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 220)
                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                Text(item.title)
                    .font(.headline)

                if let desc = item.description, !desc.isEmpty {
                    Text(desc)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if let publishedAt = item.publishedAt {
                    Text(publishedAt.f2000Formatted)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(16)
        }
        .navigationTitle("Video")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CenteredVideoPopup: View {
    let item: VideoItem
    let onClose: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let popupWidth = min(proxy.size.width - 40, 680)
            let popupHeight = min(proxy.size.height * 0.72, 560)

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.white.opacity(0.2), in: Circle())
                    }
                    .buttonStyle(.plain)
                    .padding(10)
                }

                Group {
                    if let videoID = item.youtubeVideoID {
                        YouTubeWebView(videoID: videoID)
                    } else {
                        ContentUnavailableView(
                            "Video acilamadi",
                            systemImage: "play.rectangle",
                            description: Text("Gecerli bir YouTube video kimligi bulunamadi.")
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: popupWidth, height: popupHeight)
            .background(Color.black, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.35), radius: 20, x: 0, y: 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - YouTube iFrame tam ekran WebView
struct YouTubeWebView: UIViewRepresentable {
    let videoID: String

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        if #available(iOS 10.0, *) {
            config.mediaTypesRequiringUserActionForPlayback = []
        }
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .black
        webView.isOpaque = false
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
        <meta name="viewport" content="initial-scale=1, maximum-scale=1, user-scalable=no, width=device-width">
        <style>
        html, body { margin:0; padding:0; background:black; width:100%; height:100%; overflow:hidden; }
        #wrap { position:relative; width:100%; height:100%; }
        #player { position:absolute; inset:0; width:100%; height:100%; }
        </style>
        </head>
        <body>
        <div id="wrap">
          <iframe id="player"
                  src="https://www.youtube.com/embed/\(videoID)?playsinline=1&autoplay=1&modestbranding=1&rel=0"
                  frameborder="0"
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                  allowfullscreen>
          </iframe>
        </div>
        </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }
}

#Preview {
    VideosListView()
}
