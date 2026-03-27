//
//  LoginViewModel.swift
//  schoolLF8
//
//  Created by Iryna Radionova on 26.03.26.
//
import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let authService = AuthService.shared
    
    var isValid: Bool {
        !email.isEmpty && email.contains("@") && password.count >= 6
    }
    
    func signIn() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            _ = try await authService.signInWithEmail(email: email, password: password)
        } catch let error as AuthError {
            errorMessage = error.localizedDescription
            showError = true
        } catch {
            errorMessage = "An unexpected error occurred"
            showError = true
        }
    }
    
    func signInWithGoogle() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            _ = try await authService.signInWithGoogle()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    func signInWithFacebook() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            _ = try await authService.signInWithFacebook()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
