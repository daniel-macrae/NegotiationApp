import SwiftUI

@main
struct NegotiationApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    private let viewModel = NGViewModel()
    
    var body: some Scene {
        WindowGroup {
            TitleScreen(viewModel: viewModel)
        }
    }
}
