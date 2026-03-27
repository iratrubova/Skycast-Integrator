import SwiftUI

extension View {
    #if os(iOS)
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    #else
    func hideKeyboard() {
        // No-op on macOS
    }
    #endif
}

extension Date {
    var isFuture: Bool {
        self > Date()
    }
}
