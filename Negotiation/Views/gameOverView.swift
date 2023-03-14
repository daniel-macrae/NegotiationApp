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

    var body: some View {
        NavigationStack{
            NavigationLink(destination: TitleScreen(viewModel: viewModel).navigationBarBackButtonHidden(true), isActive: $isQuitting, label: {})
            NavigationLink(destination: ContentView(viewModel: viewModel, player_name : $player_name).navigationBarBackButtonHidden(true), isActive: $newGame, label: {})
            VStack{
                if viewModel.playerScore > viewModel.modelScore{
                    Spacer()
                    Image("win")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding([.top, .leading, .trailing], 20)
                        .scaleEffect(0.7)
                    
                    statsView(playerPoints: Int(viewModel.playerScore), modelPoints: Int(viewModel.modelScore))
                    Spacer()
                    FinalButtons(isQuitting: $isQuitting, newGame: $newGame)
                    Spacer()
                    
                } else if viewModel.playerScore == viewModel.modelScore {
                    Spacer()
                    Image("tie")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding([.top, .leading, .trailing], 20)
                        .scaleEffect(0.7)
                    statsView(playerPoints: Int(viewModel.playerScore), modelPoints: Int(viewModel.modelScore))
                    Spacer()
                    FinalButtons(isQuitting: $isQuitting, newGame: $newGame)
                    Spacer()
                    
                } else {
                    Spacer()
                    Image("lose")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding([.top, .leading, .trailing], 20)
                        .scaleEffect(0.7)
                    statsView(playerPoints: Int(viewModel.playerScore), modelPoints: Int(viewModel.modelScore))
                    Spacer()
                    FinalButtons(isQuitting: $isQuitting, newGame: $newGame)
                    Spacer()
                    
                }
            }.background(backgroundImg(image: "secondbackground"))
        }
    }
}

struct FinalButtons: View{
    @Binding var isQuitting: Bool
    @Binding var newGame: Bool

    var body: some View{
        HStack{
            GameButton(text: "New Game", action: {
                newGame = true
            })
            QuitButton(text: "Return to Start", action: {
                isQuitting = true
            })
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

//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        let model = NGViewModel()
//        gameOverView(viewModel: model)
//    }
//}
