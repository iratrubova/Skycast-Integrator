//
//  RegisterViewModel.swift
//  schoolLF8
//
//  Created by Iryna Radionova on 26.03.26.
//

import Foundation
import Combine

@MainActor
final class RegisterViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var showSuccess = false
    @Published var errorMessage = ""
    
    private let authService = AuthService.shared
    
    var isValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        email.contains("@") &&
        password.count >= 6 &&
        password == confirmPassword
    }
    
    func signUp() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            _ = try await authService.signUpWithEmail(email: email, password: password, name: name)
            showSuccess = true
        } catch let error as AuthError {
            errorMessage = error.localizedDescription
            showError = true
        } catch {
            errorMessage = "An unexpected error occurred"
            showError = true
        }
    }
}
