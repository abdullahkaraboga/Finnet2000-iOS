import Foundation

enum AppConfig {
	static let apiBaseURL = "https://api.finnet2000.com"

	enum Endpoints {
		static let contentsBasePath = "/api/Contents"
		static let loginPath = "/api/Authorization/Login"
		static let refreshPath = "/api/Authorization/RefreshToken"
		static let homePagePath = "/api/HomePage/HomePage"
	}
}
