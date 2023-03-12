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
                ZStack{
                    HStack{
                        Spacer()
                        round_box(round_no: round_no)
                        Spacer()
                    }
                    HStack{
                        Spacer()
                        infoButton().padding(.horizontal)
                    }
                }
                ZStack{
                    HStack{
                        HStack{
                            UserIcon()
                            VStack{
                                Text("Score = " + String(Int(viewModel.playerScore)))
                                // What to display here? We cant just
                                Text("MNS = " + String(Int(viewModel.playerMNS)))
                            }
                        }
                        Spacer()
                        
                        VStack{
                            Text("Score = " + String(Int(viewModel.modelScore)))
                            Text("MNS = " + String(Int(viewModel.modelMNS)))
                        }
                        ComputerIcon()
                        }
                }.padding(.all)
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(20)
                Spacer()
                ChatBox(messages: viewModel.messages)
                Divider()
                VStack {
                    VStack{
                        sliderView(sliderValue: sliderValue, thresholdValue: viewModel.playerMNS).background(Color.white.opacity(0.5)).cornerRadius(20).padding(.horizontal)
                        
                        Toggle_box(finalOfferToggle: $finalOfferToggle)        .onChange(of: finalOfferToggle) { value in
                            viewModel.FinalOfferPlayerChanged()}
                        HStack {
                            GameButton(text: "Accept Model Offer", action: {viewModel.sendMessage("hello", isMe: false);
                                round_no = round_no + 1
                            })
                            Button("Co`dasdnfirm Offer", action: {viewModel.sendMessage("hello", isMe: true)})
                        } .padding()
                    }
                }
            }.background(backgroundImg(image: "secondbackground"))
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


struct GameButton: View{
    
    let text: String
    let action: () -> Void
    let buttonColor = Color(UIColor(red:0.40, green:0.30, blue:0.76,alpha: 0.75))
    
    var body: some View {
            Button(text, action: action)
                .frame(width: 150, height:50)
                .foregroundColor(.white)
                .background(buttonColor)
                .cornerRadius(50)
    }
}

struct UserIcon: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue)
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.white)
                .padding(10)
            ZStack {
                Rectangle()
                    .fill(Color.orange.opacity(0.9))
                    .frame(width: 40, height: 20)
                    .cornerRadius(8)
                    .offset(y: 20)
                    
                Text("You")
                    .foregroundColor(.white)
                    .font(.headline)
                    .offset(y: 20)
            }
        }
        .frame(width: 50, height: 50)
    }
}

struct ComputerIcon: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue)
            Image(systemName: "desktopcomputer")
                .resizable()
                .scaledToFit()
                .foregroundColor(.white)
                .padding(10)
            ZStack {
                Rectangle()
                    .fill(Color.orange.opacity(0.9))
                    .frame(width: 60, height: 20)
                    .cornerRadius(8)
                    .offset(y: 20)
                    
                Text("Model")
                    .foregroundColor(.white)
                    .font(.headline)
                    .offset(y: 20)
            }
        }
        .frame(width: 50, height: 50)
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

struct infoButton: View {
    @State private var showPicker = false
    @State private var showExplanation = false
    var body: some View {
        VStack {
            Button(action: {
                showPicker = true
            }) {
                Image(systemName: "questionmark.circle")
                    .foregroundColor(.black)
            }.scaleEffect(1.6)

        }
        .sheet(isPresented: $showPicker) {
            VStack {
                Text("What can I help you with:")
                    .font(.headline)
                    .padding()

                Button("How to Play") {
                    showExplanation = true
                    showPicker = false
                }
                Button("Save Model") {
                    showPicker = false
                }
                Button("Load Model") {
                    showPicker = false
                }
                Button("Return to Game") {
                    showPicker = false
                }
                Button("Quit Game") {
                    showPicker = false
                }.foregroundColor(Color.red)

                .padding(.bottom)
            }
        }
        .sheet(isPresented: $showExplanation){
            VStack{
                Text("HELLO THIS IS HOW GAME WORKS")
                Button("Return to Game") {
                    showExplanation = false
                }
                Button("Return to Options") {
                    showPicker = true
                    showExplanation = false
                }
                
            }
        }
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

