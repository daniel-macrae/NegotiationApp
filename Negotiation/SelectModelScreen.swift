//
//  SelectModelScreen.swift
//  Negotiation
//
//  Created by Mandy Slagter on 10/03/2023.
//

import SwiftUI

struct SelectModelScreen: View {
    @State private var name : String = ""
    @State private var showNameField = false
    @State private var StartGame = false
    @State private var goBack = false
    @State private var loadNames = false
    @State private var selectedOption = 0
    
    
    let names = ["N1", "N3", "asda"]
    //var names = [String]()
    
    var body: some View {
        NavigationStack{
            NavigationLink(destination: ContentView(viewModel: NGViewModel(), player_name : $name), isActive: $StartGame, label: {})
            ZStack{
                if showNameField{
                    VStack{
                        HStack{
                            Button(action: {showNameField=false
                                goBack=false
                            }){HStack(spacing:5){
                                Image(systemName: "chevron.backward")
                                Text("Back")
                            }}
                            .padding(.all).foregroundColor(Color.white)
                            Spacer()
                        }
                        VStack{
                            Spacer()
                            HStack{
                                Spacer()
                                ZStack(alignment: .leading){
                                    TextField("", text:$name)
                                        .placeholder(when: name.isEmpty){  Text("Enter your name").foregroundColor(.black.opacity(0.6))}
                                        .padding()
                                        .frame(width:200)
                                        .background(Color.white)
                                        .foregroundColor(Color.black)
                                        .cornerRadius(20)
                                }
                                nextPageButton(action: {StartGame = true})
                                Spacer()
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                } else if loadNames {
                    VStack{
                        HStack{
                            Button(action: {loadNames=false
                                goBack=false
                            }){HStack(spacing:5){
                                Image(systemName: "chevron.backward")
                                Text("Back")
                            }}
                            .padding(.all).foregroundColor(Color.white)
                            Spacer()
                        }
                        Spacer()
                        HStack{
                            Spacer()
                            Picker("", selection: $selectedOption){
                                ForEach(0..<names.count, id: \.self){
                                    index in Text(names[index]).foregroundColor(Color.black)
                                }
                            }.pickerStyle(MenuPickerStyle())
                                .frame(width:200)
                                .background(Color.white.opacity(0.4))
                                .cornerRadius(20)
                            
                            nextPageButton(action: {StartGame = true})
                            Spacer()
                        }
                        Spacer()
                    }
                } else {
                    VStack{
                        Spacer()
                        HStack{
                            Spacer()
                            SelectModelScreenButton(text: "New Player", action: {showNameField = true
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
            }.background(backgroundImg(image:"secondbackground"))
        }.navigationBarBackButtonHidden(goBack)
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

struct nextPageButton: View{
    let action: ()->Void
    
    var body: some View{
        Button(action: action){Image(systemName: "paperplane")}
            .frame(width: 50, height:50)
            .foregroundColor(.white)
            .background(Color.green)
            .cornerRadius(50)
        
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
        SelectModelScreen()
    }
}
