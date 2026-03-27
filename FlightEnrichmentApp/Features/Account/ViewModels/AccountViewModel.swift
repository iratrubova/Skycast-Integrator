import Foundation
import Combine

@MainActor
final class AccountViewModel: ObservableObject {
    private let authService = AuthService.shared
    
    func signOut() async {
        do {
            try await authService.signOut()
        } catch {
            print("Failed to sign out: \(error)")
        }
    }
}
