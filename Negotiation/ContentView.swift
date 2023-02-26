// This is the View file

import SwiftUI


struct ContentView: View {
    @ObservedObject var viewModel: NGViewModel
    
    @State private var sliderValue : Float = 0.0
    
    var body: some View {
        VStack {
            Spacer()
            // simple stack to show both scores and MNS's
            HStack {
                Spacer()
                VStack {
                    Text("PLAYER").bold()
                    Text("Score = " + viewModel.playerScore)
                    Text("MNS = " + viewModel.playerMNS)
                }
                Spacer()
                VStack {
                    Text("MODEL").bold()
                    Text("Score = " + viewModel.modelScore)
                    Text("MNS = " + viewModel.modelMNS)
                }
                Spacer()
            }
            .padding()
            
            Spacer()
            
            // stack to display the offers
            VStack {
                Slider(value: $sliderValue, in: 0...9, step: 1)
                    // prints "hi" for as long as the slider is moving
                    // "onEditingChanged" returns true when the user starts moving it, false when the user lets go
                    // !!! Slider has to take a float value !!!
                HStack {
                    Text(String(Int(sliderValue)))
                        .padding()
                    Button("Confirm Offer",
                           action: {viewModel.playerMakeOffer(value: sliderValue) }
                    )
                }
                HStack {
                    Text(String(viewModel.modelNegotiationValue))
                }
                
            }
            
            
            Spacer()
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let model = NGViewModel()
        ContentView(viewModel: model)
    }
}

