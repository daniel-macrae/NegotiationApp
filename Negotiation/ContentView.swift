// This is the VIEW file

import SwiftUI


struct ContentView: View {
    @ObservedObject var viewModel: NGViewModel
    @Binding var player_name: String
    @State private var sliderValue : Float = 0.0
    @State private var finalOfferToggle : Bool = false
    @State private var OfferAccepted: Bool = false
    @State private var round_no: Int = 1
    @State private var mnsDeclared: Bool = false
    @State private var isQuitting: Bool = false
    @State private var gameOver: Bool = false
    @State private var finalScreen: Bool = false
    
    var body: some View {
        NavigationStack{
            NavigationLink(destination: TitleScreen().navigationBarBackButtonHidden(true), isActive: $isQuitting, label: {})
            NavigationLink(destination: gameOverView(viewModel: viewModel, player_name: player_name).navigationBarBackButtonHidden(true), isActive: $finalScreen, label: {})
            VStack {
                ZStack{
                    HStack{
                        Spacer()
                        round_box(round_no: round_no)
                        Spacer()
                    }
                    HStack{
                        Spacer()
                        infoButton(isQuitting: $isQuitting).padding(.horizontal)
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
                        Spacer()
                        if gameOver{
                            VStack{
                                Spacer()
                                GameButton(text: "Continue", action: {
                                    finalScreen = true
                                })
                                Spacer()
                            }
                        }else{
                        sliderView(sliderValue: $sliderValue, thresholdValue: viewModel.playerMNS).background(Color.white.opacity(0.5)).cornerRadius(20).padding(.horizontal)
                        Spacer()
                        .frame(maxHeight: .infinity)
                        if mnsDeclared {
                            Toggle_box(finalOfferToggle: $finalOfferToggle)        .onChange(of: finalOfferToggle) { value in
                                viewModel.FinalOfferPlayerChanged()}
                            HStack {
                                GameButton(text: "Send Offer", action: {viewModel.playerMakeOffer(value: sliderValue, isFinal: finalOfferToggle)})
                                AcceptButton(text: "Accept Offer", action: {viewModel.playerAccepts();
                                    round_no = round_no + 1;
                                    if round_no == 10 {
                                        gameOver = true
                                    };
                                    mnsDeclared = false}, offerHasBeenMade: viewModel.offerHasBeenMade)
                                
                            } .padding()

                        } else{
                            HStack{
                                GameButton(text: "Declare MNS", action: {mnsDeclared = true;
                                    viewModel.declarePlayerMNS(value: sliderValue);
                                    
                                }).padding()
                            }
                        }
                            
                        }

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
                viewModel.messages = [] //Emptying the message log
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
                .frame(width: 160, height:50)
                .foregroundColor(.white)
                .background(buttonColor)
                .buttonStyle(CustomButtonStyle())
                .cornerRadius(50)    }
}

struct AcceptButton: View{
    
    let text: String
    let action: () -> Void
    let buttonColor = Color(UIColor(red:0.40, green:0.30, blue:0.76,alpha: 0.75))
    var offerHasBeenMade: Bool
    
    var body: some View {
            Button(text, action: action)
                .frame(width: 160, height:50)
                .foregroundColor(.white)
                .background(offerHasBeenMade ? buttonColor : Color.gray)
                .cornerRadius(50)
                .buttonStyle(CustomButtonStyle())
                .disabled(!offerHasBeenMade)
    }
}

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .scaleEffect(configuration.isPressed ? 1.5 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}


struct QuitButton: View{
    
    let text: String
    let action: () -> Void
    let buttonColor = Color.red
    
    var body: some View {
            Button(text, action: action)
                .frame(width: 160, height:50)
                .foregroundColor(.white)
                .background(buttonColor)
                .buttonStyle(CustomButtonStyle())
                .cornerRadius(50)
    }
}

struct UserIcon: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.8))
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
                .fill(Color.blue.opacity(0.8))
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
    @Binding var sliderValue : Float
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
                Slider(value: $sliderValue, in: 1...9, step: 1)
                
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
    @Binding var isQuitting: Bool

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
            ZStack{
                backgroundImg(image: "secondbackground").background()
                    .ignoresSafeArea(.all)
                VStack {
                    GameButton(text: "How to Play") {
                        showExplanation = true
                        showPicker = false
                    }
                    GameButton(text: "Save Model") {
                        NGViewModel().saveModel()
                        //Some animation for the model being save
                        showPicker = false
                    }
                    GameButton(text: "Load Model") {
                        //Some animation for the model being loaded
                        //NGViewModel().loadModel("some_model")
                        showPicker = false
                    }
                    GameButton(text: "Return to Game") {
                        showPicker = false
                    }
                    QuitButton(text: "Quit Game") {
                        showPicker = false
                        isQuitting = true
                    }.foregroundColor(Color.red)
                    
                        .padding(.bottom)
                }
            }
        }
        .sheet(isPresented: $showExplanation){
            ZStack{
                backgroundImg(image: "secondbackground").background()
                    .ignoresSafeArea(.all)
                VStack{
                    ScrollView{
                        Text("The game of nines is a negotiation game played between two players, the proposer (you) and the responder (model). The game is played over several rounds, and in each round, the proposer makes an offer, and the responder can either accept or reject the offer. The goal of the game is to maximize the total score over all rounds, where the score is calculated by subtracting the proposer's offer from the number nine.").padding(.all).foregroundColor(.white)
                        Text("At the start of each round, both players declare their minimum acceptable score (MNS), which is the minimum score they are willing to accept. The proposer makes the first offer, which must be a number between 0 and 9, and the responder can either accept or reject the offer. If the responder accepts the offer, the round ends, and both players receive a score equal to the difference between nine and the offer.").foregroundColor(.white)
                            .padding(.all)
                        Text("If the responder rejects the offer, the proposer can make a new offer and the responder can again choose to accept or reject the offer. If the proposer makes a final offer, the responder must accept or reject it, and the round ends regardless of their decision. The game continues for a fixed number of rounds, and the player with the highest total score at the end of the game is the winner.").foregroundColor(.white)
                            .padding(.all)
                    }
                    GameButton(text:"Go to Game") {
                        showExplanation = false
                    }
                    GameButton(text:"Go to Options") {
                        showPicker = true
                        showExplanation = false
                    }
                    
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
                        .background(Color.blue.opacity(0.6))
                        .foregroundColor(Color.white)
                        .cornerRadius(20)
                }
            } else {
                HStack{
                    Text(message.text)
                        .padding()
                        .background(Color.white.opacity(0.6))
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
        ZStack{
            ScrollView{
                ScrollViewReader { scrollView in
                    VStack{
                        ForEach(messages){ message in
                            MessageView(message: message).padding([.horizontal,.top], 8)
                        }
                        HStack{
                            Spacer()
                        }.id("Empty")
                    }.onChange(of: messages.count){ _ in
                        withAnimation(.easeOut(duration: 0.5)){
                            scrollView.scrollTo("Empty", anchor: .bottom)
            
                        }
                    }
                }
            }
        }.background(Color.white.opacity(0.8))

    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let model = NGViewModel()
        ContentView(viewModel: model, player_name: .constant("name"))
    }
}

