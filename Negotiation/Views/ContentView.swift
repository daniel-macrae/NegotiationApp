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
        NavigationStack {
            NavigationLink(destination: TitleScreen(viewModel: viewModel).navigationBarBackButtonHidden(true), isActive: $isQuitting, label: {})
            NavigationLink(destination: gameOverView(viewModel: viewModel, player_name: player_name).navigationBarBackButtonHidden(true), isActive: $finalScreen, label: {})
            
            // main VStack!
            VStack {
                Spacer().frame(height: 5) // put a little bit of space in between the toolbar and the content
                ScoresDisplay(playerScore:viewModel.playerScore, modelScore:viewModel.modelMNS, playerMNS:viewModel.playerMNS, modelMNS:viewModel.modelMNS) // MARK: HELLO
                Spacer()
                ChatBox(messages: viewModel.messages)
                Divider()
                VStack {
                    VStack{
                        Spacer()
                        if gameOver {
                            VStack{
                                Spacer()
                                GameButton(text: "Continue", action: { finalScreen = true } )
                                Spacer()
                            }
                        } else {
                            sliderView(sliderValue: $sliderValue, thresholdValue: Float(viewModel.playerMNS)).background(Color.white.opacity(0.75)).cornerRadius(20).padding(.horizontal)
                            Spacer()
                            .frame(maxHeight: .infinity)
                            if mnsDeclared {
                                Toggle_box(finalOfferToggle: $finalOfferToggle).onChange(of: finalOfferToggle) { value in
                                    viewModel.FinalOfferPlayerChanged()}
                                HStack {
                                    GameButton(text: "Send Offer", action: {viewModel.playerMakeOffer(value: sliderValue)})
                                    AcceptButton(text: "Accept Offer", action: {viewModel.playerAccepts();
                                        finalOfferToggle = false;
                                        round_no = round_no + 1;
                                        if round_no == viewModel.numberOfRounds {
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
            }.background(backgroundImg(image: "thirdbackground2"))
                .onAppear{viewModel.sendMessage("Hello " + String(player_name), isMe: false, PSA: false)}
            .onAppear {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation") // Forcing the rotation to portrait
                AppDelegate.orientationLock = .portrait // And making sure it stays that way
            }.onDisappear {
                AppDelegate.orientationLock = .all // Unlocking the rotation when leaving the view
                ;
                viewModel.messages = [] //Emptying the message log
            }
        }.toolbar {
            // middle of top toolbad: show round #
            ToolbarItem(placement: .principal) { round_box(round_no: round_no, maxRoundNumber: viewModel.numberOfRounds) }
            // right side, show infoButton
            ToolbarItem(placement: .primaryAction) { infoButton(viewModel: viewModel, isQuitting: $isQuitting) }
            //ToolbarItem(placement: .navigationBarLeading) { Text("hiya") }
        }
    }
}


struct ScoresDisplay: View {
    var playerScore: Int
    var modelScore: Int
    var playerMNS: Int
    var modelMNS: Int
    
    var body: some View {
        ZStack{
            HStack{
                HStack{
                    UserIcon()
                    VStack{
                        Text("Score = " + String(playerScore))
                        // What to display here? We cant just
                        Text("MNS = " + String(playerMNS))
                    }
                }
                Spacer()
                VStack{
                    Text("Score = " + String(modelScore))
                    Text("MNS = " + String(modelMNS))
                }
                ComputerIcon()
                }
        }.padding(.all)
            .background(Color.white.opacity(0.5))
            .cornerRadius(20)
    }
}


struct GameButton: View{
    let text: String
    let action: () -> Void
    let buttonColor = Color(UIColor(red:0.40, green:0.30, blue:0.76, alpha: 0.75))
    
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
    var maxRoundNumber = 5
    var RBColor =  Color(UIColor(red:0.40, green:0.30, blue:0.76,alpha: 0.75))
    var body: some View{
        VStack{
            Text("Round " + String(round_no)+"/" + String(maxRoundNumber)).foregroundColor(Color.white)
        }.padding(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(RBColor.opacity(0.3), lineWidth: 1)
        )
        .background(
             RoundedRectangle(cornerRadius: 10)
                .fill(RBColor.opacity(0.3))
         )
    }
}

struct infoButton: View {
    var viewModel: NGViewModel
    @State private var showPicker = false
    @State private var showExplanation = false
    @Binding var isQuitting: Bool

    var body: some View {
        VStack {
            Button(action: { showPicker = true } ) {
                Image(systemName: "questionmark.circle")
                    .foregroundColor(.white)
            }.scaleEffect(1.6)
        }
        .sheet(isPresented: $showPicker) {
            ZStack{
                backgroundImg(image: "thirdbackground2").background()
                    .ignoresSafeArea(.all)
                VStack {
                    GameButton(text: "How to Play") {
                        showExplanation = true
                        showPicker = false
                    }
                    GameButton(text: "Save Model") {
                        viewModel.saveModel()
                        //Some animation for the model being save
                        showPicker = false
                    }
                    GameButton(text: "Load Model") {
                        //Some animation for the model being loaded
                        viewModel.loadModel(name:"test")
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
                    }.background(.black.opacity(0.6))
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
            }.padding(.all, 8).background(Color.white.opacity(0.75)).cornerRadius(20)
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
            } else if !message.PSA{
                HStack{
                    Text(message.text)
                        .padding()
                        .background(Color.white.opacity(0.6))
                        .foregroundColor(Color.black.opacity(0.7))
                        .cornerRadius(20)
                    Spacer()
                }
            } else {
                HStack{
                    Spacer()
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
