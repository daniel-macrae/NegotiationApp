// initialises the app?
// or smth idk shit doesn't work without this anyway

import SwiftUI

@main
struct NegotiationApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    private let viewModel = NGViewModel()
    
    var body: some Scene {
        WindowGroup {
            TitleScreen()
        }
    }
}
