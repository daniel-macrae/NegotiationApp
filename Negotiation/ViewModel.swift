// this is the VIEWMODEL


import Foundation

class NGViewModel: ObservableObject {
    @Published private var model = NGModel()
    
    // MARK: ########  Acess to the Model   ########
    
    /// We need to make vars for:
    /// - player and model score
    /// - player and model MSE
    /// -
    ///
    var playerNegotiationValue: String {String(model.playerNegotiationValue)}
    var modelNegotiationValue: String {String(model.modelNegotiationValue)}
    
    var playerScore: String {String(model.playerScore)}
    var modelScore: String {String(model.modelScore)}
    var playerMNS: String {String(model.playerMNS)}
    var modelMNS: String {String(model.modelMNS)}
    
    
    // MARK: ##########     Intents     ############
    
    /// a function for when the player makes an offer
    func playerMakeOffer(value: Float) {
        /// overwrite the (now-outdated) previous offer
        model.playerPreviousOffer = model.playerCurrentOffer
        print("offer made! = " + String(value))  // check to see if the button works
        // call a function in the model here !
        model.placeholderResponse(playerOffer: value)
    }
    
}
