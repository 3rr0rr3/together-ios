import SwiftUI

@main
struct TogetherApp: App {
    @StateObject private var store = MemoryStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                // Keep system text and sheets consistent with the cream-and-white palette.
                .preferredColorScheme(.light)
        }
    }
}
