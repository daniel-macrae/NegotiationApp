// makes the app?
// or smth idk shit doesn't work without this

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
