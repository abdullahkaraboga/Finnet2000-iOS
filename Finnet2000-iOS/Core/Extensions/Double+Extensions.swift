import Foundation

extension Double {
    var asString: String {
        compactString()
    }

    func compactString(fractionDigits: Int = 2) -> String {
        compactString(fractionDigits: fractionDigits, currencySymbol: nil)
    }

    func compactCurrencyString(fractionDigits: Int = 2) -> String {
        compactString(fractionDigits: fractionDigits, currencySymbol: "₺")
    }

    private func compactString(fractionDigits: Int, currencySymbol: String?) -> String {
        if self.isNaN || self.isInfinite { return "-" }

        let absoluteValue = abs(self)
        let scale: Double
        let suffix: String

        if absoluteValue >= 1_000_000_000 {
            scale = 1_000_000_000
            suffix = "Mr"
        } else if absoluteValue >= 1_000_000 {
            scale = 1_000_000
            suffix = "Mn"
        } else if absoluteValue >= 1_000 {
            scale = 1_000
            suffix = "Bin"
        } else {
            scale = 1
            suffix = ""
        }

        let scaledValue = self / scale
        let formatter = NumberFormatter.f2000DecimalFormatter(fractionDigits: fractionDigits)
        let number = formatter.string(from: NSNumber(value: scaledValue))
            ?? String(format: "%.\(fractionDigits)f", scaledValue).replacingOccurrences(of: ".", with: ",")

        if let currencySymbol {
            return suffix.isEmpty ? "\(number) \(currencySymbol)" : "\(number) \(suffix) \(currencySymbol)"
        }

        return suffix.isEmpty ? number : "\(number) \(suffix)"
    }
}
