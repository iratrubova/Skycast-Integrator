import SwiftUI

struct AccountView: View {
    @StateObject private var viewModel = AccountViewModel()
    @EnvironmentObject private var authService: AuthService
    
    var body: some View {
        NavigationView {
            List {
                if let user = authService.currentUser {
                    Section {
                        HStack(spacing: 16) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.name)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                                Text(user.email)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text("Signed in with \(user.provider.rawValue.capitalized)")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(4)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    Section {
                        Button(role: .destructive) {
                            Task {
                                await viewModel.signOut()
                            }
                        } label: {
                            Label("Log Out", systemImage: "arrow.left.circle")
                        }
                    }
                } else {
                    Section {
                        VStack(spacing: 20) {
                            Image(systemName: "person.crop.circle.badge.exclamationmark")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                            
                            Text("Not Logged In")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    }
                    .listRowBackground(Color.clear)
                }
                
                Section("About") {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Data Enrichment", systemImage: "sparkles")
                        Spacer()
                        Text("Active")
                            .foregroundColor(.green)
                    }
                }
            }
            .navigationTitle("Account")
        }
        #if os(macOS)
        .frame(minWidth: 400, minHeight: 500)
        #endif
    }
}

#Preview {
    AccountView()
        .environmentObject(AuthService.shared)
}
