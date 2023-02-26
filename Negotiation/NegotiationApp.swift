// initialises the app?
// or smth idk shit doesn't work without this anyway

import SwiftUI

@main
struct NegotiationApp: App {
    private let viewModel = NGViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
    }
}
