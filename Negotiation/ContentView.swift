// This is the View file

import SwiftUI


struct ContentView: View {
    @ObservedObject var viewModel: NGViewModel
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let model = NGViewModel()
        ContentView(viewModel: model)
    }
}

