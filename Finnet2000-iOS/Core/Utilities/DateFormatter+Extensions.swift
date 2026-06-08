import Foundation

// MARK: - Uygulama Geneli Tarih Formatı  (dd/MM/yyyy)

extension DateFormatter {
    /// Finnet2000 standart görüntü formatı: 08/05/2026
    static let f2000Display: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        df.locale = Locale(identifier: "tr_TR")
        return df
    }()
}

extension Date {
    /// Tarihi dd/MM/yyyy formatında string'e dönüştürür.
    var f2000Formatted: String {
        DateFormatter.f2000Display.string(from: self)
    }
}

extension String {
    /// ISO 8601 veya "yyyy-MM-dd" string'ini dd/MM/yyyy formatına çevirir.
    /// Dönüşüm başarısız olursa orijinal string döner.
    var f2000Formatted: String {
        // ISO 8601 (with fractional seconds)
        if let date = ISO8601DateFormatter.f2000.date(from: self) {
            return date.f2000Formatted
        }
        // ISO 8601 (without fractional seconds)
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime]
        if let date = iso.date(from: self) {
            return date.f2000Formatted
        }
        // yyyy-MM-dd (API düz tarih formatı)
        let simple = DateFormatter()
        simple.dateFormat = "yyyy-MM-dd"
        if let date = simple.date(from: self) {
            return date.f2000Formatted
        }
        return self
    }
}
