// this is the VIEWMODEL file


import Foundation

class NGViewModel: ObservableObject {
    @Published private var model = NGModel()
    @Published var messages: [Message] = []
    var verbose: Bool {model.verbose}
    @Published var offerHasBeenMade: Bool = false
    
    ///SENTENCES for accepting and declining an offer in a happy/neutral and angry tone
    let acceptingSentencesNeutral = [
        "I accept your offer.",
        "That's acceptable, I'm in.",
        "Sounds good, I accept.",
        "Count me in, I accept.",
        "I'm happy to accept.",
        "I agree, I accept.",
        "I'm ready to proceed, I accept.",
        "Yes, let's do it, I accept.",
        "I'm fine with that, I accept.",
        "Alright, I accept."
    ]

    let decliningSentencesNeutral = [
        "I must decline, thank you.",
        "I'm unable to accept, thanks.",
        "I appreciate the offer, but I must decline.",
        "That won't be possible, thanks.",
        "Thanks for the offer, but I can't accept.",
        "Unfortunately, I have to decline.",
        "Thank you, but I can't accept.",
        "I'm honored, but I have to decline.",
        "I'm sorry, but I have to decline.",
        "I'm unable to accept at this time."
    ]
    
    let acceptingSentencesHappy = [
        "Yes! Thank you so much!",
        "Awesome, I'm in!",
        "Absolutely, I accept!",
        "Yay! Let's do it!",
        "I'm thrilled, I accept!",
        "Fantastic, count me in!",
        "Yes, this is perfect!",
        "I'm excited, I accept!",
        "This is great news, I accept!",
        "Thank you, I'm so happy to accept!"
    ]

    let acceptingSentencesAngry = [
        "Fine, I'll accept.",
        "Whatever, I accept.",
        "Okay, I guess I'll accept.",
        "Sure, I accept.",
        "If I have to, I'll accept.",
        "Ugh, fine, I accept.",
        "I suppose I'll accept.",
        "Joy of joys, I accept.",
        "Alright, I'll accept.",
        "Don't get too excited, but I accept."
    ]

    let decliningSentencesHappy = [
        "Thanks, but I'm going to decline.",
        "I appreciate the offer, but I'll pass.",
        "Thank you, but I have to say no.",
        "That's very kind, but I can't accept.",
        "I'm grateful, but I have to decline.",
        "I'm honored, but I'll have to say no.",
        "Thanks for considering me, but I'll decline.",
        "I appreciate it, but I can't accept.",
        "I'm flattered, but I'll have to decline.",
        "Thanks, but I'll have to pass."
    ]

    let decliningSentencesAngry = [
        "No way, not interested.",
        "Absolutely not, don't waste my time.",
        "You must be joking, no thanks.",
        "Not a chance, no thanks.",
        "You've got to be kidding me, no way.",
        "Nope, not interested.",
        "I don't think so, no thanks.",
        "Save your breath, no thanks.",
        "I'm not even going to dignify that with a response.",
        "Don't even bother asking."
    ]

    
    
    // MARK: ########  Acess to the Model   ########
    /// We need to make vars for:
    /// - player and model score
    /// - player and model MSE

    struct Message: Identifiable, Equatable{
        let id = UUID()
        let text:String
        let sender: Bool //true is the player flase is the model
    }
    
    var playerNegotiationValue: String {
        let val = model.playerCurrentOffer
        if val != 0 {return String(val)}
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
        model.declareModelMNS()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { //makes it more lifelike i guess when adding a wait
            self.SendModelMNS()
        }
    }
    
    func SendModelMNS(){
        sendMessage("My MNS is " + String(model.ModelDeclMNSValueGet()), isMe: false)
    }
    
    //simple sendMessage function isMe: true is the player is the sender false is the model
    func sendMessage(_ text:String, isMe: Bool){
        messages.append(Message(text: text, sender: isMe))
    }
    

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
        
        self.offerHasBeenMade = true
        
        //The code below causes a crash probably due to the rules not being fully implemented or working with a nill value
        //model.modelResponse(playerOffer: Int(value), playerIsFinalOffer: isFinal)
    }
    
    // player accepts the model's offer
    func playerAccepts () {
        self.sendMessage("I accept your offer of " + String(modelNegotiationValue), isMe: true)
        /// change the value of the player's offer in accordance to their acceptance of the model's offer
        /// (e.g. the player's "new offer" is whats left of the 9 points)
        //model.playerCurrentOffer = 9 - (Int(modelNegotiationValue) ?? 0)
        //offerHasBeenMade needs to change to offer has been made by model so that the player can only accept when both are willing to accept
        offerHasBeenMade = false
        model.newRound(playerOffered: true)
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
