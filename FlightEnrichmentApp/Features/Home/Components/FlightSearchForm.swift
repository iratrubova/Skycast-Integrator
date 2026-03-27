import SwiftUI

struct FlightSearchForm: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Origin
            VStack(alignment: .leading, spacing: 8) {
                Label("From", systemImage: "airplane.departure")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextField("Departure City", text: $viewModel.origin)
                    .textFieldStyle(RoundedTextFieldStyle())
                    #if os(iOS)
                    .textInputAutocapitalization(.words)
                    #endif
            }
            
            // Destination
            VStack(alignment: .leading, spacing: 8) {
                Label("To", systemImage: "airplane.arrival")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextField("Destination City", text: $viewModel.destination)
                    .textFieldStyle(RoundedTextFieldStyle())
                    #if os(iOS)
                    .textInputAutocapitalization(.words)
                    #endif
            }
            
            // Dates
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Departure", systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    DatePicker(
                        "",
                        selection: $viewModel.departureDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Label("Return (Optional)", systemImage: "arrow.uturn.left")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    DatePicker(
                        "",
                        selection: Binding(
                            get: { viewModel.returnDate ?? Date() },
                            set: { viewModel.returnDate = $0 }
                        ),
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .overlay(
                        Group {
                            if viewModel.returnDate == nil {
                                Button("") {
                                    viewModel.returnDate = viewModel.departureDate.addingTimeInterval(86400 * 7)
                                }
                                .font(.caption)
                                .foregroundColor(.white)
                                .opacity(0.5)
                            }
                        }
                    )
                }
            }
            
            // Currency Selection
            VStack(alignment: .leading, spacing: 8) {
                Label("Your Currency", systemImage: "dollarsign.circle")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Picker("Currency", selection: $viewModel.userCurrency) {
                    Text("USD ($)").tag("USD")
                    Text("EUR (€)").tag("EUR")
                    Text("GBP (£)").tag("GBP")
                    Text("JPY (¥)").tag("JPY")
                }
                .pickerStyle(.segmented)
            }
            
            // Search Button
            Button(action: {
                Task {
                    await viewModel.searchFlight()
                }
            }) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "magnifyingglass")
                    }
                    
                    Text(viewModel.isLoading ? "Enriching..." : "Enrich My Flight")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: viewModel.canSearch ? [.blue, .blue.opacity(0.8)] : [.gray, .gray.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .disabled(!viewModel.canSearch || viewModel.isLoading)
            .padding(.top, 10)
        }
        .padding()
        .background(Color.appBackground)  // Use our cross-platform color
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(Color.gray.opacity(0.1))  // Cross-platform background
            .cornerRadius(10)
    }
}

#Preview {
    HomeView()
}
