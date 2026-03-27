import SwiftUI

struct RecentFlightsView: View {
    @StateObject private var viewModel = RecentFlightsViewModel()
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.flights.isEmpty {
                    Section {
                        VStack(spacing: 20) {
                            Image(systemName: "airplane.slash")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary)
                            
                            Text("No Flights Yet")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text("Your enriched flight history will appear here")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                        .listRowBackground(Color.clear)
                    }
                } else {
                    ForEach(viewModel.flights, id: \.id) { flight in
                        FlightRow(
                            flight: flight,
                            enrichment: viewModel.getEnrichment(for: flight)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.selectedFlight = flight
                            viewModel.showDetail = true
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            viewModel.deleteFlight(viewModel.flights[index])
                        }
                    }
                }
            }
            #if os(iOS)
            .listStyle(.insetGrouped)
            #else
            .listStyle(.plain)
            #endif
            .navigationTitle("Recent Flights")
            .refreshable {
                viewModel.fetchFlights()
            }
            .sheet(isPresented: $viewModel.showDetail) {
                if let flight = viewModel.selectedFlight {
                    FlightDetailSheet(
                        flight: flight,
                        enrichment: viewModel.getEnrichment(for: flight)
                    )
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 800, minHeight: 600)
        #endif
    }
}

struct FlightRow: View {
    let flight: FlightEntity
    let enrichment: EnrichmentDataEntity?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(flight.origin ?? "Unknown")
                    .font(.headline)
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
                
                Text(flight.destination ?? "Unknown")
                    .font(.headline)
                
                Spacer()
                
                if enrichment != nil {
                    Image(systemName: "sparkles")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
            }
            
            HStack(spacing: 16) {
                Label(
                    flight.departureDate?.formatted(date: .abbreviated, time: .omitted) ?? "N/A",
                    systemImage: "calendar"
                )
                .font(.caption)
                .foregroundColor(.secondary)
                
                if let temp = enrichment?.weatherTemp {
                    Label(
                        "\(Int(temp))°",
                        systemImage: "cloud"
                    )
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                
                if let currency = enrichment?.currencyCode {
                    Text(currency)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.green)
                        .cornerRadius(4)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct FlightDetailSheet: View {
    let flight: FlightEntity
    let enrichment: EnrichmentDataEntity?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text("\(flight.origin ?? "") → \(flight.destination ?? "")")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(flight.departureDate?.formatted() ?? "")
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    if let enrichment = enrichment {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Weather", systemImage: "cloud.sun")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            HStack {
                                Text("\(Int(enrichment.weatherTemp))°")
                                    .font(.title)
                                Text(enrichment.weatherCondition ?? "")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Exchange Rate", systemImage: "dollarsign.circle")
                                .font(.headline)
                                .foregroundColor(.green)
                            
                            Text("1 \(enrichment.currencyCode ?? "") = \(String(format: "%.2f", enrichment.exchangeRate))")
                                .font(.title3)
                            
                            Text("Example: \(String(format: "%.0f", enrichment.localPriceExample)) local = \(String(format: "%.2f", enrichment.localPriceExample * enrichment.exchangeRate)) your currency")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                        
                        if let placesJSON = enrichment.placesJSON,
                           !placesJSON.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Saved Places", systemImage: "star")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                                
                                Text("Data stored in JSON format")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(12)
                        }
                    } else {
                        #if os(iOS)
                        ContentUnavailableView(
                            "No Enrichment Data",
                            systemImage: "exclamationmark.triangle",
                            description: Text("This flight was saved without enrichment details")
                        )
                        .padding(.vertical, 40)
                        #else
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary)
                            Text("No Enrichment Data")
                                .font(.headline)
                            Text("This flight was saved without enrichment details")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 40)
                        #endif
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Flight Details")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    RecentFlightsView()
}
