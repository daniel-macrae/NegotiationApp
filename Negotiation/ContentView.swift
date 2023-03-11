// This is the VIEW file

import SwiftUI


struct ContentView: View {
    @ObservedObject var viewModel: NGViewModel
    @Binding var player_name: String
    @State private var sliderValue : Float = 0.0
    @State private var finalOfferToggle : Bool = false
    @State private var OfferAccepted: Bool = false
    @State private var round_no: Int = 1
    
    var body: some View {
        NavigationStack{
            VStack {
                HStack{
                    Spacer()
                    round_box(round_no: round_no)
                    Spacer()
                }
                Spacer()
                ChatBox(messages: viewModel.messages)
                /*Spacer()
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
                 */
                Divider()
                VStack {
                    VStack{
                        sliderView(sliderValue: sliderValue, thresholdValue: viewModel.playerMNS)
                        
                        Toggle_box(finalOfferToggle: $finalOfferToggle)        .onChange(of: finalOfferToggle) { value in
                            viewModel.FinalOfferPlayerChanged()}
                        HStack {
                            Button("Accept Model Offer", action: {viewModel.sendMessage("hello", isMe: false);
                                round_no = round_no + 1
                            })
                            Button("Confirm Offer", action: {viewModel.sendMessage("hello", isMe: true)})
                            Button(action: {viewModel.playerQuits()}) {
                                Text("Quit")
                            }.foregroundColor(Color(.red))
                        } .padding()
                    }
                    Spacer()
                    
                    // see model response
                    HStack {
                        Text("Model offer = " + String(viewModel.modelNegotiationValue))
                        Text("Final? = " + String(viewModel.playerIsFinalOffer))
                    } .padding()
                    
                    
                    Spacer()
                    HStack {
                        Button("save model", action: {print(viewModel.messages)})
                        Button("load model", action: {viewModel.loadModel()})
                    }
                    Spacer()
                }
            }.background(Color.black.opacity(0.4))
                .onAppear{viewModel.sendMessage("Hello " + String(player_name), isMe: false)}
            .onAppear {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation") // Forcing the rotation to portrait
                AppDelegate.orientationLock = .portrait // And making sure it stays that way
            }.onDisappear {
                AppDelegate.orientationLock = .all // Unlocking the rotation when leaving the view
                ;
                viewModel.messages = []
            }
        }
    }
}


struct sliderView: View{
    @State var sliderValue : Float
    var thresholdValue : Float

    var body: some View {
        VStack{
            HStack{
                Spacer()
                Text("Offer Value:")
                    .foregroundColor(Color.black.opacity(0.7))
                Text(String(Int(sliderValue)))
                    .foregroundColor(sliderValue > thresholdValue ? .green : .orange)
                Spacer()
            }.padding([.top,.horizontal])
            HStack {
                Slider(value: $sliderValue, in: 0...10, step: 1)
                
                    .accentColor(sliderValue > thresholdValue ? .green : .orange)
                    .frame(height: 10)
                    .padding([.bottom,.horizontal])
            }
        }
    }
}

struct round_box: View{
    
    var round_no = 1
    
    var body: some View{
        VStack{
            Text("Round").foregroundColor(Color.white)
            Text(String(round_no)+"/10").foregroundColor(Color.white)
        }.padding(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.blue.opacity(0.6), lineWidth: 1)
        )
        .background(
             RoundedRectangle(cornerRadius: 10)
                 .fill(Color.blue.opacity(0.6))
         )
    }
}

struct Toggle_box: View{
    var toggleAction: ((Bool) -> Void)?
    @Binding var finalOfferToggle: Bool
    
    var body: some View{
        HStack{
            VStack(alignment: .center){
                Text("Finale Offer")
                    .foregroundColor(finalOfferToggle ? Color.green : Color.gray)
                Toggle("", isOn: $finalOfferToggle)
                    .foregroundColor(finalOfferToggle ? Color.green : Color.gray).labelsHidden()
            }.padding(.all, 8).background(Color.white.opacity(0.5)).cornerRadius(20)
            Spacer()
        }
        .scaleEffect(0.8)
    }
}

struct MessageView: View{
    let message: NGViewModel.Message
    var body: some View{

            if message.sender{
                HStack{
                    Spacer()
                    Text(message.text)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                }
            } else {
                HStack{
                    Text(message.text)
                        .padding()
                        .background(Color.gray.opacity(0.6))
                        .foregroundColor(Color.black.opacity(0.7))
                        .cornerRadius(20)
                    Spacer()
                }
            }
        }
}

struct ChatBox: View{
    var messages: [NGViewModel.Message]
    var body: some View{
        List(messages){
            message in MessageView(message: message)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let model = NGViewModel()
        ContentView(viewModel: model, player_name: .constant("name"))
    }
}

