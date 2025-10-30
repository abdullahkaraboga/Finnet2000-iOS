// VideosListView.swift
import SwiftUI
import AVKit
import WebKit
import AVFoundation

struct VideosListView: View {
    @StateObject private var viewModel = VideosListViewModel()
    @State private var selectedItem: VideoItem? = nil
    @State private var showOverlay: Bool = false

    var body: some View {
        ZStack {
            // Ana içerik
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
                            selectedItem = item
                            withAnimation(.easeInOut(duration: 0.2)) { showOverlay = true }
                        } label: {
                            VideoRowView(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                    .listStyle(.plain)
                }
            }

            
        }
        .onAppear {
            if viewModel.items.isEmpty {
                viewModel.load()
            }
        }
    }

    private func dismissOverlay() {
        withAnimation(.easeInOut(duration: 0.2)) {
            showOverlay = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            selectedItem = nil
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
                    Text(d.formatted(date: .abbreviated, time: .shortened))
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

struct PlayerLayerView: UIViewRepresentable {
    let url: URL
    // isPortraitHint: true -> fill, false -> fit, nil -> fit
    var isPortraitHint: Bool?

    func makeUIView(context: Context) -> PlayerContainerView {
        let v = PlayerContainerView()
        v.backgroundColor = .black
        v.player = AVPlayer(url: url)
        v.player?.play()
        applyGravity(on: v)
        return v
    }

    func updateUIView(_ uiView: PlayerContainerView, context: Context) {
        applyGravity(on: uiView)
    }

    private func applyGravity(on view: PlayerContainerView) {
        if let isPortrait = isPortraitHint {
            view.setVideoGravity(isPortrait ? .resizeAspectFill : .resizeAspect)
        } else {
            view.setVideoGravity(.resizeAspect)
        }
    }

    static func dismantleUIView(_ uiView: PlayerContainerView, coordinator: ()) {
        uiView.player?.pause()
    }
}

final class PlayerContainerView: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }

    var player: AVPlayer? {
        didSet { avLayer.player = player }
    }

    // Yardımcı: ana layer’ı AVPlayerLayer olarak döndür
    private var avLayer: AVPlayerLayer { layer as! AVPlayerLayer }

    func setVideoGravity(_ gravity: AVLayerVideoGravity) {
        avLayer.videoGravity = gravity
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        avLayer.frame = bounds
    }
}

// MARK: - YouTube iFrame tam ekran WebView
struct YouTubeWebViewFull: UIViewRepresentable {
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
        // Tam ekran iFrame
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
        <meta name="viewport" content="initial-scale=1, maximum-scale=1, user-scalable=no, width=device-width, height=device-height">
        <style>
        html, body { margin:0; padding:0; background:black; width:100%; height:100%; overflow:hidden; }
        #wrap { position:fixed; inset:0; }
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
