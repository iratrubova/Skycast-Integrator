import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .recent:
                    RecentFlightsView()
                case .account:
                    AccountView()
                }
            }
            .padding(.bottom, 80)
            
            VStack {
                Spacer()
                BottomMenuView(selectedTab: $selectedTab)
            }
            #if os(iOS)
            .ignoresSafeArea(.keyboard)
            #endif
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, CoreDataStack.shared.context)
}
