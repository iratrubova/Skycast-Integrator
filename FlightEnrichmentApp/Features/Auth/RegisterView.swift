import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    VStack(spacing: 16) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 80))
                            .foregroundStyle(.green.gradient)
                        
                        Text("Create Account")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Start your journey with us")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    
                    VStack(spacing: 20) {
                        TextField("Full Name", text: $viewModel.name)
                            .textFieldStyle(RoundedTextFieldStyle())
                            #if os(iOS)
                            .textInputAutocapitalization(.words)
                            #endif
                        
                        TextField("Email", text: $viewModel.email)
                            .textFieldStyle(RoundedTextFieldStyle())
                            #if os(iOS)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            #endif
                        
                        SecureField("Password", text: $viewModel.password)
                            .textFieldStyle(RoundedTextFieldStyle())
                        
                        SecureField("Confirm Password", text: $viewModel.confirmPassword)
                            .textFieldStyle(RoundedTextFieldStyle())
                    }
                    .padding(.horizontal)
                    
                    if !viewModel.password.isEmpty {
                        PasswordStrengthView(password: viewModel.password)
                            .padding(.horizontal)
                    }
                    
                    Button(action: {
                        Task {
                            await viewModel.signUp()
                        }
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "person.badge.plus")
                            }
                            Text("Create Account")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: viewModel.isValid ? [.green, .green.opacity(0.8)] : [.gray],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .disabled(!viewModel.isValid || viewModel.isLoading)
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .alert("Success", isPresented: $viewModel.showSuccess) {
            Button("Continue", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("Your account has been created successfully!")
        }
    }
}

struct PasswordStrengthView: View {
    let password: String
    
    var strength: PasswordStrength {
        if password.count < 6 { return .weak }
        let hasUppercase = password.rangeOfCharacter(from: .uppercaseLetters) != nil
        let hasNumbers = password.rangeOfCharacter(from: .decimalDigits) != nil
        let hasSpecial = password.rangeOfCharacter(from: .punctuationCharacters) != nil
        
        if hasUppercase && hasNumbers && password.count >= 8 {
            return .strong
        }
        if (hasUppercase || hasNumbers) && password.count >= 6 {
            return .medium
        }
        return .weak
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Password Strength")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Rectangle()
                        .fill(barColor(for: index))
                        .frame(height: 4)
                        .cornerRadius(2)
                }
            }
            
            Text(strength.description)
                .font(.caption)
                .foregroundColor(strength.color)
        }
    }
    
    func barColor(for index: Int) -> Color {
        switch strength {
        case .weak:
            return index == 0 ? .red : Color.gray.opacity(0.3)
        case .medium:
            return index <= 1 ? .yellow : Color.gray.opacity(0.3)
        case .strong:
            return .green
        }
    }
}

enum PasswordStrength {
    case weak, medium, strong
    
    var color: Color {
        switch self {
        case .weak: return .red
        case .medium: return .yellow
        case .strong: return .green
        }
    }
    
    var description: String {
        switch self {
        case .weak: return "Weak"
        case .medium: return "Medium"
        case .strong: return "Strong"
        }
    }
}

#Preview {
    RegisterView()
}
