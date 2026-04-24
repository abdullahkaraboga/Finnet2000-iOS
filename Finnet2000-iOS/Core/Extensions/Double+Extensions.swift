import Foundation

extension Double {
    var asString: String {
        if self.isNaN || self.isInfinite { return "-" }
        if abs(self) > 1_000_000_000 {
            return String(format: "%.2f Mr ₺", self / 1_000_000_000)
        } else if abs(self) > 1_000_000 {
            return String(format: "%.2f Mn ₺", self / 1_000_000)
        } else {
            return String(format: "%.2f ₺", self)
        }
    }
}
