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
            NavigationLink(destination: TitleScreen().navigationBarBackButtonHidden(true), isActive: $isQuitting, label: {})
            NavigationLink(destination: ContentView(viewModel: NGViewModel(), player_name : $player_name).navigationBarBackButtonHidden(true), isActive: $newGame, label: {})
            VStack{
                if viewModel.playerScore > viewModel.modelScore{
                    Spacer()
                    Text("You win")
                    Spacer()
                    FinalButtons(isQuitting: $isQuitting, newGame: $newGame)
                    Spacer()
                    
                } else if viewModel.playerScore == viewModel.modelScore {
                    Spacer()
                    Text("It's a tie")
                    Spacer()
                    FinalButtons(isQuitting: $isQuitting, newGame: $newGame)
                    Spacer()
                    
                } else {
                    Spacer()
                    Text("You lost")
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

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        let model = NGViewModel()
        gameOverView(viewModel: model)
    }
}
