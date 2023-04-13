// This is the VIEW file

import SwiftUI


struct ContentView: View {
    @ObservedObject var viewModel: NGViewModel
    @Binding var player_name: String
    @State private var sliderValue : Float = 0.0
    @State private var finalOfferToggle : Bool = false
    @State private var OfferAccepted: Bool = false
    @State private var isQuitting: Bool = false
    //private var gameOver: Bool {viewModel.gameOver}
    @State private var finalScreen: Bool = false
    @State private var toSelectModel: Bool = false
 
    var body: some View {
        NavigationStack {
            NavigationLink(destination: TitleScreen(viewModel: viewModel).navigationBarBackButtonHidden(true), isActive: $isQuitting, label: {})
                
            NavigationLink(destination: gameOverView(viewModel: viewModel, player_name: player_name).navigationBarBackButtonHidden(true), isActive: $finalScreen, label: {})
            
            NavigationLink(destination:SelectModelScreen(viewModel: viewModel).navigationBarBackButtonHidden(true), isActive: $toSelectModel, label: {})
            
            // main VStack!
            VStack {
                Spacer().frame(height: 5) // put a little bit of space in between the toolbar and the content
                ScoresDisplay(playerDeclaredMNS: viewModel.playerDeclaredMNS,
                              modelDeclaredMNS: viewModel.modelDeclaredMNS,
                              playerScore:viewModel.playerScore, modelScore:viewModel.modelScore, playerMNS:viewModel.playerMNS, modelMNS:viewModel.modelMNS, showModelDecMNS:viewModel.displayDeclaredMNS, animDuration:viewModel.animDuration)
                Spacer()
                ChatBox(viewModel: viewModel, messages: viewModel.messages)
                    .layoutPriority(1)
                Divider()
                    //Spacer()
                    if viewModel.gameOver {
                        VStack{
                            Spacer()
                            GameButton(text: "Continue", action: { finalScreen = true })
                            Spacer()
                        }
                    } else if viewModel.MNSDeclared {
                        VStack {
                            HStack {
                                Spacer()
                                RejectButton(text: viewModel.quitButtonText, action: {viewModel.playerRejectsFinalOffer();
                                    finalOfferToggle = false;
                                    //viewModel.removeMessage()
                                    
                                }, offerHasBeenMade: viewModel.offerHasBeenMade, isPlayerTurn: viewModel.isPlayerTurn)
                                Spacer()
                                AcceptButton(text: "Accept Offer", action: {viewModel.playerAccepts();
                                    finalOfferToggle = false;
                                    
                                }, offerHasBeenMade: viewModel.offerHasBeenMade, isPlayerTurn: viewModel.isPlayerTurn)
                                Spacer()
                                
                            }
                            
                            sliderView(displayText: "Offer Value:", sliderValue: $sliderValue, thresholdValue: Float(viewModel.playerMNS))
                                .padding(.horizontal)
                                .background(Color.white.opacity(0.75))
                                .cornerRadius(20)
                            
                            //Spacer()
                            //.frame(maxHeight: .infinity)
                            HStack{
                                if viewModel.offerHasBeenMade{
                                    Spacer()
                                    Toggle_box(finalOfferToggle: $finalOfferToggle).onChange(of: finalOfferToggle) { value in
                                        viewModel.FinalOfferPlayerChanged()}
                                    Spacer()
                                    BidButton(text: "Send Offer", isPlayerTurn: viewModel.isPlayerTurn, modelIsFinal:viewModel.modelIsFinalOffer, action: {viewModel.playerMakeOffer(playerBid: sliderValue); finalOfferToggle = false})
                                    Spacer()
                                } else {
                                    Spacer()
                                    BidButton(text: "Send Offer", isPlayerTurn: viewModel.isPlayerTurn, modelIsFinal:viewModel.modelIsFinalOffer, action: {viewModel.playerMakeOffer(playerBid: sliderValue); finalOfferToggle = false}).padding(.bottom).padding(.top)
                                    Spacer()
                                }
                            }
                        }
                        
                    } else {
                        VStack {
                        sliderView(displayText: "Declared MNS Value:", sliderValue: $sliderValue, thresholdValue: Float(viewModel.playerMNS))
                            .padding(.horizontal)
                            .background(Color.white.opacity(0.75))
                            .cornerRadius(20)
                        Spacer()
                        .frame(maxHeight: .infinity)
                        HStack {
                            BidButton(text: "Declare MNS", isPlayerTurn: viewModel.isPlayerTurn, modelIsFinal:viewModel.modelIsFinalOffer, action: {
                                viewModel.declarePlayerMNS(value: sliderValue)
                            }).padding()
                        }
                    }
    
                }
            }
            .onAppear {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation") // Forcing the rotation to portrait
                AppDelegate.orientationLock = .portrait // And making sure it stays that way
            }.onDisappear {
                AppDelegate.orientationLock = .all // Unlocking the rotation when leaving the view
                viewModel.messages = [] //Emptying the message log
            }
        }
        .background(backgroundImg(image: "SolidBackground"))
            
        .toolbar {
            // middle of top toolbar: show the round # out of 5
            ToolbarItem(placement:.navigationBarLeading){backButton(action: {toSelectModel = true})}
            
            ToolbarItem(placement: .principal) { round_box(round_no: viewModel.currentRound, maxRoundNumber: viewModel.numberOfRounds) }
            // right side, show infoButton
            ToolbarItem(placement: .primaryAction) { infoButton(viewModel: viewModel) }
        }
        .sheet(isPresented: $viewModel.firstTime){
            infoText()
        }
    }
}


