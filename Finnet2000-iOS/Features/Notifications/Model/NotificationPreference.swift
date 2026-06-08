import Foundation

struct NotificationCategory: Identifiable {
    let id: String
    let title: String
    let description: String
    var items: [NotificationItem]
}

struct NotificationItem: Identifiable {
    let id: String
    let title: String
    let description: String
    var isEnabled: Bool
}

struct NotificationAlertInfo: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}
