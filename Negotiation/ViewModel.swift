// this is the VIEWMODEL file


import Foundation

class NGViewModel: ObservableObject {
    @Published private var model = NGModel()
    var verbose: Bool {model.verbose}
    
    // MARK: ########  Acess to the Model   ########
    
    /// We need to make vars for:
    /// - player and model score
    /// - player and model MSE
    /// -
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
    
    var playerScore: String {String(model.playerScore)}
    var modelScore: String {String(model.modelScore)}
    var playerMNS: String {String(model.playerMNS)}
    var modelMNS: String {String(model.modelMNS)}
    
    var playerIsFinalOffer: Bool {model.playerIsFinalOffer}
    var modelIsFinalOffer: Bool {model.modelIsFinalOffer}
    
    
    // MARK: ##########     Intents     ############
    
    /// a function for when the player makes an offer
    func playerMakeOffer(value: Float, isFinal: Bool) {
        /// overwrite the (now-outdated) previous offer
        
        model.playerPreviousOffer = model.playerCurrentOffer
        model.playerCurrentOffer = Int(value)
        if verbose {print("VM: player offer made! = " + String(value) + ", is final = " + String(isFinal))}  // check to see if the button works
        // call a function in the model here !
        model.placeholderResponse(playerOffer: value, playerIsFinalOffer: isFinal)
    }
    
    // player quits negotiation, no need to change any scores so just reset everything
    func playerQuits () {
        if verbose {print("VM: player has quit")}
        model.playerHasQuit = true
        model.newRound()
    }
    // player accepts the model's offer
    func playerAccepts () {
        if verbose {print("VM: player has accepted the model's offer")}
        
        /// change the value of the player's offer in accordance to their acceptance of the model's offer
        /// (e.g. the player's "new offer" is whats left of the 9 points)
        model.playerCurrentOffer = 9 - (Int(modelNegotiationValue) ?? 0)
        
        model.newRound()
    }
    
    func saveModel() {
        model.testSave()
    }
    func loadModel() {
        model.testLoad()
    }
}
