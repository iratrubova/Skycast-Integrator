import Foundation
import Combine
import CoreData  
import AuthenticationServices
import CryptoKit

enum AuthProvider: String, CaseIterable, Codable {  // ADD Codable
    case email = "email"
    case google = "google"
    case facebook = "facebook"
}

enum AuthError: Error {
    case invalidCredentials
    case userNotFound
    case emailAlreadyExists
    case socialAuthFailed
    case networkError
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .invalidCredentials: return "Invalid email or password"
        case .userNotFound: return "User not found"
        case .emailAlreadyExists: return "Email already registered"
        case .socialAuthFailed: return "Social authentication failed"
        case .networkError: return "Network error. Please try again"
        case .unknown: return "An unknown error occurred"
        }
    }
}

struct AuthUser: Codable {  // Codable at declaration
    let id: String
    let email: String
    let name: String
    let provider: AuthProvider  // Now Codable too
    let providerId: String
}

final class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var currentUser: AuthUser?
    @Published var isAuthenticated = false
    
    private let coreDataStack = CoreDataStack.shared
    private let baseURL = "https://your-backend-api.com/auth"
    
    private init() {
        checkSavedSession()
    }
    
  
    
    // MARK: - Email Authentication
    
    func signInWithEmail(email: String, password: String) async throws -> AuthUser {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        let request = NSFetchRequest<UserEntity>(entityName: "UserEntity")
        request.predicate = NSPredicate(format: "email == %@ AND provider == %@", email, AuthProvider.email.rawValue)
        
        let users = try? coreDataStack.context.fetch(request)
        
        guard let userEntity = users?.first else {
            throw AuthError.userNotFound
        }
        
        let authUser = AuthUser(
            id: userEntity.id?.uuidString ?? UUID().uuidString,
            email: userEntity.email ?? "",
            name: userEntity.name ?? "",
            provider: .email,
            providerId: userEntity.email ?? ""
        )
        
        await MainActor.run {
            self.currentUser = authUser
            self.isAuthenticated = true
            self.saveSession(user: authUser)
        }
        
        return authUser
    }
    
    func signUpWithEmail(email: String, password: String, name: String) async throws -> AuthUser {
        let request = NSFetchRequest<UserEntity>(entityName: "UserEntity")
        request.predicate = NSPredicate(format: "email == %@", email)
        
        let existingUsers = try? coreDataStack.context.fetch(request)
        guard existingUsers?.isEmpty ?? true else {
            throw AuthError.emailAlreadyExists
        }
        
        let userEntity = UserEntity(context: coreDataStack.context)
        userEntity.id = UUID()
        userEntity.email = email
        userEntity.name = name
        userEntity.provider = AuthProvider.email.rawValue
        userEntity.providerId = email
        userEntity.createdAt = Date()
        
        coreDataStack.save()
        
        let authUser = AuthUser(
            id: userEntity.id?.uuidString ?? UUID().uuidString,
            email: email,
            name: name,
            provider: .email,
            providerId: email
        )
        
        await MainActor.run {
            self.currentUser = authUser
            self.isAuthenticated = true
            self.saveSession(user: authUser)
        }
        
        return authUser
    }
    
    // MARK: - Social Login
    
    func signInWithGoogle() async throws -> AuthUser {
        let authURL = URL(string: "https://accounts.google.com/o/oauth2/v2/auth?client_id=YOUR_GOOGLE_CLIENT_ID&redirect_uri=yourapp://oauth&response_type=code&scope=email%20profile")!
        return try await performOAuthSignIn(url: authURL, provider: .google)
    }
    
    func signInWithFacebook() async throws -> AuthUser {
        let authURL = URL(string: "https://www.facebook.com/v18.0/dialog/oauth?client_id=YOUR_FACEBOOK_APP_ID&redirect_uri=yourapp://oauth&scope=email,public_profile")!
        return try await performOAuthSignIn(url: authURL, provider: .facebook)
    }
    
    private func performOAuthSignIn(url: URL, provider: AuthProvider) async throws -> AuthUser {
        #if os(iOS)
        await MainActor.run {
            UIApplication.shared.open(url)
        }
        #elseif os(macOS)
        await MainActor.run {
            NSWorkspace.shared.open(url)
        }
        #endif
        
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        let authUser = AuthUser(
            id: UUID().uuidString,
            email: "user@\(provider.rawValue).com",
            name: "Test \(provider.rawValue.capitalized) User",
            provider: provider,
            providerId: "123456"
        )
        
        await MainActor.run {
            self.saveSocialUser(authUser)
            self.currentUser = authUser
            self.isAuthenticated = true
            self.saveSession(user: authUser)
        }
        
        return authUser
    }
    
    // MARK: - Session Management
    
    func signOut() async throws {
        await MainActor.run {
            self.currentUser = nil
            self.isAuthenticated = false
            UserDefaults.standard.removeObject(forKey: "currentUser")
        }
    }
    
    func getCurrentUser() -> AuthUser? {
        return currentUser
    }
    
    private func saveSession(user: AuthUser) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        }
    }
    
    private func checkSavedSession() {
        guard let data = UserDefaults.standard.data(forKey: "currentUser"),
              let user = try? JSONDecoder().decode(AuthUser.self, from: data) else {
            return
        }
        self.currentUser = user
        self.isAuthenticated = true
    }
    
    private func saveSocialUser(_ authUser: AuthUser) {
        let request = NSFetchRequest<UserEntity>(entityName: "UserEntity")
        request.predicate = NSPredicate(format: "providerId == %@ AND provider == %@", authUser.providerId, authUser.provider.rawValue)
        
        let existing = try? coreDataStack.context.fetch(request)
        
        if existing?.isEmpty ?? true {
            let userEntity = UserEntity(context: coreDataStack.context)
            userEntity.id = UUID(uuidString: authUser.id) ?? UUID()
            userEntity.email = authUser.email
            userEntity.name = authUser.name
            userEntity.provider = authUser.provider.rawValue
            userEntity.providerId = authUser.providerId
            userEntity.createdAt = Date()
            coreDataStack.save()
        }
    }
}
