//
//  SelectModelScreen.swift
//  Negotiation
//
//

import SwiftUI

struct SelectModelScreen: View {
    @ObservedObject var viewModel: NGViewModel
    @State private var name : String = ""
    @State private var showNameField = false
    @State private var StartGame = false
    @State private var goBack = false
    @State private var loadNames = false
    @State private var toTitlePage = false
    @State private var playerAlreadyExists = false
    
    
    
    var names: [String] {viewModel.playerNames}  // get the names to display here
    
    @State var selectedOption: Int = 0
    
    var body: some View {
        
        NavigationStack {
            VStack {
                NavigationLink(destination: ContentView(viewModel: viewModel, player_name : $name).navigationBarBackButtonHidden(true), isActive: $StartGame, label: {})
                    // when we enter the contentview, reset the game variables
                    .onChange(of: StartGame) { (newValue) in
                        if newValue { viewModel.resetGame() }
                    }
                NavigationLink(destination: TitleScreen(viewModel: viewModel).navigationBarBackButtonHidden(true), isActive: $toTitlePage, label: {})
        
                if showNameField {
                    
                    VStack{
                        VStack{
                            Spacer()
                            HStack{
                                Spacer()
                                textFieldView(name: $name)
                                nextPageButton(action: {
                                    playerAlreadyExists = viewModel.createNewPlayer(newName: name);
                                    if viewModel.playerAlreadyExists == false {
                                        StartGame = true;
                                        viewModel.firstTime = true;
                                        showNameField = false}
                                }).disabled(name.isEmpty)
                                    .background((name.isEmpty) ? Color.gray : Color.green)
                                    .cornerRadius(50)
                                    // error message to show if the player already exists
                                    .alert(isPresented: $playerAlreadyExists) {
                                        Alert(title: Text("This player already exists"),
                                              message: Text("This username is already in use, please consider entering a different name, or removing the exisiting user."),
                                              dismissButton: .default(Text("OK"), action: {playerAlreadyExists = false}))
                                    }
                                Spacer()
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                    
                } else if loadNames {
                    VStack{
                        Spacer()
                        HStack{
                            VStack{
                                HStack{
                                    Picker("", selection: $selectedOption){
                                        ForEach(0..<names.count, id: \.self){
                                            index in
                                            Text(names[index]).foregroundColor(Color.black)
                                                .onAppear{  name = names[index]  }
                                        }
                                    }.pickerStyle(MenuPickerStyle())
                                        .frame(width:200)
                                        .background(Color.white.opacity(0.4))
                                        .cornerRadius(20)
                                    
                                }
                                
                                removePlayerButton(action: {
                                    viewModel.removePlayer(name: name);
                                    if !names.isEmpty {name = names[0]} else {loadNames=false; goBack = false}
                                })
                            }
                            nextPageButton(action: {StartGame = true; viewModel.loadModel(name: name);     viewModel.firstTime = false; selectedOption = 0}).background(Color.green).cornerRadius(50)
                            
                        }
                        Spacer()
                    }
                } else {
                    VStack {
                        Spacer()
                        HStack{
                            Spacer()
                            SelectModelScreenButton(text: "New Session", action: {showNameField = true
                                goBack = true
                            })
                            Spacer()
                        }
                        HStack{
                            Spacer()
                            if !names.isEmpty{
                                SelectModelScreenButton(text: "Load Session", action: {loadNames = true
                                    goBack = true
                                })
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                }
            }

        }
        .background(backgroundImg(image:"secondbackground")).ignoresSafeArea(.all)
        .toolbar {
            // middle of top toolbar: show the round # out of 5
            ToolbarItem(placement:.navigationBarLeading){backButton(action: {
                if loadNames || showNameField {
                    loadNames = false
                    showNameField = false
                } else {
                    toTitlePage = true
                }})}
        }
    }
}

extension View{
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View{
            
            ZStack(alignment: alignment){
                placeholder().opacity(shouldShow ? 1 : 0 )
                self
            }
        }
}



struct backButton: View{
    let action: ()->Void

    var body: some View{
        HStack{
            Button(action:action){
                HStack(spacing:5){
                    Image(systemName: "chevron.backward")
                    Text("Back")
                }
                //.padding(.all)
                .foregroundColor(Color.white)
                Spacer()
            }
        }
    }
}



struct removePlayerButton: View {
    var action: () -> Void
    @State private var showingAlert = false
    
    var body: some View {
        Button(String("Remove Player")) {showingAlert = true}
            .font(.subheadline)
            .buttonStyle(.borderedProminent)
            .cornerRadius(50)
            .tint(.red.opacity(0.85))
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Are you sure you would like to delete this user?"),
                      message: Text("There is no undoing this action. All of the user's data will be deleted."),
                      primaryButton: .destructive(
                        Text("Confirm"),
                        action: action
                      ), secondaryButton: .cancel())
            }
        }
}

struct textFieldView: View {
    @Binding var name: String
    
    var body: some View{
        ZStack(alignment: .leading){
            TextField("", text:$name)
                .placeholder(when: name.isEmpty){  Text("Enter your name").foregroundColor(.black.opacity(0.6))}
                .padding()
                .frame(width:200)
                .background(Color.white)
                .foregroundColor(Color.black)
                .cornerRadius(20)
        }.onAppear{name = ""}
    }
}

struct nextPageButton: View{
    let action: ()->Void
    
    var body: some View{
        Button(action: action){Image(systemName: "paperplane")}
            .frame(width: 50, height:50)
            .foregroundColor(.white)
            .buttonStyle(CustomButtonStyle())        
    }
}
struct SelectModelScreenButton: View{
    
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




struct SelectModelScreen_Previews: PreviewProvider {
    static var previews: some View {
        SelectModelScreen(viewModel: NGViewModel())
    }
}
