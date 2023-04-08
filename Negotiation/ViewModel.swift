// this is the VIEWMODEL file


import Foundation
import SwiftUI

class NGViewModel: ObservableObject {
    @Published private var model : NGModel
    @Published var messages: [Message] = []
    
    // variables relating to the game state and game management
    var currentRound: Int  {model.currentRoundNumber}
    var numberOfRounds: Int  {model.maxRoundNumber}
    var gameOver: Bool = false
    
    @Published var offerHasBeenMade: Bool = false
    @Published var MNSDeclared: Bool = false
    var quitButtonText: String {
        if model.modelIsFinalOffer==true{
        return "Reject Offer"}
        else{ return "Quit Round"}}
    
    var playerNames: [String] {model.playerNames}
    var currentPlayerName: String {model.currentPlayerName!}
    var firstTime: Bool = false
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
    var playerDeclaredMNS: Int?
    var modelDeclaredMNS: Int?
    var playerIsFinalOffer: Bool {model.playerIsFinalOffer}
    var modelIsFinalOffer: Bool {model.modelIsFinalOffer}
    @Published var isPlayerTurn: Bool = false
    @Published var playerIsNext: Bool = false // this is a temporary vairable, used to make isPlayerTurn true after animations have finished
    @Published var animDuration: Double = 0.5
    @Published var displayDeclaredMNS: Bool = false
    @Published var playerAlreadyExists: Bool = false // to toggle error message if the user inputs a player name that already exists
    
    
    // TIMING
    var playerResponseStartTime = Date() /// is reset whenever the player's bid buttons become active
    //var playerResponseDuration: Double?
    
    init() {
        model = NGModel() // make just one active model file
        model.pickMNS()
    }
    
    
    
    
    
    
    // MARK: ########  THE PLAYER'S INTENETS  ########
    
    
    /// a function when the player declares their MNS
    func declarePlayerMNS(value: Float){
        model.playerResponseDuration = Double(Date().timeIntervalSince(playerResponseStartTime))
         
        model.playerDeclaredMNS = Int(value)
        let pString = String(format: mnsDeclarationMSGs.randomElement()!, Int(value))
        sendMessage(pString, isMe: true, PSA : false)
        
        isPlayerTurn = false
        playerIsNext = true
        
        // make the model determine its MNS
        model.declareModelMNS()
        
        // based on the model's trategy, find a message template to declare its MNS
        switch model.modelStrategy {
            case "Cooperative":
                let mString = String(format: mnsResponseMSGsCoopNeutral.randomElement()!, model.modelDeclaredMNS!)
                sendMessage(mString, isMe: false, PSA: false)
            case "Aggressive":
                let mString = String(format: mnsResponseMSGsAggressive.randomElement()!, model.modelDeclaredMNS!)
                sendMessage(mString, isMe: false, PSA: false)
            case "Neutral":
                let mString = String(format: mnsResponseMSGsCoopNeutral.randomElement()!, model.modelDeclaredMNS!)
                sendMessage(mString, isMe: false, PSA: false)
            default:
                let mString = String(format: "My MNS is %d", model.modelDeclaredMNS!)
                sendMessage(mString, isMe: false, PSA: false)
        }
        
        MNSDeclared = true  // if the model has declared its MNS, then so has the player
        
    }
    
