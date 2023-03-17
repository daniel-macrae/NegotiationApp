// this is the VIEWMODEL file


import Foundation
import SwiftUI

class NGViewModel: ObservableObject {
    @Published private var model : NGModel
    @Published var messages: [Message] = []
    var verbose: Bool {model.verbose}
    
    @Published var numberOfRounds: Int = 5
    @Published var offerHasBeenMade: Bool = false
    @Published var currentRound: Int = 1
    @Published var MNSDeclared: Bool = false
    
    var playerScore: Int {Int(model.playerScore)}
    var modelScore: Int {Int(model.modelScore)}
    var playerMNS: Int {Int(model.playerMNS)}
    var modelMNS: Int {Int(model.modelMNS)}
    
    init() {
        model = NGModel()
        sendMessage("Your MNS for this round is " + String(playerMNS), isMe: false, PSA: true)
    }
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
        let PSA: Bool
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
    
    
    
    var playerDeclaredMNS: Int? {
        if let val = model.playerDeclaredMNS {return val}
        else {return nil}
    }
    var modelDeclaredMNS: Int? {
        if let val = model.modelDeclaredMNS {return val}
        else {return nil}
    }
    
    var playerIsFinalOffer: Bool {model.playerIsFinalOffer}
    var modelIsFinalOffer: Bool {model.modelIsFinalOffer}
    
    
    // MARK: ##########     Intents     ############
    
    /// a function when the player declares their MNS
    func declarePlayerMNS(value: Float){
        model.playerDeclaredMNS = Int(value)
        self.sendMessage("My MNS is " + String(Int(value)), isMe: true, PSA : false)
        model.declareModelMNS()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { //makes it more lifelike i guess when adding a wait
            self.SendModelMNS()
        }
    }
    
    func SendModelMNS(){
        sendMessage("My MNS is " + String(model.ModelDeclMNSValueGet()), isMe: false, PSA: false)
        MNSDeclared = true  // if the model has declared its MNS, then so has the player
    }
    
    //simple sendMessage function isMe: true is the player is the sender false is the model
    func sendMessage(_ text:String, isMe: Bool, PSA: Bool){
        messages.append(Message(text: text, sender: isMe, PSA: PSA))
    }
    

    // this function deals with processing the player's offer
    func playerMakeOffer(playerBid: Float) {
        /// overwrite the (now-outdated) previous offer
        if self.playerIsFinalOffer {
            self.sendMessage("This is my final offer: " + String(Int(playerBid)) + " points for me, " + String(9 - Int(playerBid)) + " for you.", isMe: true, PSA: false)
            // TODO Make model aware of offer and that it is final offer
        } else {
            self.sendMessage("This is my offer: I want " + String(Int(playerBid))  + " points, you'd get " + String(9 - Int(playerBid)) + " points", isMe: true, PSA: false)
            // TODO Make model aware of offer
        }
        model.playerPreviousOffer = model.playerCurrentOffer
        model.playerCurrentOffer = Int(playerBid)
        model.playerMoveType = "Bid"
        
        self.offerHasBeenMade = true
        
        modelResponding()
        
    }
    
    // this function tells the model file to respond to an offer, and then deals with the message to send
    func modelResponding() {
        
        // make the cognitive model respond
        model.modelResponse()
        
        // JUST ADD A self.sendMessage HERE !?!
        if model.modelMoveType == "Decision" && model.modelDecision! == "Accept" {
            self.sendMessage("I accept your offer", isMe: false, PSA: false)
            interRoundScoreDisplay(playerDecided:false,decisionAccept:true)
        }
        else if model.modelMoveType == "Decision" && model.modelDecision! == "Reject" {
            self.sendMessage("I reject your final offer", isMe: false, PSA: false)
            interRoundScoreDisplay(playerDecided:false,decisionAccept:false)
        }
        else if model.modelMoveType == "Quit" {
            self.sendMessage("I want to quit this negotiation.",  isMe: false, PSA: false)
            interRoundScoreDisplay(playerDecided:false, decisionAccept:false)
        }
        else if (model.modelMoveType == "Bid" || model.modelMoveType == "Opening") && model.modelIsFinalOffer == false {
            print("VM: model has responded with move type = " + model.modelMoveType)
            self.sendMessage("I want " + String(model.modelCurrentOffer!) + " points, you would get " + String(9-model.modelCurrentOffer!) + " points", isMe: false, PSA: false)
        }
        else if (model.modelMoveType == "Bid" || model.modelMoveType == "Opening") {
            let msg = "This is my final offer, I want " + String(model.modelCurrentOffer!) + " points, you would get " + String(9-model.modelCurrentOffer!) + " points"
            self.sendMessage(msg, isMe: false, PSA: false)
        }
    }
    
    
    // player accepts the model's offer
    func playerAccepts () {
        self.sendMessage("I accept your offer", isMe: true, PSA: false)
        model.playerMoveType = "Decision";     model.playerDecision = "Accept"
 
        interRoundScoreDisplay(playerDecided:true, decisionAccept:true)
    }
    
    // player rejects the model's offer
    func playerRejectsFinalOffer() {
        self.sendMessage("I reject your final offer", isMe: true, PSA: false)
        model.playerMoveType = "Decision";     model.playerDecision = "Reject"
      
        interRoundScoreDisplay(playerDecided:true, decisionAccept:false)
    }
    
    func playerQuitsRound() {
        self.sendMessage("I want to quit this negotiation.",  isMe: true, PSA: false)
        model.playerMoveType = "Quit";     model.playerDecision = "Quit"
        model.playerHasQuit = true
        
        interRoundScoreDisplay(playerDecided:true, decisionAccept:false)
    }
   

    // function to display the grey messages about score changes and the player MNS value for a new round
    func interRoundScoreDisplay(playerDecided: Bool, decisionAccept: Bool){
        if decisionAccept == true {
            if playerDecided == true{
                sendMessage("You earned " + String((9 - model.modelCurrentOffer!) - model.playerMNS) + " points this round.", isMe: false, PSA: true)}
            else{
                sendMessage("You earned " + String((9 - model.playerCurrentOffer) - model.modelMNS) + " points this round.", isMe: false, PSA: true)}}
        else{sendMessage("No points were earned this round.", isMe: false, PSA: true)}
        offerHasBeenMade = false
        model.playerIsFinalOffer = !playerDecided
        currentRound += 1
        model.newRound(playerOffered: !playerDecided)
        
        MNSDeclared = false // new round, neither player has declared their MNS
        sendMessage("Your MNS for the next round is " + String(playerMNS), isMe: false, PSA: true)
    }
    
    func FinalOfferPlayerChanged(){
        model.playerIsFinalOffer.toggle()
    }
    
    func resetGame() {
        model.resetGameVariables(newGame: true)  // reset the game variables when returning to the ContentView
    }
    
    
    func saveModel() {    // this button will be removed, so delete this later. it should be done automatically between rounds anyway, in my opinion
        model.testSave()
    }
    func loadModel(name: String) {   // this function gets used when picking a model
        model.testLoad(fileName: name)
    }
    
    func getLoadFilesNames() -> [String]{
        return model.loadFilesNames
    }
    //Needs proper implementation
    func createNewLoadFile(fileName: String){
        model.loadFilesNames.append(fileName)
    }
}
