// this is the VIEWMODEL file


import Foundation
import SwiftUI

class NGViewModel: ObservableObject {
    @Published private var model : NGModel
    @Published var messages: [Message] = []
    
    // variables relating to the game state and game management
    var currentRound: Int  {model.currentRoundNumber}
    var numberOfRounds: Int  {model.maxRoundNumber}
    @Published var offerHasBeenMade: Bool = false
    @Published var MNSDeclared: Bool = false
    var quitButtonText: String {
        if model.modelIsFinalOffer==true{
        return "Reject Offer"}
        else{ return "Quit Round"}}
    
    var playerNames: [String] {model.playerNames}
    var currentPlayerName: String {model.currentPlayerName!}
    
    // player and model states
    var playerScore: Int {Int(model.playerScore)}
    var modelScore: Int {Int(model.modelScore)}
    var playerMNS: Int {Int(model.playerMNS)}
    var modelMNS: Int {Int(model.modelMNS)}
    /// dealing with model variables that are optionals
    var playerNegotiationValue: String {
        if let val = model.playerCurrentOffer {return String(val)}
        else {return "N/A"}    }
    var modelNegotiationValue: String {
        if let val = model.modelCurrentOffer {return String(val)}
        else {return "N/A"}    }
    var playerDeclaredMNS: Int? {
        if let val = model.playerDeclaredMNS {return val}
        else {return nil}    }
    var modelDeclaredMNS: Int? {
        if let val = model.modelDeclaredMNS {return val}
        else {return nil}    }
    var playerIsFinalOffer: Bool {model.playerIsFinalOffer}
    var modelIsFinalOffer: Bool {model.modelIsFinalOffer}
    var isPlayerTurn: Bool = false
    var playerIsNext: Bool = false // this is a temporary vairable, used to make isPlayerTurn true after animations have finished
    var animDuration: Double = 0.5
    
    
    init() {
        model = NGModel() // make just one active model file
        model.pickMNS()
    }
    
    
    
    
    
    
    // MARK: ########  THE PLAYER'S INTENETS  ########
    
    
    /// a function when the player declares their MNS
    func declarePlayerMNS(value: Float){
        model.playerDeclaredMNS = Int(value)
        self.sendMessage("My MNS is " + String(Int(value)), isMe: true, PSA : false)
        
        // Now the model responds
        
        /// seemed to cause problems
        /*
         DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { //makes it more lifelike i guess when adding a wait
            self.model.declareModelMNS()
            self.sendMessage("My MNS is " + String(self.model.modelDeclaredMNS!), isMe: false, PSA: false)
            self.MNSDeclared = true  // if the model has declared its MNS, then so has the player
        }
         */
        
        isPlayerTurn = false
        model.declareModelMNS()
        sendMessage("My MNS is " + String(model.modelDeclaredMNS!), isMe: false, PSA: false)
        MNSDeclared = true  // if the model has declared its MNS, then so has the player
        
        playerIsNext = true
        
        
        
        
        
    }
    
    // this function deals with processing the player's offer
    func playerMakeOffer(playerBid: Float) {
        if self.playerIsFinalOffer {
            self.sendMessage("This is my final offer: " + String(Int(playerBid)) + " points for me, " + String(9 - Int(playerBid)) + " for you.", isMe: true, PSA: false)
        } else {
            // check if the player is insisting
            if let playerLastOffer = model.playerCurrentOffer{
                if Int(playerBid) == playerLastOffer{
                    model.playerInsists = true
                }
                else{model.playerInsists = false}
            }
            //send message
            if model.playerInsists == true{
                let string = String(format: insistMSGs.randomElement()!, Int(playerBid), Int(9-playerBid))
                self.sendMessage(string, isMe: true, PSA: false)
            }
            else{
                let string = String(format: bidMSGs.randomElement()!, Int(playerBid), Int(9-playerBid))
                self.sendMessage(string, isMe: true, PSA: false)
            }
        
            //self.sendMessage("This is my offer: I want " + String(Int(playerBid))  + " points, you'd get " + String(9 - Int(playerBid)) + " points", isMe: true, PSA: false)
        }
        
        isPlayerTurn = false
        
        
        model.playerPreviousOffer = model.playerCurrentOffer
        model.playerCurrentOffer = Int(playerBid)
        
        if model.playerPreviousOffer != nil { model.playerMoveType = "Bid" }
        else {model.playerMoveType = "Opening"}
        
        // playerIsFinal is toggled with the button anyway, so no need to have it here as well
        
        offerHasBeenMade = true
        
        modelResponseMessage()
        playerIsNext = true
        
        
        
    }
    
    
    // player accepts the model's offer
    func playerAccepts () {
        self.sendMessage(acceptingSentencesNeutral.randomElement()!, isMe: true, PSA: false)
        model.playerMoveType = "Decision";     model.playerDecision = "Accept"
        model.playerPreviousOffer = model.playerCurrentOffer
        
        model.modelResponse() // model has to save this experience
        
        interRoundScoreDisplay(playerDecided:true, decisionAccept:true)
    }
    
