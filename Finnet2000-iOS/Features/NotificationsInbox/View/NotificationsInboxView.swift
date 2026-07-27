import SwiftUI

// MARK: - Model

enum InboxTab: String, CaseIterable, Identifiable {
    case watchlist  = "Takip Listesi"
    case portfolio  = "Portföy"
    case market     = "Piyasa & Ekonomi Gelişmeleri"
    case news       = "Haberler"
    case roboSepet  = "RoboSepet"
    case technical  = "Teknik Analiz"
    case general    = "Genel Duyuru"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .watchlist:  return "bookmark.fill"
        case .portfolio:  return "briefcase.fill"
        case .market:     return "chart.bar.fill"
        case .news:       return "newspaper.fill"
        case .roboSepet:  return "cpu.fill"
        case .technical:  return "waveform.path.ecg"
        case .general:    return "megaphone.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .watchlist:  return Color(red: 0.161, green: 0.749, blue: 0.451)
        case .portfolio:  return Color(red: 0.20, green: 0.53, blue: 0.90)
        case .market:     return Color(red: 0.95, green: 0.60, blue: 0.10)
        case .news:       return Color(red: 0.85, green: 0.25, blue: 0.25)
        case .roboSepet:  return Color(red: 0.55, green: 0.25, blue: 0.90)
        case .technical:  return Color(red: 0.10, green: 0.70, blue: 0.80)
        case .general:    return Color(red: 0.90, green: 0.45, blue: 0.10)
        }
    }
}

struct InboxNotification: Identifiable {
    let id: UUID
    let tab: InboxTab
    let title: String
    let body: String
    let date: Date
    let stockCode: String?
    let stockName: String?
    let priceText: String?
    let changeText: String?
    let gainers: [String]
    let losers: [String]
    var isRead: Bool
}

// MARK: - Sample Data

