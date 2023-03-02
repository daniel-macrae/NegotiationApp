// This is the MODEL file

import Foundation



struct NGModel {
    // for printing of errors and function calls
    var verbose = true
    
    // MARK: Game state management
    var MNS_combinations: Array<(Int, Int)> = [(2,2),(1,3),(3,1),(2,2),(3,3),(2,3),(3,2),(3,4),(4,3),(2,4),(4,4)]
    /// Model's total score
    var modelScore = 0
    /// Player's total score
    var playerScore = 0
    /// Player's MNS, score and reward
    var playerMNS: Int = 2
    var modelMNS: Int = 3   /// CHANGE
    
    
    // MARK: Player and Model offer management
    var playerPreviousOffer: Int?
    var playerCurrentOffer: Int?  // work on how to display this if it has no value?
    var modelPreviousOffer: Int?
    var modelCurrentOffer: Int?  // same here
    var playerIsFinalOffer = false
    var modelIsFinalOffer = false
    var playerHasQuit = false
    var modelHasQuit = false
    
    /// Boolean that states whether the model is waiting for an action.
    var waitingForAction = true
    
    internal var model = Model()
    
    
    // functions to save and load the model (calls functions from JSONManger.swift file)
    mutating func testSave() {
        saveModel2(model: model, filename: "test")  // function that does the actual saving
        print("M: model saved")
    }
    
    mutating func testLoad() {
        model = loadModel2(filename: "test")  // loading the model
        print("M: model loaded")
        //print(model.dm)
        //print(model.imaginalActionTime)
        //print(model.time)
    }
    
    
    
    /// Here we do not actually load in anything: we just reset the model
    /// - Parameter filename: filename to be loaded (extension .actr is added by the function)
    func resetModel(filename: String) {
        model.reset()
        model.waitingForAction = true
    }
    
    
    func saveModel(filename: String) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(model)        /// convert the model to JSON
            print(String(data: data, encoding: .utf8)!)  /// print to console
        } catch {
            print("M: failure to save model")
        }
    }
    
    // placeholder function (implement the actual model later...)
    // this is just to figure out how to pass info back and forth
    mutating func placeholderResponse(playerOffer: Float, playerIsFinalOffer: Bool) {
        if verbose {print("M: model is responding/making a new offer")}
        modelPreviousOffer = modelCurrentOffer
        modelCurrentOffer = Int.random(in: 1..<10)  /// model makes a completely random offer
        
        modelIsFinalOffer = !modelIsFinalOffer   /// just flip the boolean for now
        
        
    }
    
    
    // select new MNSs for both players (call this once a round finishes)
    mutating func pickMNS() {
        if verbose {print("M: picking new MNS values")}
        if let randomMNS = MNS_combinations.randomElement() {
            playerMNS = randomMNS.0
            modelMNS = randomMNS.1
        }
        else { /// this should never happen, but swift won't pick a randomElement without it :/
            print("M: MNS error!")
        }
    }
    
    
    // add the current round scores to the total score
    mutating func updateScores() {
        if verbose {print("M: updating scores")}
        playerScore += (playerCurrentOffer! - playerMNS)
        modelScore += (modelCurrentOffer! - modelMNS)
    }
    
    // the round has ended, clean up and start a new one
    mutating func newRound() {
        if verbose {print("M: preparing new negotiation round")}
        // if neither player has quit, an agreement was made and their scores should be updated
        if !(playerHasQuit || modelHasQuit) {
            updateScores()
        }
        // reset offer history
        playerPreviousOffer = nil; playerCurrentOffer = nil
        modelPreviousOffer = nil; modelCurrentOffer  = nil
        playerIsFinalOffer = false; modelIsFinalOffer = false
        playerHasQuit = false; modelHasQuit = false
        
        // new MNS values for the next round
        pickMNS()
        
        // start next round, player makes move
        model.waitingForAction = true
        
        update()
        
    }
    
    
    
    
    
    
    
        
        
    // ###########################################
    // MARK: leftover code scraps below this !
    // just to look at, really
    // ###########################################

    
    
    
    
    
    
    
    /// The trace from the model
    var traceText: String = ""
    /// The model code
    var modelText: String = ""
    /// Part of the contents of DM that can needs to be displayed in the interface
    var dmContent: [PublicChunk] = []
    
    /// String that is displayed to show the outcome of a round
    var feedback = ""
    /// Amount of points the model gets
    var modelreward = 0
    /// Amount of points the player gets
    var playerreward = 0
        
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