struct ScoresDisplay: View {
    var playerDeclaredMNS: Int?
    var modelDeclaredMNS: Int?
    var playerScore: Int
    var modelScore: Int
    var playerMNS: Int
    var modelMNS: Int
    var showModelDecMNS: Bool
    var animDuration: Double
    
    var body: some View {
        ZStack{
            HStack{
                ComputerIcon()
                
                VStack{
                    // Text("Score = " + String(modelScore))
                    // Text("MNS = " + String(modelMNS)) //  MARK: Don't show the model score or MNS to the player
                    // display declared MNS
                    if let modelDecMNS = modelDeclaredMNS {Text("Declared\nMNS = " + String(modelDecMNS))
                        .font(.custom("Sans-Regular",size: 15, relativeTo: .body)) // REMOVE THIS LINE
                        .lineLimit(2, reservesSpace: true)
                    }
                    
                }.layoutPriority(2)
                
                Spacer()
                
                VStack{
                    Text("Score = " + String(playerScore))
                    Text("MNS = " + String(playerMNS))
                    // MARK: Don't display the declared MNS
                    //if let playerDecMNS = playerDeclaredMNS {Text("Declared\nMNS = " + String(playerDecMNS))
                    //        .font(.custom("Sans-Regular",size: 15, relativeTo: .body))  // REMOVE THIS LINE
                    //        .lineLimit(2, reservesSpace: true)
                    //}
                }.layoutPriority(2)
                UserIcon()
                
                }
        }.padding(.all)
            .background(Color.white.opacity(0.5))
            .cornerRadius(20)
            .animation(.linear(duration: animDuration))
    }
}


struct GameButton: View{
    let text: String
    let action: () -> Void
    let buttonColor = Color(UIColor(red:0.40, green:0.30, blue:0.76, alpha: 0.75))
    let screenWidth = UIScreen.main.bounds.size.width
    
    var body: some View {
            Button(text, action: action)
            .frame(width: screenWidth * 0.6, height:50)  // width is 60% of screen width
                .foregroundColor(.white)
                .background(buttonColor)
                .buttonStyle(CustomButtonStyle())
                .cornerRadius(50)    }
}



struct BidButton: View {
    let text: String
    let isPlayerTurn: Bool
    let modelIsFinal: Bool
    let action: () -> Void
    let buttonColor = Color(UIColor(red:0.40, green:0.30, blue:0.76, alpha: 0.75))
    let screenWidth = UIScreen.main.bounds.size.width
    
    var body: some View {
        withAnimation(.easeInOut) {
            Button(text, action: action)
                .frame(width: screenWidth * 0.6, height:50)  // width is 60% of screen width
                .foregroundColor(.white)
                .background((isPlayerTurn && !modelIsFinal) ? buttonColor : Color.gray)
                .buttonStyle(CustomButtonStyle())
                .cornerRadius(50)
                .disabled( (!isPlayerTurn || modelIsFinal) )
        }
    }
}




struct AcceptButton: View{
    let text: String
    let action: () -> Void
    //let buttonColor = Color(UIColor(red:0.40, green:0.30, blue:0.76,alpha: 0.75))
    let buttonColor = Color.green.opacity(0.85)
    let offerHasBeenMade: Bool
    let isPlayerTurn: Bool
    
    var body: some View {
        withAnimation(.easeInOut) {
            Button(text, action: action)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .foregroundColor(.white)
                .background(offerHasBeenMade&&isPlayerTurn ? buttonColor : Color.gray)
                .cornerRadius(50)
                .buttonStyle(CustomButtonStyle())
                .disabled(!offerHasBeenMade)
        }
    }
}

struct RejectButton: View{
    let text: String
    let action: () -> Void
    //let buttonColor = Color(UIColor(red:0.40, green:0.30, blue:0.76,alpha: 0.75))
    let buttonColor = Color.red.opacity(0.85)
    let offerHasBeenMade: Bool
    let isPlayerTurn: Bool
    
