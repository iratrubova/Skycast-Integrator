import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                if viewModel.showResults, let flight = viewModel.enrichedFlight {
                    EnrichmentCard(flight: flight)
                        .navigationTitle("Flight Enriched")
                        #if os(iOS)
                        .navigationBarTitleDisplayMode(.large)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("New Search") {
                                    viewModel.clearSearch()
                                }
                            }
                        }
                        #else
                        .toolbar {
                            ToolbarItem {
                                Button("New Search") {
                                    viewModel.clearSearch()
                                }
                            }
                        }
                        #endif
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            VStack(spacing: 12) {
                                Image(systemName: "airplane.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundStyle(.blue.gradient)
                                
                                Text("Flight Enrichment")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                
                                Text("Book a flight and get instant weather, places & currency info")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                            .padding(.top, 20)
                            
                            FlightSearchForm(viewModel: viewModel)
                                .padding(.horizontal)
                            
                            Spacer(minLength: 100)
                        }
                    }
                    .navigationTitle("Plan Trip")
                    #if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
                    #endif
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "Unknown error")
            }
        }
        #if os(macOS)
        .frame(minWidth: 800, minHeight: 600)
        #endif
    }
}


#Preview {
    HomeView()
}
