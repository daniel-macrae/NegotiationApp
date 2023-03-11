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
                    VStack{
                        Text("Round").foregroundColor(Color.white)
                        Text(String(round_no)+"/10").foregroundColor(Color.white)
                    }
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue.opacity(0.6), lineWidth: 1)
                    )
                    .background(
                         RoundedRectangle(cornerRadius: 10)
                             .fill(Color.blue.opacity(0.6))
                     )
                    Spacer()
                }

                
                Spacer()
                ChatBox(messages: viewModel.messages)
                /*Spacer()
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
                 */
                // stack to display player negotiation actions
                Spacer()
                Divider()
                    .background(Color.black)
                    .frame(height: 4)
                
                VStack {
                    VStack{
                        HStack{
                            Spacer()
                            Text("Offer Value: " + String(Int(sliderValue)))
                                .padding(.top)
                            Spacer()
                        }
                        HStack {
                            Slider(value: $sliderValue, in: 0...9, step: 1)
                            // prints "hi" for as long as the slider is moving
                            // "onEditingChanged" returns true when the user starts moving it, false when the user lets go
                            // !!! Slider has to take a float value !!!
                        }.padding([.bottom,.horizontal])
                        HStack {
                            VStack(alignment: .center){
                                Text("Finale Offer")
                                    .foregroundColor(finalOfferToggle ? Color.green : Color.gray)
                                Toggle("", isOn: $finalOfferToggle)
                                    .foregroundColor(finalOfferToggle ? Color.green : Color.gray).labelsHidden()
                            }.padding(.horizontal)
                            Spacer()
                        }



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
                        Text("Final? = " + String(viewModel.modelIsFinalOffer))
                    } .padding()
                    
                    
                    Spacer()
                    HStack {
                        Button("save model", action: {print(viewModel.messages)})
                        Button("load model", action: {viewModel.loadModel()})
                    }
                    Spacer()
                }
            }.onAppear {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation") // Forcing the rotation to portrait
                AppDelegate.orientationLock = .portrait // And making sure it stays that way
            }.onDisappear {
                AppDelegate.orientationLock = .all // Unlocking the rotation when leaving the view
            }
        }
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

