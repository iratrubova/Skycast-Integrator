import SwiftUI

enum Tab: String, CaseIterable {
    case home = "Home"
    case recent = "Recent"
    case account = "Account"
    
    var icon: String {
        switch self {
        case .home: return "airplane"
        case .recent: return "clock.arrow.circlepath"
        case .account: return "person.circle"
        }
    }
}

struct BottomMenuView: View {
    @Binding var selectedTab: Tab
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 24, weight: .semibold))
                            .symbolRenderingMode(.hierarchical)
                        
                        Text(tab.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(selectedTab == tab ? .blue : .gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        selectedTab == tab ?
                        Color.blue.opacity(0.1) :
                        Color.clear
                    )
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        #if os(iOS)
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.gray.opacity(0.3)),
            alignment: .top
        )
        #else
        .background(Color.gray.opacity(0.1))
        #endif
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedTab: Tab = .home
        
        var body: some View {
            VStack {
                Spacer()
                BottomMenuView(selectedTab: $selectedTab)
            }
        }
    }
    
    return PreviewWrapper()
}
