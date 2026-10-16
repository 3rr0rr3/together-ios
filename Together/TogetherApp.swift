import SwiftUI

@main
struct TogetherApp: App {
    @StateObject private var store = MemoryStore()

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(store)
        }
    }
}
