import Foundation

struct FilteredStockItem: Decodable {
    let code: String
    let logoPath: String?
    let name: String?
    let date: String?
    let value: Double?
    let price: Double?

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        code     = try c.decode(String.self, forKey: .code)
        logoPath = try c.decodeIfPresent(String.self, forKey: .logoPath)
        name     = try c.decodeIfPresent(String.self, forKey: .name)
        date     = try c.decodeIfPresent(String.self, forKey: .date)
        
        do {
            value = try c.decodeIfPresent(Double.self, forKey: .value)
        } catch {
            print("Failed to decode value for \(code)")
            value = nil
        }
        
        do {
            price = try c.decodeIfPresent(Double.self, forKey: .price)
        } catch {
            print("Failed to decode price for \(code)")
            price = nil
        }
    }

    private enum CodingKeys: String, CodingKey {
        case code, logoPath, name, date, value, price
    }
}

do {
    let data = try Data(contentsOf: URL(fileURLWithPath: "response.json"))
    let items = try JSONDecoder().decode([FilteredStockItem].self, from: data)
    print("Success: decoded \(items.count) items")
} catch {
    print("Error:", error)
}