    var body: some View {
        withAnimation(.easeInOut) {
            Button(text, action: action)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .foregroundColor(.white)
                .background(offerHasBeenMade&&isPlayerTurn ? buttonColor : Color.gray)
                .cornerRadius(50)
                .buttonStyle(CustomButtonStyle())
                .disabled(!offerHasBeenMade)
        }
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
    var displayText : String
    @Binding var sliderValue : Float
    var thresholdValue : Float

    var body: some View {
        VStack{
            HStack{
                Spacer()
                Text(displayText)
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


struct infoText: View{
    var body: some View{
        ZStack{
            backgroundImg(image: "SolidBackground").background()
                .ignoresSafeArea(.all)
            VStack {
                Spacer()
                Text("How to Play:")
                    .font(.largeTitle)
                    .foregroundColor(Color.white)
                Spacer()
                ScrollView{
                    Text("The Game of Nines is played between two players, who have to decide how to split 9 points between themselves. However, each player has their own Minimum Necessary Score (MNS) that indicates the lowest number of points they need to get from the negotiation. Players score by agreeing a deal where they get more points than their MNS value. For example, if you get 6 points, and your MNS is 4, you score 2 on that round. But, if the negotiation leads to you getting less points than your MNS, points will be deducted from your score.").padding(.all).foregroundColor(.white)
                    Text("The game works as follows; first, you must declare to the opponent what your MNS is; it is not necessary for you to tell the truth, but if you lie more often, then the opponent might do so as well.").foregroundColor(.white)
                        .padding(.all)
                    Text("Once you've both declared your MNSs, both players iteratively make bids on how to split the 9 points using the slider and the bid buttons at the bottom of the screen. This negotiation goes on until one of the players accepts or rejects the opponents bid, while both players can also quit the round at any time, resulting in 0 points for both players.").foregroundColor(.white)
                        .padding(.all)
                    Text("The game consists of 5 rounds of negotiation, where the MNS values change on each round. The winner is whoever gets the highest score after these five rounds. Good luck!").foregroundColor(.white)
                        .padding(.all)
                    Text("To return to the game, close this window by swiping down from the top of the screen.").foregroundColor(.white)
                        .padding(.all)
                }.background(.black.opacity(0.3))
            }
        }
    }
}
struct infoButton: View {
    var viewModel: NGViewModel
    @State private var showMenu = false
    @State private var showExplanation = false
    var body: some View {
        VStack {
            Button(action: { showMenu = true } ) {
                Image(systemName: "questionmark.circle")
                    .foregroundColor(.white)
            }.scaleEffect(1.6)
        }
        .sheet(isPresented: $showMenu) {
            infoText()
        }
    }
            
}
    



struct Toggle_box: View{
    var toggleAction: ((Bool) -> Void)?
    @Binding var finalOfferToggle: Bool
    
    var body: some View{
        HStack{
            VStack(alignment: .center){
                Text("Final Offer?")
                    .foregroundColor(finalOfferToggle ? Color.green : Color.black.opacity(0.75))
                Toggle("", isOn: $finalOfferToggle)
                    .foregroundColor(finalOfferToggle ? Color.green : Color.black).labelsHidden()
            }
            .padding(.all, 8)
            .background(Color.white.opacity(0.75))
            .cornerRadius(20)
            Spacer()
        }
        .scaleEffect(0.8)
    }
}






struct MessageView: View{
    let message: NGViewModel.Message
    let screenWidth = UIScreen.main.bounds.size.width
    
    var body: some View {
            // if its a player message
            if message.sender{
                HStack{
                    Spacer()
                    Text(message.text)
                        .padding(13)
                        .background(Color.blue.opacity(0.6))
                        .foregroundColor(Color.white)
                        .cornerRadius(20)
                }
            // else if it is not a PSA, it must be a model message
            } else if !message.PSA{
                HStack{
                    if message.text == "..." {   // MARK: Maybe we can do some kind of animation with the three dots here?
                        Text("...")
                            .padding(13)
                            .background(Color.white.opacity(0.6))
                            .foregroundColor(Color.black.opacity(0.7))
                            .cornerRadius(20)
                    } else {
                        Text(message.text)
                        //.frame(minWidth: screenWidth * 0, idealWidth: screenWidth * 0.1 , maxWidth: screenWidth * 0.6, alignment: .leading)
                            .padding(13)
                            .background(Color.white.opacity(0.6))
                            .foregroundColor(Color.black.opacity(0.7))
                            .cornerRadius(20)
                    }
                    Spacer()
                }
            // a game info PSA
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
    var viewModel: NGViewModel
    var messages: [NGViewModel.Message]
    //let animationDuration: Double = 0.5
    var body: some View{
        ZStack {
            ScrollView {
                ScrollViewReader { scrollView in
                    VStack {
                        ForEach(messages){ message in
                            MessageView(message: message).padding([.horizontal,.top], 8)
                        }
                        HStack{
                            Spacer()
                        }.id("Empty")
                    }.onChange(of: messages){ _ in
                        withAnimation(.easeOut(duration: viewModel.animDuration)){
                            scrollView.scrollTo("Empty", anchor: .bottom)
                        }
                    }
                }
                .animation(.linear(duration: viewModel.animDuration))
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

