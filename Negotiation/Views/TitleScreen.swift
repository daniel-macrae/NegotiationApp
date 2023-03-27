import SwiftUI

struct TitleScreen: View {
    
    @ObservedObject var viewModel: NGViewModel
    
    @State private var isShowingText = false
    @State private var nextPage = false
    
    
   
    var body: some View {
       
        NavigationStack{
            ZStack{
                NavigationLink(destination: SelectModelScreen(viewModel: viewModel).navigationBarBackButtonHidden(true), isActive: $nextPage, label: {})
                    
                VStack{
                    Image("text1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding([.top, .leading, .trailing], 20)
                    Text("Press anywhere to continue")
                        .padding(.top, -3.0)
                        .foregroundColor(.white)
                        .onAppear(){
                            withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)){
                                isShowingText.toggle()
                            }
                        }.opacity(isShowingText ? 0 : 1)
                    Spacer()
                }
            }.background(backgroundImg(image:"TS_BG_IMG")).onTapGesture {
                nextPage = true
            }
        }.accentColor(.white)
    }
    }
struct backgroundImg: View{
    
    let image : String
    
    var body: some View{
        GeometryReader { geo in
        Image(image)
            .resizable()
            .edgesIgnoringSafeArea(.all)
            .aspectRatio(contentMode: .fill)
        .frame(width: geo.size.width,height: geo.size.height)}
    }
}
struct TitleScreen_Previews: PreviewProvider {
    static var previews: some View {
        TitleScreen(viewModel: NGViewModel())
    }
}
