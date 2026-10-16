import SwiftUI

@main
struct TogetherApp: App {
    @StateObject private var store = MemoryStore()

    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        let titleColor = UIColor(red: 0.58, green: 0.16, blue: 0.31, alpha: 1)
        appearance.largeTitleTextAttributes = [
            .font: UIFont(name: "SnellRoundhand-Bold", size: 38) ?? UIFont.systemFont(ofSize: 34),
            .foregroundColor: titleColor
        ]
        appearance.titleTextAttributes = [
            .font: UIFont(name: "Georgia-BoldItalic", size: 19) ?? UIFont.systemFont(ofSize: 19),
            .foregroundColor: titleColor
        ]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .fontDesign(.serif)
                // Keep system text and sheets consistent with the cream-and-white palette.
                .preferredColorScheme(.light)
        }
    }
}