    // player rejects the model's offer
    func playerRejectsFinalOffer() {
        self.sendMessage(decliningSentencesNeutral.randomElement()!, isMe: true, PSA: false)
        model.playerMoveType = "Decision";     model.playerDecision = "Reject"
        model.playerHasQuit = true
        model.playerPreviousOffer = model.playerCurrentOffer
        
        model.modelResponse() // model has to save this experience
        
        interRoundScoreDisplay(playerDecided:true, decisionAccept:false)
    }
    
    func playerQuitsRound() {
        self.sendMessage("I want to quit this negotiation.",  isMe: true, PSA: false)
        model.playerMoveType = "Quit";     model.playerDecision = "Quit"
        model.playerHasQuit = true
        model.playerPreviousOffer = model.playerCurrentOffer
        
        model.modelResponse() // model has to save this experience
        
        interRoundScoreDisplay(playerDecided:true, decisionAccept:false)
    }
    
    
    // MARK: Model
    
    
    func modelResponseMessage() {
        
        // make the cognitive model respond
        model.modelResponse()
        
        // if the model accepts the player's bid
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
        // if the model rejects the player's bid
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
        
        // if the model quits the game
        else if model.modelMoveType == "Quit" {
            self.sendMessage("I want to quit this negotiation.",  isMe: false, PSA: false)
            interRoundScoreDisplay(playerDecided:false, decisionAccept:false)
        }
        
        // The model makes a new bid
        else if (model.modelMoveType == "Bid" || model.modelMoveType == "Opening") && model.modelIsFinalOffer == false {
            
            if model.modelIsFinalOffer == true {
                let msg = "This is my final offer, I want " + String(model.modelCurrentOffer!) + " points, you would get " + String(9-model.modelCurrentOffer!) + " points"
                self.sendMessage(msg, isMe: false, PSA: false)
            }
            else if model.modelInsists == true {
                let string = String(format: insistMSGs.randomElement()!, model.modelCurrentOffer!, 9-model.modelCurrentOffer!)
                self.sendMessage(string, isMe: false, PSA: false)
            }
            else{
                let string = String(format: bidMSGs.randomElement()!, model.modelCurrentOffer!, 9-model.modelCurrentOffer!)
                self.sendMessage(string, isMe: false, PSA: false)
            }
            
        }
        

    }
    
    
    
    
    
    // MARK: Game management
    
    func FinalOfferPlayerChanged(){
        model.playerIsFinalOffer.toggle()
    }
    
    func resetGame() {
        model.resetGameVariables(newGame: true)  // reset the game variables when returning to the ContentView
        openingNewGame()
        offerHasBeenMade = false;     MNSDeclared = false
    }
    
    func loadModel(name: String) {   // this function gets used when picking a model
        model.currentPlayerName = name
        model.loadPlayerModel(playerName: name)
    }
    
    func createNewPlayer(newName: String){
        model.currentPlayerName = newName
        model.playerNames.insert(newName, at: 0)  // insert new player to start of playerNames list, means they become the first option on the selection page
    }
    
    func removePlayer(name: String) -> Void {
        if let index = model.playerNames.firstIndex(of: name) {
            model.playerNames.remove(at: index)  // removes the player from the list of names in the Model file
            deletePlayerFile(name: name)         // removes the ACT-R model json file (this function is defined in JSONManager.swift)
        } else {
            print("VM: Can't remove player, name not found")
        }
    }
    
    
    // MARK: ########  MESSAGING FUNCTIONS  ########
    
    struct Message: Identifiable, Equatable {
        let id = UUID()
        let text:String
        let sender: Bool //true is the player flase is the model
        let PSA: Bool
    }
    
    
    // simple sendMessage function isMe: true if the player is the sender false is the model. PSA is the grey messages about MNSs and score changes
    func sendMessage(_ text:String, isMe: Bool, PSA: Bool){
        
        // MARK: This allows the model and the game to take 1 second before the message animation starts
        var delay: Double {if isMe {return 0.0} else {return 1.0}}
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.messages.append(Message(text: text, sender: isMe, PSA: PSA))
        }
        
        // MARK: This is to delay the player's buttons becoming active while animations are running
        DispatchQueue.main.asyncAfter(deadline: .now() + animDuration) {
            if self.playerIsNext {self.isPlayerTurn=true; self.playerIsNext = false}
        }
    
    }
    
    
    func openingNewGame() {
        sendMessage("Your MNS for this round is " + String(playerMNS), isMe: false, PSA: true)
        //isPlayerTurn = true
        playerIsNext = true
    }
    
    // function to display the grey messages (PSAs) about score changes and the player MNS value for a new round
    func interRoundScoreDisplay(playerDecided: Bool, decisionAccept: Bool){
        
        if decisionAccept == true {
            if playerDecided == true {
                sendMessage("You earned " + String((9 - model.modelCurrentOffer!) - playerMNS) + " points this round.", isMe: false, PSA: true)}
            else{
                sendMessage("You earned " + String((9 - model.playerCurrentOffer!) - playerMNS) + " points this round.", isMe: false, PSA: true)}}
        else{sendMessage("No points were earned this round.", isMe: false, PSA: true)}
        
        // make a new round, once the PSAs have been sent
        model.newRound(playerOffered: !playerDecided)
        MNSDeclared = false
        offerHasBeenMade = false
        playerIsNext = true
        
        
        if currentRound < numberOfRounds {
            sendMessage("Your MNS for the next round is " + String(playerMNS), isMe: false, PSA: true)
        }
        
        
        
    }
        
    
}
