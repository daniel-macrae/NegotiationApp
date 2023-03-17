// this is the VIEWMODEL file


import Foundation
import SwiftUI

class NGViewModel: ObservableObject {
    @Published private var model : NGModel
    @Published var messages: [Message] = []
    var verbose: Bool {model.verbose}
    
    var currentRound: Int  {model.currentRoundNumber}
    var numberOfRounds: Int  {model.maxRoundNumber}
    @Published var offerHasBeenMade: Bool = false
    
    @Published var MNSDeclared: Bool = false
    
    var playerScore: Int {Int(model.playerScore)}
    var modelScore: Int {Int(model.modelScore)}
    var playerMNS: Int {Int(model.playerMNS)}
    var modelMNS: Int {Int(model.modelMNS)}
    
    init() {
        model = NGModel()
        sendMessage("Your MNS for this round is " + String(playerMNS), isMe: false, PSA: true)
    }
    
    
    
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
    
    
    
    
    // MARK: ########  THE PLAYER'S INTENETS  ########
    
    
    /// a function when the player declares their MNS
    func declarePlayerMNS(value: Float){
        model.playerDeclaredMNS = Int(value)
        self.sendMessage("My MNS is " + String(Int(value)), isMe: true, PSA : false)
        
        // Now the model responds
        model.declareModelMNS()
        sendMessage("My MNS is " + String(model.modelDeclaredMNS!), isMe: false, PSA: false)
        MNSDeclared = true  // if the model has declared its MNS, then so has the player
    
        /// seemed to cause problems
        //DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { //makes it more lifelike i guess when adding a wait
        //    }
        
        
    }
    
    
    
    
    
    // this function deals with processing the player's offer
    func playerMakeOffer(playerBid: Float) {
        if self.playerIsFinalOffer {
            self.sendMessage("This is my final offer: " + String(Int(playerBid)) + " points for me, " + String(9 - Int(playerBid)) + " for you.", isMe: true, PSA: false)
        } else {
            let string = String(format: bidMSGs.randomElement()!, Int(playerBid), Int(9-playerBid))
            self.sendMessage(string, isMe: true, PSA: false)
            
            //self.sendMessage("This is my offer: I want " + String(Int(playerBid))  + " points, you'd get " + String(9 - Int(playerBid)) + " points", isMe: true, PSA: false)
        }
        model.playerPreviousOffer = model.playerCurrentOffer
        model.playerCurrentOffer = Int(playerBid)
        model.playerMoveType = "Bid"
        // playerIsFinal is toggled with the button anyway, so no need to have it here as well
        
        self.offerHasBeenMade = true
        
        modelResponseMessage()
        
    }
    
    func modelResponseMessage() {
        
        // make the cognitive model respond
        model.modelResponse()
        print("MODEL MOOD = ", model.modelStrategy)
        
        // JUST ADD A self.sendMessage HERE !?!
        if model.modelMoveType == "Decision" && model.modelDecision! == "Accept" {
            
            switch model.modelStrategy {
                case "Cooperative":
                    self.sendMessage(acceptingSentencesHappy.randomElement()!, isMe: false, PSA: false)
                case "Aggressive":
                    self.sendMessage(acceptingSentencesAngry.randomElement()!, isMe: false, PSA: false)
                case "Neutral":
                    self.sendMessage(acceptingSentencesNeutral.randomElement()!, isMe: false, PSA: false)
                default:
                    self.sendMessage("I accept your offer", isMe: false, PSA: false)
            }
            
            interRoundScoreDisplay(playerDecided:false,decisionAccept:true)
            
        }
        else if model.modelMoveType == "Decision" && model.modelDecision! == "Reject" {
            switch model.modelStrategy {
                case "Cooperative":
                    self.sendMessage(decliningSentencesHappy.randomElement()!, isMe: false, PSA: false)
                case "Aggressive":
                    self.sendMessage(decliningSentencesAngry.randomElement()!, isMe: false, PSA: false)
                case "Neutral":
                    self.sendMessage(decliningSentencesNeutral.randomElement()!, isMe: false, PSA: false)
                default:
                    self.sendMessage("I reject your final offer.", isMe: false, PSA: false)
            }
   
            interRoundScoreDisplay(playerDecided:false,decisionAccept:false)
            
        }
        
        else if model.modelMoveType == "Quit" {
            self.sendMessage("I want to quit this negotiation.",  isMe: false, PSA: false)
            interRoundScoreDisplay(playerDecided:false, decisionAccept:false)
        }
        else if (model.modelMoveType == "Bid" || model.modelMoveType == "Opening") && model.modelIsFinalOffer == false {
            let string = String(format: bidMSGs.randomElement()!, model.modelCurrentOffer!, 9-model.modelCurrentOffer!)
            self.sendMessage(string, isMe: false, PSA: false)
            
            //self.sendMessage("I want " + String(model.modelCurrentOffer!) + " points, you would get " + String(9-model.modelCurrentOffer!) + " points", isMe: false, PSA: false)
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
        model.playerHasQuit = true
        
        interRoundScoreDisplay(playerDecided:true, decisionAccept:false)
    }
    
    func playerQuitsRound() {
        self.sendMessage("I want to quit this negotiation.",  isMe: true, PSA: false)
        model.playerMoveType = "Quit";     model.playerDecision = "Quit"
        model.playerHasQuit = true
        
        //model.newRound(playerOffered: false)
        interRoundScoreDisplay(playerDecided:true, decisionAccept:false)
    }
    
    
    // function to display the grey messages (PSAs) about score changes and the player MNS value for a new round
    func interRoundScoreDisplay(playerDecided: Bool, decisionAccept: Bool){
        if decisionAccept == true {
            if playerDecided == true {
                sendMessage("You earned " + String((9 - model.modelCurrentOffer!) - model.playerMNS) + " points this round.", isMe: false, PSA: true)}
            else{
                sendMessage("You earned " + String((9 - model.playerCurrentOffer) - model.modelMNS) + " points this round.", isMe: false, PSA: true)}}
        else{sendMessage("No points were earned this round.", isMe: false, PSA: true)}
        offerHasBeenMade = false
        model.playerIsFinalOffer = !playerDecided
        
        
        // make a new round, once the PSAs have been sent
        model.newRound(playerOffered: !playerDecided)
        
        MNSDeclared = false // new round, neither player has declared their MNS
        sendMessage("Your MNS for the next round is " + String(playerMNS), isMe: false, PSA: true)
    }
    
    func FinalOfferPlayerChanged(){
        model.playerIsFinalOffer.toggle()
    }
    
    func resetGame() {
        model.resetGameVariables(newGame: true)  // reset the game variables when returning to the ContentView
        MNSDeclared = false
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
    
    
    
    // MARK: ########  MESSAGING FUNCTIONS  ########
    
    
    //simple sendMessage function isMe: true is the player is the sender false is the model
    func sendMessage(_ text:String, isMe: Bool, PSA: Bool){
        messages.append(Message(text: text, sender: isMe, PSA: PSA))
    }
    
    
    
    
    
    
    
    // SENTENCES the messages between players
    let bidMSGs = [
        "I'll bid %d points, you'd get %d.",
        "I want %d points, which leaves %d for you.",
        "I want %d points, which would leave %d points for you.",
        "What about %d points for me, and %d points for you?",
        "I'd like to do this; %d points for me, %d for you. How does that sound?",
        "We can split the 9 points like this; %d to me, %d for you."
        
    ]
    
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
    
    
}
