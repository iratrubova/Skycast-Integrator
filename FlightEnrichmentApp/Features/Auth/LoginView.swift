//
//  LoginView.swift
//  schoolLF8
//
//  Created by Iryna Radionova on 26.03.26.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject private var authService: AuthService
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "airplane.circle.fill")
                                .font(.system(size: 80))
                                .foregroundStyle(.blue.gradient)
                            
                            Text("Welcome Back")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Sign in to continue planning your trips")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 40)
                        
                        // Form
                        VStack(spacing: 20) {
                            TextField("Email", text: $viewModel.email)
                                .textFieldStyle(RoundedTextFieldStyle())
                                #if os(iOS)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                #endif
                            
                            SecureField("Password", text: $viewModel.password)
                                .textFieldStyle(RoundedTextFieldStyle())
                        }
                        .padding(.horizontal)
                        
                        // Sign In Button
                        Button(action: {
                            Task {
                                await viewModel.signIn()
                            }
                        }) {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "arrow.right.circle")
                                }
                                Text("Sign In")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: viewModel.isValid ? [.blue, .blue.opacity(0.8)] : [.gray],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                        .disabled(!viewModel.isValid || viewModel.isLoading)
                        .padding(.horizontal)
                        
                        // Divider
                        HStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                            Text("OR")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                        }
                        .padding(.horizontal)
                        
                        // Social Login
                        VStack(spacing: 12) {
                            SocialButton(
                                title: "Continue with Google",
                                icon: "g.circle.fill",
                                color: .red,
                                action: {
                                    Task {
                                        await viewModel.signInWithGoogle()
                                    }
                                }
                            )
                            
                            SocialButton(
                                title: "Continue with Facebook",
                                icon: "f.circle.fill",
                                color: .blue,
                                action: {
                                    Task {
                                        await viewModel.signInWithFacebook()
                                    }
                                }
                            )
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        // Register Link
                        HStack {
                            Text("Don't have an account?")
                                .foregroundColor(.secondary)
                            NavigationLink(destination: RegisterView()) {
                                Text("Sign Up")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

struct SocialButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Text(title)
                    .fontWeight(.medium)
                
                Spacer()
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthService.shared)
}
