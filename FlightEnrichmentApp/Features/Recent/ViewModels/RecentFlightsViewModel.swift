import Foundation
import Combine
import CoreData

@MainActor
final class RecentFlightsViewModel: ObservableObject {
    @Published var flights: [FlightEntity] = []
    @Published var isLoading = false
    @Published var selectedFlight: FlightEntity?
    @Published var showDetail = false
    
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
        fetchFlights()
    }
    
    func fetchFlights() {
        isLoading = true
        
        let request = NSFetchRequest<FlightEntity>(entityName: "FlightEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            flights = try coreDataStack.context.fetch(request)
        } catch {
            print("Failed to fetch flights: \(error)")
        }
        
        isLoading = false
    }
    
    func deleteFlight(_ flight: FlightEntity) {
        coreDataStack.context.delete(flight)
        coreDataStack.save()
        fetchFlights()
    }
    
    // FIX: Fetch enrichment data separately since relationship might not be set up
    func getEnrichment(for flight: FlightEntity) -> EnrichmentDataEntity? {
        let request = NSFetchRequest<EnrichmentDataEntity>(entityName: "EnrichmentDataEntity")
        request.predicate = NSPredicate(format: "flight == %@", flight)
        request.fetchLimit = 1
        
        do {
            let results = try coreDataStack.context.fetch(request)
            return results.first
        } catch {
            print("Failed to fetch enrichment: \(error)")
            return nil
        }
    }
    
    func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    func formatCurrency(_ amount: Double, code: String) -> String {
        return String(format: "%.2f %@", amount, code)
    }
}