private func sampleNotifications() -> [InboxNotification] {
    let now = Date()
    func ago(_ minutes: Int) -> Date { now.addingTimeInterval(-Double(minutes) * 60) }
    func watchlistNotification(
        code: String,
        name: String,
        priceText: String,
        changeText: String,
        title: String,
        body: String,
        gainers: [String],
        losers: [String],
        date: Date,
        isRead: Bool
    ) -> InboxNotification {
        InboxNotification(
            id: UUID(),
            tab: .watchlist,
            title: title,
            body: body,
            date: date,
            stockCode: code,
            stockName: name,
            priceText: priceText,
            changeText: changeText,
            gainers: gainers,
            losers: losers,
            isRead: isRead
        )
    }

    return [
        // Takip Listesi
        watchlistNotification(
            code: "IEYHO",
            name: "Takip Listesi Özeti",
            priceText: "nil",
            changeText: "nil",
            title: "Takip Listesi Özeti",
            body: "Güncel takip listesi performans özeti",
            gainers: ["IEYHO +%3.72", "ASELS +%0.21"],
            losers: ["TKFEN -%9.76", "OBAMS -%3.94"],
            date: Calendar.current.date(from: DateComponents(year: 2026, month: 6, day: 5, hour: 21, minute: 8)) ?? ago(39000),
            isRead: false
        ),

        // Portföy
        InboxNotification(id: UUID(), tab: .portfolio, title: "Portföyünüz bugün %2.3 kazandı", body: "Toplam portföy değeriniz günlük bazda %2.3 artarak 48.750 ₺ seviyesine ulaştı.", date: ago(35), stockCode: nil, stockName: nil, priceText: nil, changeText: nil, gainers: [], losers: [], isRead: false),
        InboxNotification(id: UUID(), tab: .portfolio, title: "GARAN pozisyonunuz kâra geçti", body: "GARAN hissenizdeki pozisyonunuz alış fiyatının %6.5 üzerine çıktı.", date: ago(420), stockCode: nil, stockName: nil, priceText: nil, changeText: nil, gainers: [], losers: [], isRead: true),

        // Piyasa & Ekonomi
        InboxNotification(id: UUID(), tab: .market, title: "BIST 100 rekor kırdı", body: "BIST 100 endeksi 10.850 puanla tarihi zirvesini yeniledi.", date: ago(22), stockCode: nil, stockName: nil, priceText: nil, changeText: nil, gainers: [], losers: [], isRead: false),
        InboxNotification(id: UUID(), tab: .market, title: "Enflasyon verisi açıklandı", body: "TÜİK Nisan 2026 TÜFE verisini %68.50 olarak açıkladı. Piyasa beklentisinin altında geldi.", date: ago(95), stockCode: nil, stockName: nil, priceText: nil, changeText: nil, gainers: [], losers: [], isRead: false),
        InboxNotification(id: UUID(), tab: .market, title: "Fed faiz kararı", body: "ABD Merkez Bankası faizleri 25 baz puan indirdi. Gelişmekte olan piyasalar olumlu karşıladı.", date: ago(300), stockCode: nil, stockName: nil, priceText: nil, changeText: nil, gainers: [], losers: [], isRead: true),
        InboxNotification(id: UUID(), tab: .market, title: "Yeni halka arz: XYZ AŞ", body: "XYZ AŞ halka arz başvuruları 20-22 Mayıs tarihleri arasında alınacak.", date: ago(2880), stockCode: nil, stockName: nil, priceText: nil, changeText: nil, gainers: [], losers: [], isRead: true),

        // Haberler
        InboxNotification(id: UUID(), tab: .news, title: "SASA finansal sonuçları açıkladı", body: "SASA Polyester 2026 Q1 net kârını 3.2 milyar TL olarak açıkladı. Geçen yılın aynı dönemine göre %41 artış.", date: ago(55), stockCode: nil, stockName: nil, priceText: nil, changeText: nil, gainers: [], losers: [], isRead: false),
        InboxNotification(id: UUID(), tab: .news, title: "FROTO KAP açıklaması", body: "Ford Otosan, yeni model lansmanı için özel durum açıklaması yaptı.", date: ago(720), stockCode: nil, stockName: nil, priceText: nil, changeText: nil, gainers: [], losers: [], isRead: true),

        // RoboSepet
        InboxNotification(id: UUID(), tab: .roboSepet, title: "RoboSepet dağılımı güncellendi", body: "Büyüme sepetinizin hisse dağılımı piyasa koşullarına göre optimize edildi.", date: ago(200), stockCode: nil, stockName: nil, priceText: nil, changeText: nil, gainers: [], losers: [], isRead: false),

        // Teknik Analiz
        InboxNotification(id: UUID(), tab: .technical, title: "BIMAS destek kırılımı", body: "BİM Birleşik Mağazalar 45.20 ₺ destek seviyesini kırdı. Teknik görünüm bozuldu.", date: ago(18), stockCode: nil, stockName: nil, priceText: nil, changeText: nil, gainers: [], losers: [], isRead: false),
        InboxNotification(id: UUID(), tab: .technical, title: "KCHOL RSI aşırı satım", body: "Koç Holding RSI indikatörü 28 seviyesiyle aşırı satım bölgesine girdi.", date: ago(110), stockCode: nil, stockName: nil, priceText: nil, changeText: nil, gainers: [], losers: [], isRead: true),

        // Genel Duyuru
        InboxNotification(id: UUID(), tab: .general, title: "Uygulama güncellendi 🎉", body: "Finnet 2000 v3.2 yayında! Yeni bildirim merkezi ve gelişmiş teknik analiz araçları eklendi.", date: ago(60), stockCode: nil, stockName: nil, priceText: nil, changeText: nil, gainers: [], losers: [], isRead: false),
        InboxNotification(id: UUID(), tab: .general, title: "Bakım çalışması", body: "21 Mayıs 02:00–04:00 arasında planlı bakım nedeniyle hizmetlere kısa süre erişilemeycektir.", date: ago(1200), stockCode: nil, stockName: nil, priceText: nil, changeText: nil, gainers: [], losers: [], isRead: true),
    ]
}

