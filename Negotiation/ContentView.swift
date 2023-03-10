// This is the VIEW file

import SwiftUI


struct ContentView: View {
    @ObservedObject var viewModel: NGViewModel
    @Binding var player_name: String
    @State private var sliderValue : Float = 0.0
    @State private var finalOfferToggle : Bool = false
    
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
            
            // stack to display player negotiation actions
            VStack {
                HStack {
                    Slider(value: $sliderValue, in: 0...9, step: 1)
                    // prints "hi" for as long as the slider is moving
                    // "onEditingChanged" returns true when the user starts moving it, false when the user lets go
                    // !!! Slider has to take a float value !!!
                    Text("Offer Value: " + String(Int(sliderValue)))
                        .padding()
                }
                Toggle("Final Offer", isOn: $finalOfferToggle)
                
                HStack {
                    Button("Accept Model Offer", action: {viewModel.playerAccepts()})
                    Button("Confirm Offer", action: {viewModel.playerMakeOffer(value: sliderValue, isFinal: finalOfferToggle)})
                    Button(action: {viewModel.playerQuits()}) {
                        Text("Quit")
                    }.foregroundColor(Color(.red))
                } .padding()
            }
            Spacer()
            
            // see model response
            HStack {
                Text("Model offer = " + String(viewModel.modelNegotiationValue))
                Text("Final? = " + String(viewModel.modelIsFinalOffer))
            } .padding()
            
            
            Spacer()
            HStack {
                Button("save model", action: {viewModel.saveModel()})
                Button("load model", action: {viewModel.loadModel()})
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let model = NGViewModel()
        ContentView(viewModel: model, player_name: .constant("name"))
    }
}

