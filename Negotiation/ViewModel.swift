// this is the VIEWMODEL file


import Foundation

class NGViewModel: ObservableObject {
    @Published private var model = NGModel()
    @Published var player_name : String = ":placeholder:"
    @Published var messages: [Message] = []
    var verbose: Bool {model.verbose}
   
    
    // MARK: ########  Acess to the Model   ########
    
    struct Message: Identifiable, Equatable{
        let id = UUID()
        let text:String
        let sender: Bool
        
    }
    /// We need to make vars for:
    /// - player and model score
    /// - player and model MSE
    /// -
    ///
    ///
    ///
    var playerNegotiationValue: String {
        let val = model.playerCurrentOffer
        if val != nil {return String(val!)}
        else {return "N/A"}
        }
    
    var modelNegotiationValue: String {
        let val = model.modelCurrentOffer
        if val != nil {return String(val!)}
        else {return "N/A"}
        }
    
    var playerScore: Float {Float(model.playerScore)}
    var modelScore: Float {Float(model.modelScore)}
    var playerMNS: Float {Float(model.playerMNS)}
    var modelMNS: Float {Float(model.modelMNS)}
    
    var playerIsFinalOffer: Bool {model.playerIsFinalOffer}
    var modelIsFinalOffer: Bool {model.modelIsFinalOffer}
    
    
    // MARK: ##########     Intents     ############
    
    /// a function when the player declares their MNS
    func declarePlayerMNS(value: Float){
        model.playerDeclaredMNS = Int(value)
        self.sendMessage("My MNS is " + String(Int(value)), isMe: true)
        //: TODO MAKE MODEL AWARE of MNS
        //call function for the model to declare MSN
        model.declareModelMNS()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.SendModelMNS()
        }
    }
    
    func SendModelMNS(){
        sendMessage("My MNS is" + String(Int(modelMNS)), isMe: false)
    }
    func sendMessage(_ text:String, isMe: Bool){
        messages.append(Message(text: text, sender: isMe))
    }
    
    /// a function for when the player makes an offer
    ///
    ///
    func playerMakeOffer(value: Float, isFinal: Bool) {
        /// overwrite the (now-outdated) previous offer
        if isFinal {
            self.sendMessage("This is my final offer " + String(Int(value)) , isMe: true)
            // TODO Make model aware of offer and that it is final offer
        } else {
            self.sendMessage("This is my offer " + String(Int(value)) , isMe: true)
            // TODO Make model aware of offer
        }
        model.playerPreviousOffer = model.playerCurrentOffer
        model.playerCurrentOffer = Int(value)
        
        //The code below causes a crash probably due to the rules not being fully implemented or working with a nill value
        //model.modelResponse(playerOffer: value, playerIsFinalOffer: isFinal)
        
    }
    
    // player accepts the model's offer
    func playerAccepts () {
        self.sendMessage("I accept your offer of " + String(modelNegotiationValue), isMe: true)
        /// change the value of the player's offer in accordance to their acceptance of the model's offer
        /// (e.g. the player's "new offer" is whats left of the 9 points)
        //model.playerCurrentOffer = 9 - (Int(modelNegotiationValue) ?? 0)
        
        //model.newRound()
    }
    func setPlayerName(name: String){
        self.player_name = name
    }
    func FinalOfferPlayerChanged(){
        model.playerIsFinalOffer.toggle()
        print(model.playerIsFinalOffer)
    }
    
    func saveModel() {
        model.testSave()
    }
    func loadModel() {
        model.testLoad()
    }
    
}