// MARK: - Main View

private let inboxGreen = Color(red: 0.161, green: 0.749, blue: 0.451)

struct NotificationsInboxView: View {

    @State private var selectedTab: InboxTab = .watchlist
    @State private var notifications: [InboxNotification] = sampleNotifications()
    @State private var tabScrollProxy: ScrollViewProxy? = nil

    private var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }

    var body: some View {
        VStack(spacing: 0) {
            tabBar
            tabContent
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Bildirimler")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if unreadCount > 0 {
                    Button(action: markAllRead) {
                        Text("Tümünü Okundu")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(inboxGreen)
                    }
                }
            }
        }
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(InboxTab.allCases) { tab in
                        tabBarItem(tab)
                            .id(tab)
                    }
                }
                .padding(.horizontal, 12)
            }
            .background(Color.black)
            .onAppear { tabScrollProxy = proxy }
        }
    }

    @ViewBuilder
    private func tabBarItem(_ tab: InboxTab) -> some View {
        let isSelected = selectedTab == tab
        let tabUnread = notifications.filter { $0.tab == tab && !$0.isRead }.count

        Button(action: {
            withAnimation(.easeInOut(duration: 0.22)) {
                selectedTab = tab
                tabScrollProxy?.scrollTo(tab, anchor: .center)
            }
        }) {
            VStack(spacing: 0) {
                HStack(spacing: 5) {
                    Text(tab.rawValue)
                        .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                        .foregroundColor(isSelected ? .white : Color.white.opacity(0.55))
                        .lineLimit(1)

                    if tabUnread > 0 {
                        Text("\(tabUnread)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(inboxGreen, in: Capsule())
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 12)
                .padding(.bottom, 10)

                Rectangle()
                    .fill(isSelected ? inboxGreen : Color.clear)
                    .frame(height: 2.5)
                    .cornerRadius(2)
            }
        }
        .buttonStyle(.plain)
        .fixedSize(horizontal: true, vertical: false)
    }

    // MARK: - Tab Content

    private var tabContent: some View {
        TabView(selection: $selectedTab) {
            ForEach(InboxTab.allCases) { tab in
                notificationList(for: tab)
                    .tag(tab)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut(duration: 0.22), value: selectedTab)
        .onChange(of: selectedTab) { _, tab in
            withAnimation { tabScrollProxy?.scrollTo(tab, anchor: .center) }
        }
    }

    @ViewBuilder
    private func notificationList(for tab: InboxTab) -> some View {
        let items = notifications.filter { $0.tab == tab }
        if items.isEmpty {
            emptyState(for: tab)
        } else {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(items) { item in
                        notificationCard(item: item)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
    }

    @ViewBuilder
    private func emptyState(for tab: InboxTab) -> some View {
        VStack(spacing: 14) {
            Image(systemName: tab.iconName)
                .font(.system(size: 42, weight: .light))
                .foregroundColor(tab.accentColor.opacity(0.6))

            Text("Bildirim yok")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)

            Text("\(tab.rawValue) kategorisinde\nhenüz bildiriminiz bulunmuyor.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 60)
    }

    @ViewBuilder
    private func notificationCard(item: InboxNotification) -> some View {
        if item.tab == .watchlist {
            watchlistNotificationCard(item: item)
        } else {
            genericNotificationCard(item: item)
        }
    }

    @ViewBuilder
    private func watchlistNotificationCard(item: InboxNotification) -> some View {
        Button(action: { markRead(item) }) {
            VStack(alignment: .leading, spacing: 14) {

                // MARK: Başlık satırı
                HStack(alignment: .center, spacing: 0) {
                    Text("Takip Listesi Özeti")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color(UIColor.label))

                    HStack(spacing: 8) {
                        HStack(spacing: 3) {
                            Image(systemName: "arrow.up")
                                .font(.system(size: 11, weight: .semibold))
                            Text("\(item.gainers.count)")
                                .font(.system(size: 15, weight: .regular))
                        }
                        .foregroundColor(Color(red: 0.16, green: 0.50, blue: 0.29))

                        HStack(spacing: 3) {
                            Image(systemName: "arrow.down")
                                .font(.system(size: 11, weight: .semibold))
                            Text("\(item.losers.count)")
                                .font(.system(size: 15, weight: .regular))
                        }
                        .foregroundColor(Color(red: 0.72, green: 0.15, blue: 0.13))
                    }
                    .padding(.leading, 10)

                    Spacer(minLength: 8)

                    Text(formattedSummaryDate(item.date))
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                }

                // MARK: Yükselenler
                VStack(alignment: .leading, spacing: 8) {
                    Text("Yükselenler")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color(red: 0.16, green: 0.50, blue: 0.29))

                    summaryChipRow(items: item.gainers, kind: .gainer)
                }

                // MARK: Düşenler
                VStack(alignment: .leading, spacing: 8) {
                    Text("Düşenler")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color(red: 0.72, green: 0.15, blue: 0.13))

                    summaryChipRow(items: item.losers, kind: .loser)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color(UIColor.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color(UIColor.separator).opacity(0.4), lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func summaryChipRow(items: [String], kind: SummaryChipKind) -> some View {
        HStack(spacing: 10) {
            ForEach(items, id: \.self) { chip in
                let parts = chip.split(separator: " ", maxSplits: 1)
                HStack(spacing: 6) {
                    if parts.count > 0 {
                        Text(String(parts[0]))
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color(UIColor.label))
                    }
                    if parts.count > 1 {
                        Text(String(parts[1]))
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(kind.valueColor)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(kind.backgroundColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private func genericNotificationCard(item: InboxNotification) -> some View {
        Button(action: { markRead(item) }) {
            HStack(alignment: .top, spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(item.tab.accentColor.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: item.tab.iconName)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(item.tab.accentColor)
                }

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(item.title)
                            .font(.system(size: 14, weight: item.isRead ? .medium : .bold))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text(relativeTime(item.date))
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .fixedSize()
                    }

                    Text(item.body)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                // Unread dot
                if !item.isRead {
                    Circle()
                        .fill(inboxGreen)
                        .frame(width: 8, height: 8)
                        .padding(.top, 4)
                }
            }
            .padding(14)
            .background(Color(UIColor.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(item.isRead ? Color.clear : inboxGreen.opacity(0.25), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func markRead(_ item: InboxNotification) {
        if let idx = notifications.firstIndex(where: { $0.id == item.id }) {
            notifications[idx].isRead = true
        }
    }

    private func markAllRead() {
        for i in notifications.indices {
            notifications[i].isRead = true
        }
    }

    // MARK: - Helpers

    private func relativeTime(_ date: Date) -> String {
        let diff = Int(Date().timeIntervalSince(date) / 60)
        if diff < 1   { return "Az önce" }
        if diff < 60  { return "\(diff)dk" }
        if diff < 1440 { return "\(diff / 60)sa" }
        return "\(diff / 1440)g"
    }

    private func changeColor(for item: InboxNotification) -> Color {
        guard let changeText = item.changeText else { return .secondary }
        return changeText.trimmingCharacters(in: .whitespaces).hasPrefix("-") ? .red : inboxGreen
    }

    private func formattedSummaryDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return formatter.string(from: date)
    }
}

private enum SummaryChipKind {
    case gainer
    case loser

    // Soluk yeşil: #E6F4EC  /  soluk kırmızı: #FAE9E9
    var backgroundColor: Color {
        switch self {
        case .gainer: return Color(red: 0.902, green: 0.957, blue: 0.925)
        case .loser:  return Color(red: 0.980, green: 0.914, blue: 0.914)
        }
    }

    // Koyu yeşil: #1A7A42  /  koyu kırmızı: #B42318
    var valueColor: Color {
        switch self {
        case .gainer: return Color(red: 0.102, green: 0.478, blue: 0.259)
        case .loser:  return Color(red: 0.706, green: 0.137, blue: 0.094)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        NotificationsInboxView()
    }
}
