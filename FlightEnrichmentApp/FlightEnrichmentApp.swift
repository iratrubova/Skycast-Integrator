import SwiftUI

@main
struct FlightEnrichmentApp: App {
    let persistenceController = CoreDataStack.shared
    @StateObject private var authService = AuthService.shared
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authService.isAuthenticated {
                    ContentView()
                        .environment(\.managedObjectContext, persistenceController.context)
                        .environmentObject(persistenceController)
                        .environmentObject(authService)
                } else {
                    LoginView()
                        .environment(\.managedObjectContext, persistenceController.context)
                        .environmentObject(authService)
                }
            }
        }
        #if os(macOS)
        .defaultSize(width: 1200, height: 800)
        #endif
    }
}
