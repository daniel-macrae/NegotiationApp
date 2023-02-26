// This is the MODEL file

import Foundation


// maybe an enum for the actions?


struct NGModel {
    /// The trace from the model
    var traceText: String = ""
    /// The model code
    var modelText: String = ""
    /// Part of the contents of DM that can needs to be displayed in the interface
    var dmContent: [PublicChunk] = []
    /// Boolean that states whether the model is waiting for an action.
    var waitingForAction = true
    /// String that is displayed to show the outcome of a round
    var feedback = ""
    // MARK: Game state management
    /// Amount of points the model gets
    var modelreward = 0
    /// Amount of points the player gets
    var playerreward = 0
    /// Model's total score
    var modelScore = 0
    /// Player's total score
    var playerScore = 0
    /// The ACT-R model
    var playerMNS = 2
    var modelMNS = 3
    
    // MARK: Player and Model offer management
    var playerNegotiationValue = 1
    var modelNegotiationValue = 2
    var playerPreviousOffer = Offer.none
    var playerCurrentOffer = Offer.none
    var modelPreviousOffer = Offer.none
    var modelCurrentOffer = Offer.none
    
   
    // an attempt at making a neat dictiory, that failed...
    ///var offerHistory[String:Offer] = ["prev player bid": Offer.none,
    ///                    "current player bid": Offer,
    ///                 "prev model bid": Offer,
    ///                    "current model bid": Offer.none ]
    
    internal var model = Model()
    
    /// Here we do not actually load in anything: we just reset the model
    /// - Parameter filename: filename to be loaded (extension .actr is added by the function)
    func loadModel(filename: String) {
        model.reset()
        model.waitingForAction = true
    }
    
    /// an enum to represent the possible offers the model and the player can make
    enum Offer: CustomStringConvertible {
        case Concede(value: Int, isFinal: Bool)
        case Raise(value: Int, isFinal: Bool)
        case Insist(isFinal: Bool)  // value will always be 0
        case StopNegotiation
        case none // no bids have been made (e.g. its the start of the game)
        
        var description: String {
            switch self {
            case .Concede:
                return "concede"
            case .Raise:
                return "raise"
            case .Insist:
                return "insist"
            case .StopNegotiation:
                return "stop negotiation"
            case .none:
                return "N/A"
            }
        }
    }
    
    mutating func placeholderResponse(playerOffer: Float) {
        modelPreviousOffer = modelCurrentOffer
        modelCurrentOffer = Offer.Concede(value: 1, isFinal: false)
        modelNegotiationValue = 4
    }
    
    
    
        
        
    // ###########################################
    // MARK: leftover code scraps below this !
    // ###########################################

        
    /// Enum to represent the choices. It is always good to use enums for internal representation, because
    /// they can help you with preventing bugs. (e.g., if you use strings it is easy to make a typo)
    enum Choice: CustomStringConvertible {
        case cooperate
        case defect
        var description: String {
            switch self {
            case .cooperate:
                return "coop"
            case .defect:
                return "defect"
            }
        }
    }
    
    /// These represent the current and previous choice by the player and the model. They are optionals
    /// because they don't have values right away
    private var lastModel: Choice?
    private var lastPlayer: Choice?
    private var currentModel: Choice?
    private var currentPlayer: Choice?
        
    /// Run the model until it has made a decision,
    /// which means it waits for a response
    /// At the start of the call, currentModel and currentPlayer contain the choices of the last round (unless this is the first round),
    /// and lastModel and lastPlayer the choice from the round before that (unless this is the first or second round)
    mutating func run() {
        if currentModel == nil {
            currentModel = actrNoise(noise: 1.0) > 0 ? .cooperate : .defect
            model.time += 1.0
            model.addToTrace(string: "First decision: random pick")
        } else if lastModel == nil {
            lastModel = currentModel
            lastPlayer = currentPlayer
            currentModel = lastPlayer // tit for tat
            model.time += 1.0
            model.addToTrace(string: "Second decision: tit for tat")
        } else {
            lastModel = currentModel
            lastPlayer = currentPlayer
            let query = Chunk(s: "query", m: model)
            query.setSlot(slot: "model", value: lastModel!.description)
            query.setSlot(slot: "player", value: lastPlayer!.description)
            let (latency, chunk) = model.dm.retrieve(chunk: query)
            if let newPlayer = chunk?.slotvals["new-player"]?.description {
                currentModel = newPlayer == "coop" ? .cooperate : .defect
                model.addToTrace(string: "Retrieving \(chunk!)")
            } else {
                currentModel = lastPlayer
                model.addToTrace(string: "Failed retrieval, tit for tat instead")
            }
            model.time += 1.0 + latency
        }
            update()
        waitingForAction = true
    }
    
    /// Reset the model and the game
    mutating func reset() {
        model.reset()
        model.waitingForAction = true
        modelScore = 0
        playerScore = 0
        feedback = ""
        lastModel = nil
        lastPlayer = nil
        currentModel = nil
        currentPlayer = nil
        run()
    }
        
    /// Function that is executed whenever the player makes a choice. At that point
    /// the model has already made a choice, so the score can then be calculated,
    /// and can be shown in the display. The function also adds a chunk to memory that
    /// reflects the experience.
    /// - Parameter playerAction: "coop" or "defect"
    mutating func choose(playerAction: String) {
       guard currentModel != nil else { return }
        model.addToTrace(string: "Player chooses \(playerAction)")
        currentPlayer = playerAction == "coop" ? Choice.cooperate : Choice.defect
        switch (currentPlayer!, currentModel!) {
        case (.cooperate,.cooperate):
             modelreward = 1
             playerreward = 1
        case (.cooperate,.defect):
             modelreward = 10
             playerreward = -10
        case (.defect,.cooperate):
             modelreward = -10
             playerreward = 10
        case (.defect,.defect):
             modelreward = -1
             playerreward = -1
        }
        modelScore += modelreward
        playerScore += playerreward
        feedback = "The model chooses \(currentModel!)\nYou get \(playerreward) and I get \(modelreward)\n"
        feedback += "Model score is \(modelScore) and the player's score is \(playerScore)\n"
        if (lastModel != nil && lastPlayer != nil) {
            let newExperience = model.generateNewChunk(string: "instance")
            newExperience.setSlot(slot: "model", value: lastModel!.description)
            newExperience.setSlot(slot: "player", value: lastPlayer!.description)
            newExperience.setSlot(slot: "new-player", value: playerAction)
            model.dm.addToDM(newExperience)
        }
        model.time += 1.0
        run()
        update()
    }
    
    mutating func update() {
            self.traceText = model.trace
            self.modelText = model.modelText
            dmContent = []
            var count = 0
            for (_,chunk) in model.dm.chunks {
                var slots: [(slot: String,val: String)] = []
                for slot in chunk.printOrder {
                    if let val = chunk.slotvals[slot] {
                        slots.append((slot:slot, val:val.description))
                    }
                }
                dmContent.append(PublicChunk(name: chunk.name, slots: slots, activation: chunk.activation(),id: count))
                count += 1
            }
            dmContent.sort { $0.activation > $1.activation }
            waitingForAction = true
        }

}

