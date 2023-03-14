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
    var modelMNS: Int = 3  /// CHANGE
    
    var playerDeclaredMNS: Int?
    var modelDeclaredMNS: Int?
    
    // MARK: Player and Model offer management
    var playerPreviousOffer: Int?
    var playerCurrentOffer: Int = 0 // work on how to display this if it has no value?
    var modelPreviousOffer: Int?
    var modelCurrentOffer: Int?  // same here
    var playerIsFinalOffer = false
    var modelIsFinalOffer = false
    var playerHasQuit = false
    var modelHasQuit = false
    //agressive or cooperative
    var playerStrategy: String?
    var modelStrategy: String?
    //concede, insist or raise
    var playerMoveType: String?
    var modelMoveType: String?
    
    //Need some function to get these from JSONManager
    var loadFilesNames: [String] = ["loadfile1", "loadfile2", "thisNeedsImplementation"]
    
    /// Boolean that states whether the model is waiting for an action.
    var waitingForAction = true
    
    internal var model = Model()
    
    
    // functions to save and load the model (calls functions from JSONManger.swift file)
    mutating func testSave() {
        saveModel(model: model, filename: "test")  // function that does the actual saving
        print("M: model saved")
    }
    
    mutating func testLoad(fileName: String) {
        model = loadModel(name: fileName)  // loading the model
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
    
    
    mutating func declareModelMNS(){
        modelDeclaredMNS = Int(arc4random_uniform(9)) + 1
 //think how we want to do this
        // model should probably retrieve a chunk with the right mns to max change of succes 
    }
   
    // the strategy chunk can be used to set the mood of the UI too
    
    mutating func modelResponse(playerOffer: Int, playerIsFinalOffer: Bool){
        //maybe this things should be three different functions
        let changePlayerBid = playerOffer - playerPreviousOffer!

        
//DETECT STRATEGY // In the paper they use how usually the player concedes
        
        //they offer what they are keeping out of the nine
        if let modelDecMNS = modelDeclaredMNS{
            if modelDecMNS < (9 - playerOffer){ // see how we want to define this. now NOT INCLUDING NEUTRAL
                playerStrategy = "agressive"
            } else{ playerStrategy = "cooperative"}
            //reinforce strategy chunk (maybe addEncounter???)
            let (latency, _) = model.dm.retrieve(chunk: Chunk(s: playerStrategy!, m: model))
            model.time += 1.0 + latency
        }
//DECIDE MODEL'S MOVE
        if verbose {print("M: model is responding/making a new offer")}
            // first offer
            if modelCurrentOffer == nil{
                // MARK: I think this can be retrieved with a chunk now, using just the keys "myMNS"=modelMNS and "myMoveType"="Opening" and "opponentMoveType"="Opening" (the chunks do contain the move type, so this should work)
                
                modelCurrentOffer = Int.random(in: modelMNS..<10)  /// model makes a completely random offer above their MNS
                model.time += 1.0
                model.addToTrace(string: "First decision: random pick")
            }
        else{// im assuming the playes goes first (so here previousPlayerOffer is ensured
            
            //determine players move type
            // MARK: the way the chunks are in the paper, the only (useful) values for the player's move type are "Bid" and "Opening", so I changed the query chunk slot value to "Bid", but we can still use the three lines below for generating the player's text message for the UI - Dan
            if changePlayerBid > 0 {playerMoveType = "raise"}
            else if changePlayerBid == 0 {playerMoveType = "insist"}
            else {playerMoveType = "concede"}
            
            //
            // MARK: CHUNK SLOT NAMES ARE NOW:
            // "myStrategy","myMNS","myBidMNSDifference","opponentMoveType","opponentMove","opponentIsFinal",
            // "myMoveType","myMove","myIsFinal"
            // - Dan
            /// (where 'opponentMove' and 'myMove' are the player's and model's change in bid value respectively)
            
            modelPreviousOffer = modelCurrentOffer
            let query = Chunk(s: "query", m: model)
            // i dont get why retrieve MNS-Bid Diff
            query.setSlot(slot: "myStrategy", value: playerStrategy!)
            //query.setSlot(slot: "myBidMNSDifference", value: "Something") /// String(modelCurrentOffer-modelMNS) ?
            query.setSlot(slot: "opponentMove", value: changePlayerBid.description)
            //query.setSlot(slot: "opponentIsFinal", value: playerIsFinalOffer)
            query.setSlot(slot: "opponentMoveType", value: "Bid")
            
            let (latency, chunk) = model.dm.retrieve(chunk: query)
            //im very confused with types here
            // CHECK for what move the model is making here (as the may quit, or accept the offer)
            // then decide what to do. (slot is = ["myMoveType"])
            
            if let changeModelBid = chunk?.slotvals["myMove"]?.description {
                    modelCurrentOffer = modelPreviousOffer! + Int(changeModelBid)! // idk why this one is an optional though
                    model.addToTrace(string: "Retrieving \(chunk!)")
                //maybe retrieve modelMoveType, but that can be calculated
                //if let modelIsFinal = chunk?.slotvals["myIsFinal"]?.description {
                   // modelIsFinalOffer = Bool(modelIsFinal)!
            
                } else {
                    model.addToTrace(string: "Failed retrieval, insist on previous offer")
                }
                model.time += 1.0 + latency
            }
            
//SAVE THIS EXPERIENCE
        let changeModelBid = modelCurrentOffer! - modelPreviousOffer! // this cant be enforced here, maybe use another function
        //determine models move type
        if changeModelBid > 0 {modelMoveType = "raise"}
        else if changeModelBid == 0 {modelMoveType = "insist"}
        else {modelMoveType = "concede"}
 
        
        let newExperience = model.generateNewChunk(string: "instance")
        
        // "myStrategy","myMNS","myBidMNSDifference","opponentMoveType","opponentMove","opponentIsFinal",
        // "myMoveType","myMove","myIsFinal"
            
        // MARK: I think it might make sense to put this newExperience at the start of this function, and then do it by infering the POV of the player. So the "opponent" slots refer to what the model did, and the "my" slots are for what the player just did. This way, new negetiation response types are learned by how the player responds to the model
        // (would require guessing what the opponent's MNS is, but the data sheet might have a suggestion on how to do it, or we just keep a running average of the model's MNSs and assume the player has the same) - Dan
        
        //save new experience
        newExperience.setSlot(slot: "opponentMove", value: changePlayerBid.description)
        newExperience.setSlot(slot: "myMove", value: changeModelBid.description)
        newExperience.setSlot(slot: "opponentMoveType", value: playerMoveType!) // this cant be enforced here, maybe use another function
        newExperience.setSlot(slot: "myMoveType", value: modelMoveType!) // this cant be enforced here, maybe use another function
        //newExperience.setSlot(slot: "opponentIsFinal", value: playerIsFinalOffer)
        //newExperience.setSlot(slot: "myIsFinal", value: modelIsFinalOffer)
        newExperience.setSlot(slot: "myStrategy", value: playerStrategy!)
        
        //newExperience.setSlot(slot: "myBidMNSDifference", value: "something")  //  maybe?
        //newExperience.setSlot(slot: "myMNS", value: modelMNS.description)  //  ?
        model.dm.addToDM(newExperience)
        
        //add more time?
        update()
        waitingForAction = true

    }
    
    func ModelDeclMNSValueGet() -> Int{
        return self.modelDeclaredMNS!
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
    mutating func updateScores(playerOffered: Bool) {
        var playerCurrentScoreGain: Int = 0
        var modelCurrentScoreGain: Int = 0
        //Added this to see who made last offer
        if playerOffered {
            modelCurrentScoreGain = (9 - playerCurrentOffer)-modelMNS
            playerCurrentScoreGain = playerCurrentOffer - playerMNS
        } else { // model made accepted offer
            playerCurrentScoreGain = (9 - modelCurrentOffer!)-playerMNS
            modelCurrentScoreGain = modelCurrentOffer!-modelMNS

        }
        playerScore += playerCurrentScoreGain
        modelScore += modelCurrentScoreGain
    }
    
    // the round has ended, clean up and start a new one
    mutating func newRound(playerOffered: Bool) {
        if verbose {print("M: preparing new negotiation round")}
        // if neither player has quit, an agreement was made and their scores should be updated
        if !(playerHasQuit || modelHasQuit) {
            updateScores(playerOffered: playerOffered)
        }
        // reset offer history
        playerPreviousOffer = nil; playerCurrentOffer = 0
        modelPreviousOffer = nil; modelCurrentOffer  = nil
        playerIsFinalOffer = false; modelIsFinalOffer = false
        playerHasQuit = false; modelHasQuit = false
        
        // new MNS values for the next round
        pickMNS()
        
        // start next round, player makes move
        model.waitingForAction = true
        
        update()
        
    }
    
    

    /// The trace from the model
    var traceText: String = ""
    /// The model code
    var modelText: String = ""
    /// Part of the contents of DM that can needs to be displayed in the interface
    var dmContent: [PublicChunk] = []
    
  
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

    
    
    mutating func makeNewModel() {
        model = initNewModel()
    }
    
    
}
    
        
        
    // ###########################################
    // MARK: leftover code scraps below this !
    // just to look at, really
    // ###########################################

    
    
    /*:
     
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

*/
