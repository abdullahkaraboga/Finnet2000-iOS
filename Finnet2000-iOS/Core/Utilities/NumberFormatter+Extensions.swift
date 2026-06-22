import Foundation

extension NumberFormatter {
	static func f2000DecimalFormatter(fractionDigits: Int = 2) -> NumberFormatter {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.minimumFractionDigits = fractionDigits
		formatter.maximumFractionDigits = fractionDigits
		formatter.groupingSeparator = "."
		formatter.decimalSeparator = ","
		return formatter
	}
}
