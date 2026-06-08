import Foundation
import Combine

@MainActor
final class RegisterViewModel: ObservableObject {

    // MARK: - Step 1 fields
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""

    // MARK: - Step 2 fields
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var emailNotifications: Bool = true
    @Published var kvkkAccepted: Bool = false

    // MARK: - Step 1 live validation
    var firstNameValid: Bool {
        let regex = /^[A-Za-zÇçĞğİıÖöŞşÜü]{2,}$/
        return (try? regex.wholeMatch(in: firstName)) != nil
    }
    var lastNameValid: Bool {
        let regex = /^[A-Za-zÇçĞğİıÖöŞşÜü]{2,}$/
        return (try? regex.wholeMatch(in: lastName)) != nil
    }
    var emailValid: Bool {
        let regex = /^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$/
        return (try? regex.wholeMatch(in: email)) != nil
    }

    // MARK: - Step 2 live validation
    var hasLetter: Bool    { password.contains(where: { $0.isLetter }) }
    var hasDigit: Bool     { password.contains(where: { $0.isNumber }) }
    var hasMixedCase: Bool {
        password.contains(where: { $0.isUppercase }) &&
        password.contains(where: { $0.isLowercase })
    }
    var hasSpecial: Bool {
        let specials = CharacterSet.alphanumerics.inverted
        return !password.unicodeScalars.filter({ specials.contains($0) }).isEmpty
    }
    var isValidLength: Bool  { password.count >= 8 && password.count <= 16 }
    var noSpaces: Bool       { !password.contains(" ") }
    var passwordsMatch: Bool { !password.isEmpty && password == confirmPassword }

    // MARK: - Step validation (used by button)
    func validateStep1() -> Bool {
        firstNameValid && lastNameValid && emailValid
    }

    func validateStep2() -> Bool {
        hasLetter && hasDigit && hasMixedCase && hasSpecial && isValidLength && noSpaces && passwordsMatch
    }
}