    // this function deals with processing the player's offer
    func playerMakeOffer(playerBid: Float) {
        model.playerResponseDuration = Double(Date().timeIntervalSince(playerResponseStartTime))
        
        if self.playerIsFinalOffer {
            self.sendMessage("This is my final offer: " + String(Int(playerBid)) + " points for me, " + String(9 - Int(playerBid)) + " for you.", isMe: true, PSA: false)
        } else {
            // check if the player is insisting
            if let playerLastOffer = model.playerCurrentOffer {
                if Int(playerBid) == playerLastOffer {
                    model.playerInsists = true
                }
                else{model.playerInsists = false}
            }
            //send message
            if model.playerInsists == true {
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
        
        playerIsNext = true
        modelResponseMessage()
        
        
        
        
    }
    
    
    // player accepts the model's offer
    func playerAccepts () {
        model.playerResponseDuration = Double(Date().timeIntervalSince(playerResponseStartTime))
        
        self.sendMessage(acceptingSentencesNeutral.randomElement()!, isMe: true, PSA: false)
        model.playerMoveType = "Decision";     model.playerDecision = "Accept"
        model.playerPreviousOffer = model.playerCurrentOffer
        
        model.modelResponse() // model has to save this experience
        
        interRoundScoreDisplay(playerDecided:true, decisionAccept:true)
    }
    
    // player rejects the model's offer
    func playerRejectsFinalOffer() {
        model.playerResponseDuration = Double(Date().timeIntervalSince(playerResponseStartTime))
        
        self.sendMessage(decliningSentencesNeutral.randomElement()!, isMe: true, PSA: false)
        model.playerMoveType = "Decision";     model.playerDecision = "Reject"
        model.playerHasQuit = true
        model.playerPreviousOffer = model.playerCurrentOffer
        
        model.modelResponse() // model has to save this experience
        
        interRoundScoreDisplay(playerDecided:true, decisionAccept:false)
    }
    
    func playerQuitsRound() {
        model.playerResponseDuration = Double(Date().timeIntervalSince(playerResponseStartTime))
        
        self.sendMessage("I want to quit this negotiation.",  isMe: true, PSA: false)
        model.playerMoveType = "Quit";     model.playerDecision = "Quit"
        model.playerHasQuit = true
        model.playerPreviousOffer = model.playerCurrentOffer
        
        model.modelResponse() // model has to save this experience
        
        interRoundScoreDisplay(playerDecided:true, decisionAccept:false)
    }
    
    
    // MARK: Model
    
    
    func modelResponseMessage() {
        
        //messages.append(Message(text: "...", sender: false, PSA: false))
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
            DispatchQueue.main.asyncAfter(deadline: .now() + sigmoid(model.modelResponseDuration) + animDuration) {
                self.interRoundScoreDisplay(playerDecided:false,decisionAccept:true)
            }
            
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
            
            DispatchQueue.main.asyncAfter(deadline: .now() + sigmoid(model.modelResponseDuration)  + animDuration) {
                self.interRoundScoreDisplay(playerDecided:false,decisionAccept:false)
            }
            
            //interRoundScoreDisplay(playerDecided:false,decisionAccept:false)
            
        }
        
        // if the model quits the game
        else if model.modelMoveType == "Quit" {
            self.sendMessage("I want to quit this negotiation.",  isMe: false, PSA: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + sigmoid(model.modelResponseDuration)  + animDuration) {
                self.interRoundScoreDisplay(playerDecided:false,decisionAccept:false)
            }
            //interRoundScoreDisplay(playerDecided:false, decisionAccept:false)
        }
        
        // The model makes a new bid
        else if (model.modelMoveType == "Bid" || model.modelMoveType == "Opening") {
            
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
        modelDeclaredMNS = nil; playerDeclaredMNS = nil
        gameOver = false
    }
    
    func loadModel(name: String) {   // this function gets used when picking a model
        model.loadPlayerModel(playerName: name)
    }
    
    func createNewPlayer(newName: String) -> Bool {
        playerAlreadyExists = model.addNewPlayer(newName: newName)
        return playerAlreadyExists
    }
    
    func removePlayer(name: String) -> Void {
        model.removePlayer(name: name)
    }
    
    
    // MARK: ########  MESSAGING FUNCTIONS  ########
    
    struct Message: Identifiable, Equatable {
        let id = UUID()
        let text:String
        let sender: Bool //true is the player flase is the model
        let PSA: Bool
    }
    
    // function to bound the times down
    func sigmoid(_ x: Double) -> Double {
        return tanh((x/15.0)) * 8
    }
    
    
    // simple sendMessage function isMe: true if the player is the sender false is the model. PSA is the grey messages about MNSs and score changes
    func sendMessage(_ text:String, isMe: Bool, PSA: Bool){
        
        isPlayerTurn = false
        
        var delay: Double
        if isMe {delay = 0.0} // if the player is sending a message
        else {delay = 1.0}
        
        var modelDuration: Double // how long until the model's full message should be sent
        if isMe || PSA {modelDuration = 0.0}
        else {
            modelDuration = model.modelResponseDuration
            modelDuration = sigmoid(modelDuration) // limit the duration so that its not unbearably long
        }
        
        // controls the delay of the messages showing up
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            
            // if the model is sending a message, it should show the 'typing' animation for as long as the model needs to make an offer ("modelDuration"), and then this text message box is filled with the actual offer
            if isMe==false && PSA==false {
                
                self.messages.append(Message(text: "...", sender: false, PSA: false))
                
                DispatchQueue.main.asyncAfter(deadline: .now() + modelDuration) {
                    
                    if let modelMessIndex = self.messages.lastIndex(where: {$0.text == "..."}) {
                        self.messages[modelMessIndex] = Message(text: text, sender: false, PSA: false)
                        if let val = self.model.modelDeclaredMNS {self.modelDeclaredMNS = val} // toggle display of declared MNS after the model has sent its message
                    }
                }
                
            }
            // player and PSA messages fall into this conditon
            else {
                self.messages.append(Message(text: text, sender: isMe, PSA: PSA))
                if let val = self.model.playerDeclaredMNS {self.playerDeclaredMNS = val}
            }
        }
        
        // This is to delay the player's buttons becoming active while animations are running
        // basically, it prevents the player from making bids while the model is active, or while a new round is being prepared
        if isMe == false && playerIsNext == true {
            DispatchQueue.main.asyncAfter(deadline: .now() + (1.5*animDuration) + delay + modelDuration) {
                self.makePlayerButtonsActive()
            }
        }
    }
    
    
    // this funtion allows the other functions to toggle whether the player's buttons are clickable
    func makePlayerButtonsActive() {
        if playerIsNext {
            isPlayerTurn = true
            playerIsNext = false
            playerResponseStartTime = Date()
        }
    }
    
    
    func openingNewGame() {
        isPlayerTurn = false
        
        sendMessage("Your MNS for this round is " + String(playerMNS), isMe: false, PSA: true)
        playerIsNext = true
        let string = String(format: openingMSGs.randomElement()!, currentPlayerName)
        sendMessage(string, isMe: false, PSA: false)

        
    }
    
    //func removeMessage() {
    //    messages[messages.endIndex-1] = Message(text: "...", sender: false, PSA: false)
    //}
    
    // function to display the grey messages (PSAs) about score changes and the player MNS value for a new round
    func interRoundScoreDisplay(playerDecided: Bool, decisionAccept: Bool){
        
        if decisionAccept == true {
            if playerDecided == true {
                sendMessage("You earned " + String((9 - model.modelCurrentOffer!) - playerMNS) + " points this round.", isMe: false, PSA: true)}
            else{
                sendMessage("You earned " + String((model.playerCurrentOffer!) - playerMNS) + " points this round.", isMe: false, PSA: true)}}
        else{sendMessage("No points were earned this round.", isMe: false, PSA: true)}
        
        // make a new round, once the PSAs have been sent
        model.newRound(playerOffered: !playerDecided)
        MNSDeclared = false
        offerHasBeenMade = false
        playerIsNext = true
        displayDeclaredMNS = false
        modelDeclaredMNS = nil; playerDeclaredMNS = nil
        
        
        if !model.gameOver {
            sendMessage("Your MNS for the next round is " + String(playerMNS), isMe: false, PSA: true)
            gameOver = false
        } else {
            gameOver = true
            model.gameOver = false
            
        }
        
        
        
    }
        
    
}
