import Foundation
import Combine

final class NotificationPreferencesViewModel: ObservableObject {

    @Published var categories: [NotificationCategory] = NotificationPreferencesViewModel.defaultCategories()
    @Published var isSaved: Bool = false

    // MARK: - Select All / Deselect All

    func selectAll() {
        for i in categories.indices {
            for j in categories[i].items.indices {
                categories[i].items[j].isEnabled = true
            }
        }
    }

    func deselectAll() {
        for i in categories.indices {
            for j in categories[i].items.indices {
                categories[i].items[j].isEnabled = false
            }
        }
    }

    // MARK: - Save

    func save() {
        // TODO: API çağrısı veya UserDefaults kaydı buraya eklenecek
        isSaved = true
    }

    // MARK: - Default Data

    static func defaultCategories() -> [NotificationCategory] {
        [
            NotificationCategory(
                id: "watchlist",
                title: "Takip Listesi",
                description: "Takip listenize eklenen hisselere ait getiri ve fiyat değişim bildirimlerini yönetin.",
                items: [
                    NotificationItem(
                        id: "watchlist_getiri",
                        title: "Getiri",
                        description: "Takip listenizdeki hisselerin günlük getiri değişimlerine ait bildirimler.",
                        isEnabled: true
                    )
                ]
            ),
            NotificationCategory(
                id: "portfolio",
                title: "Portföy",
                description: "Portföyünüzdeki varlıklara ait bildirim tercihlerini yönetin.",
                items: [
                    NotificationItem(
                        id: "portfolio_getiri",
                        title: "Getiri",
                        description: "Portföyünüzdeki hisselerin getiri değişimlerine ait bildirimler.",
                        isEnabled: true
                    )
                ]
            ),
            NotificationCategory(
                id: "market",
                title: "Piyasa & Ekonomi Gelişmeleri",
                description: "Piyasa ve makroekonomik gelişmelere ait bildirim tercihlerini yönetin.",
                items: [
                    NotificationItem(
                        id: "market_endeks",
                        title: "Endeks Getiri",
                        description: "BIST100, BIST30 gibi borsa endekslerinin getiri değişim bildirimleri.",
                        isEnabled: true
                    ),
                    NotificationItem(
                        id: "market_halka_arz",
                        title: "Halka Arz",
                        description: "Yeni halka arz başvuruları ve sonuçlarına ait duyurular.",
                        isEnabled: true
                    ),
                    NotificationItem(
                        id: "market_makro",
                        title: "Makro Veriler",
                        description: "Enflasyon, işsizlik ve büyüme gibi makroekonomik veri açıklamaları.",
                        isEnabled: true
                    ),
                    NotificationItem(
                        id: "market_merkez",
                        title: "Merkez Bankası Kararları",
                        description: "Merkez bankası para politikası ve faiz kararı bildirimleri.",
                        isEnabled: true
                    ),
                    NotificationItem(
                        id: "market_kuresel",
                        title: "Küresel Gelişmeler",
                        description: "Küresel piyasaları ve ekonomiyi etkileyen önemli gelişme bildirimleri.",
                        isEnabled: true
                    )
                ]
            ),
            NotificationCategory(
                id: "news",
                title: "Haberler",
                description: "Şirkete özel ve sektörel haber bildirim tercihlerini yönetin.",
                items: [
                    NotificationItem(
                        id: "news_finansal",
                        title: "Finansal Rapor Açıklaması",
                        description: "Şirketlerin bilanço, gelir tablosu ve finansal rapor açıklamaları.",
                        isEnabled: true
                    ),
                    NotificationItem(
                        id: "news_kap",
                        title: "KAP Özel Durum Açıklamaları",
                        description: "KAP sistemine bildirilen özel durum ve önemli açıklamalar.",
                        isEnabled: true
                    ),
                    NotificationItem(
                        id: "news_temettu",
                        title: "Temettü Duyuruları",
                        description: "Şirketlerin temettü dağıtım kararları ve ödeme tarihleri.",
                        isEnabled: false
                    ),
                    NotificationItem(
                        id: "news_sermaye",
                        title: "Sermaye Artırımı",
                        description: "Şirketlerin bedelli veya bedelsiz sermaye artırım duyuruları.",
                        isEnabled: false
                    ),
                    NotificationItem(
                        id: "news_sektorel",
                        title: "Sektörel Haberler",
                        description: "Takip ettiğiniz şirketlerin sektörüne özel haber ve gelişme bildirimleri.",
                        isEnabled: false
                    )
                ]
            ),
            NotificationCategory(
                id: "robosepet",
                title: "RoboSepet",
                description: "RoboSepet portföyünüze ait bildirim tercihlerini yönetin.",
                items: [
                    NotificationItem(
                        id: "robosepet_getiri",
                        title: "Getiri",
                        description: "RoboSepet portföyünüzün günlük getiri değişim bildirimleri.",
                        isEnabled: false
                    ),
                    NotificationItem(
                        id: "robosepet_dagilim",
                        title: "Dağılım Güncellemesi",
                        description: "RoboSepet portföy dağılımında yapılan güncelleme bildirimleri.",
                        isEnabled: false
                    )
                ]
            ),
            NotificationCategory(
                id: "technical",
                title: "Teknik Analiz",
                description: "Teknik analiz tabanlı sinyal ve uyarı bildirim tercihlerini yönetin.",
                items: [
                    NotificationItem(
                        id: "tech_formasyon",
                        title: "Formasyon Uyarıları",
                        description: "Hisse grafiklerinde oluşan teknik formasyon uyarıları (omuz-baş-omuz, üçgen vb.).",
                        isEnabled: false
                    ),
                    NotificationItem(
                        id: "tech_indiktor",
                        title: "İndikatör Bazlı Sinyaller",
                        description: "RSI, MACD, Bollinger Bandı gibi teknik indikatörlere dayalı sinyal bildirimleri.",
                        isEnabled: false
                    ),
                    NotificationItem(
                        id: "tech_destek",
                        title: "Destek/Direnç Kırılımı",
                        description: "Hisse senetlerinin önemli destek veya direnç seviyelerini kırdığında gönderilen bildirimler.",
                        isEnabled: false
                    ),
                    NotificationItem(
                        id: "tech_trend",
                        title: "Trend Değişimi Uyarıları",
                        description: "Hisse senetlerinde yükseliş veya düşüş trendinin değiştiğine dair uyarı bildirimleri.",
                        isEnabled: false
                    ),
                    NotificationItem(
                        id: "tech_kisa_vadeli",
                        title: "Kısa Vadeli Al/Sat Sinyalleri",
                        description: "Kısa vadeli teknik analiz yöntemlerine dayalı alım ve satım sinyal bildirimleri.",
                        isEnabled: false
                    ),
                    NotificationItem(
                        id: "tech_analist",
                        title: "Analist Teknik Görüşleri",
                        description: "Finnet analistlerinin hisse senetlerine ait teknik görüş ve yorum bildirimleri.",
                        isEnabled: false
                    )
                ]
            )
        ]
    }
}
