//
//  SwiftUIView.swift
//  Negotiation
//
//

import SwiftUI

struct gameOverView: View {
    @ObservedObject var viewModel: NGViewModel
    @State var isQuitting :Bool = false
    @State var newGame : Bool = false
    @State var player_name: String = ""
    
    var displayImg: String {
        if viewModel.playerScore > viewModel.modelScore {
            return "win"
        } else if viewModel.playerScore == viewModel.modelScore {
            return "tie"
        } else { return "lose" }
    }

    var body: some View {
        NavigationStack{
            NavigationLink(destination: TitleScreen(viewModel: viewModel).navigationBarBackButtonHidden(true), isActive: $isQuitting, label: {})
            NavigationLink(destination: ContentView(viewModel: viewModel, player_name : $player_name).navigationBarBackButtonHidden(true), isActive: $newGame, label: {})
                .onChange(of: newGame) { (newValue) in
                    if newValue { viewModel.resetGame() }
                }
            VStack{
                    Spacer()
                    Image(displayImg)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding([.top, .leading, .trailing], 20)
                        .scaleEffect(0.7)
                    
                    statsView(playerPoints: Int(viewModel.playerScore), modelPoints: Int(viewModel.modelScore))
                    Spacer()
                FinalButtons(isQuitting: $isQuitting, newGame: $newGame).padding(.vertical)

                
            }.background(backgroundImg(image: "secondbackground"))
        }
    }
}

struct FinalButtons: View{
    @Binding var isQuitting: Bool
    @Binding var newGame: Bool

    var body: some View{
        VStack{
            gameOverButton(text: "New Game", action: {
                newGame = true
            }, buttonColor: Color(UIColor(red:0.40, green:0.30, blue:0.76, alpha: 0.75)))
            gameOverButton(text: "Return to Start", action: {
                isQuitting = true
            }, buttonColor: Color.red)
        }
    }
}

struct statsView: View{
    
    var playerPoints: Int
    var modelPoints: Int
    var body: some View{
        VStack{
            Text("Your points: " + String(playerPoints))
                .padding([.top,.horizontal])
            Text("Model points: " + String(modelPoints)).padding([.bottom, .horizontal])
        }                        .background(Color.white.opacity(0.5))
            .cornerRadius(20)
    }
}


struct gameOverButton: View{
    let text: String
    let action: () -> Void
    let buttonColor : Color
    
    var body: some View {
            Button(text, action: action)
                .frame(width: 160, height:50)
                .foregroundColor(.white)
                .background(buttonColor)
                .buttonStyle(CustomButtonStyle())
                .cornerRadius(50)
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        let model = NGViewModel()
        gameOverView(viewModel: model)
    }
}
