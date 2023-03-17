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
    var playerMNS = 3 // the first round is always the same:(
    var modelMNS = 4
    var averagedMNS: [Int] = []
    
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
    var playerStrategy = "Cooperative"
    //maybe make the models initial strategy random? so we get different possibilities
    var modelStrategy = "Neutral"
    //opening, bid, decision, quit
    var playerMoveType = "Opening"
    var modelMoveType = "Opening"
    
    var playerDecision: String?
    var modelDecision: String?
    
    //MNS runnig average
    var runningMNSAverage = 4
    //Need some function to get these from JSONManager
    var loadFilesNames: [String] = ["loadfile1", "loadfile2", "thisNeedsImplementation"]
    
    /// Boolean that states whether the model is waiting for an action.
    var waitingForAction = true
    
    
    internal var model = Model()
    
    // functions to save and load the model (calls functions from JSONManger.swift file)
    mutating func makeNewModel() {
        model = initNewModel()
    }
    
    mutating func testLoad(fileName: String) {
        print("M: Before Load: " + String(model.dm.chunks.count))
        model = loadModel(name: fileName)  // loading the model
        print("M: Model loaded. Number of chunks: " + String(model.dm.chunks.count))
        //print(model.time)
        //model.time += 5.0
        //print(model.time)
    }
    
    func testSave() {
        print("M: Number of Chunks in model to save: " + String(model.dm.chunks.count))
        saveModel(model: model, filename: "test") // save the model
        print("M: model saved!")
    }
    
    
    /// Here we do not actually load in anything: we just reset the model
    /// - Parameter filename: filename to be loaded (extension .actr is added by the function)
    mutating func resetModel() {
        model.reset()
        model.waitingForAction = true
    }
    
    
    //
    // MARK: CHUNK SLOT NAMES ARE NOW:
    // "myStrategy","myMNS","myBidMNSDifference","opponentMoveType","opponentMove","opponentIsFinal",
    // "myMoveType","myMove","myIsFinal"
    // - Dan
    /// (where 'opponentMove' and 'myMove' are the player's and model's change in bid value respectively)
    
    mutating func declareModelMNS(){ // MARK: still to be implemented
        modelDeclaredMNS = Int(arc4random_uniform(9)) + 1
 //think how we want to do this
        // model should probably retrieve a chunk with the right mns to max change of succes
    }

    
    mutating func detectPlayerStrategy(bidMNSDifference: Int, changePlayerBid: Int){
    
        let query = Chunk(s: "query", m: model)
        query.setSlot(slot: "myMNS", value: runningMNSAverage.description)
        query.setSlot(slot: "myBidMNSDifference", value: bidMNSDifference.description)
        query.setSlot(slot: "myMoveType", value: playerMoveType)
        
        
        if playerMoveType == "Bid" {
            query.setSlot(slot: "myMove", value: changePlayerBid.description)}
        else if playerMoveType == "Decision" || playerMoveType == "Quit" {// if quit the only point to find the strategy is to reinforce the chunk
            query.setSlot(slot: "myMove", value: playerDecision!)}
        // If opening you cant have any more chunks
        
        let (latency, chunk) = model.dm.retrieve(chunk: query)
        model.time +=  latency
        
        if let playerCurrentStrategy = chunk?.slotvals["myStrategy"]?.description {
            playerStrategy = playerCurrentStrategy
            model.addToTrace(string: "Retrieving strategy \(chunk!)")
            
        } else {
            model.addToTrace(string: "detectPlayerStrategy() strategy chunk retrieval failed!")
        }
        //reinforce strategy chunk
        let strategyChunk = Chunk(s: "stategyChunk", m: model )  // check s
        strategyChunk.setSlot(slot: "isa", value: "strategy")
        strategyChunk.setSlot(slot: "strategy", value: playerStrategy)
        let (latencyStrategy, _) = model.dm.retrieve(chunk: strategyChunk)
        model.time += 1 + latencyStrategy

    }
    
    
    mutating func saveNewExperience(bidMNSDifference: Int, changePlayerBid: Int) {
     
        let changeModelBid: Int
        
        if let ModelsLastOffer = modelPreviousOffer {
            changeModelBid = modelCurrentOffer! - ModelsLastOffer
        }
        else {
            changeModelBid = 0 // this is probably not good practice. ERROR if the model starts!!
        }
        
        let newExperience = model.generateNewChunk(string: "instance") // from the player's POV
         
        // "myStrategy","myMNS","myBidMNSDifference","opponentMoveType","opponentMove","opponentIsFinal",
        // "myMoveType","myMove","myIsFinal"
        newExperience.setSlot(slot: "opponentMoveType", value: modelMoveType)
        newExperience.setSlot(slot: "myMoveType", value: playerMoveType)
        if playerMoveType == "Bid" {
         newExperience.setSlot(slot: "myMove", value: changePlayerBid.description)}
        else if playerMoveType == "Decision" || playerMoveType == "Quit" {// if quit the only point to find the strategy is to reinforce the chunk
         newExperience.setSlot(slot: "myMove", value: playerDecision!)}
        else if playerMoveType == "Opening"{
         newExperience.setSlot(slot: "myMove", value: playerCurrentOffer.description)}

        if modelMoveType == "Bid" {
         newExperience.setSlot(slot: "opponentMove", value: changeModelBid.description)}
        else if modelMoveType == "Decision" || playerMoveType == "Quit" {// if quit the only point to find the strategy is to reinforce the chunk
         newExperience.setSlot(slot: "opponentMove", value: modelDecision!)}
        else if modelMoveType == "Opening"{
         newExperience.setSlot(slot: "opponentMove", value: modelCurrentOffer!.description)}

        newExperience.setSlot(slot: "myStrategy", value: playerStrategy)
        newExperience.setSlot(slot: "myMNS", value: runningMNSAverage.description)
        newExperience.setSlot(slot: "myBidMNSDifference", value: bidMNSDifference.description)  //  ?

        newExperience.setSlot(slot: "myIsFinal", value: playerIsFinalOffer.description)
        newExperience.setSlot(slot: "opponentIsFinal", value: modelIsFinalOffer.description)

        model.dm.addToDM(newExperience)

        //add more time?
        model.time += 1.0
        update()
        waitingForAction = true

 }
 
    // MARK: The running average is not implemented yet
    mutating func modelResponse() {
        var changePlayerBid = 0 // it needs to be defined even if its useless ??optinonal?/
        /*var changePlayerBid: Int
        
        if let playersLastOffer = playerPreviousOffer {
            changePlayerBid = playerCurrentOffer - playersLastOffer
        }
        else {
            changePlayerBid = 0 // it's never used (this is probably not good practice)
        }*/
        
        //assume players MNS as the running average
        
        let bidMNSDifference = runningMNSAverage - playerCurrentOffer
        modelPreviousOffer = modelCurrentOffer
        
        detectPlayerStrategy(bidMNSDifference: bidMNSDifference, changePlayerBid: changePlayerBid)
        
        
        if verbose {print("M: model is responding/making a new offer")}
        // first offer
        if modelCurrentOffer == nil {
            print("modelCurrentOffer is nil")
                let query = Chunk(s: "query", m: model)
                
                query.setSlot(slot: "myMNS", value: modelMNS.description)
                // if the model plays first, both moveTypes are openings, if the player plays first, their moveType here is bid
                // players move should be used if they mark final offer, but i dont know how yet
                query.setSlot(slot: "myMoveType", value: modelMoveType)
                query.setSlot(slot: "myStrategy", value: modelStrategy)
                
                //if playerIsFinalOffer == true{ // very aggresive, but possible
                //query.setSlot(slot: "opponentMoveType", value: playerMoveType)
                // query.setSlot(slot: "opponentMove", value: pla)
                //}
                
                let (latency, chunk) = model.dm.retrieve(chunk: query)
                model.time +=  latency
                
                if let modelOffer = chunk?.slotvals["myMove"]?.description {
                    modelCurrentOffer = (Int(Float(modelOffer)!))// This is a mess we need to fix it
                    print("M: offer should be = " + String(modelCurrentOffer!))
                    
                    if let modelNewMoveType = chunk?.slotvals["myMoveType"]?.description { // It only lets me unwrap like this, check options
                        modelMoveType = modelNewMoveType}
                    
                    
                    model.addToTrace(string: "First decision: retrieving opening \(chunk!)")
                    model.time += 1.0
                    
                } else {
                    
                    modelCurrentOffer = Int.random(in: modelMNS..<10)  /// model makes a completely random offer above their MNS
                    model.addToTrace(string: "Failed retrieval, random offer")
                    model.time += 1.0
                }
            modelMoveType = "Bid" // enforce that only makes an opening move once
        }

        else if playerMoveType == "Decision" {
            changePlayerBid = playerCurrentOffer - playerPreviousOffer!
            if playerDecision == "Accept" {
                saveNewExperience(bidMNSDifference: bidMNSDifference, changePlayerBid: changePlayerBid)
                //newRound(playerOffered: false) ALREADY DONE IN VIEWMODEL
            }
            else {
                changePlayerBid = playerCurrentOffer - playerPreviousOffer!
                saveNewExperience(bidMNSDifference: bidMNSDifference, changePlayerBid: changePlayerBid)
                playerHasQuit = true
                //newRound(playerOffered: false)
            }
            
        }
        else if playerMoveType == "Quit" {
            changePlayerBid = playerCurrentOffer - playerPreviousOffer!
            saveNewExperience(bidMNSDifference: bidMNSDifference, changePlayerBid: changePlayerBid)
            playerHasQuit = true
            //newRound(playerOffered: false)
            
        }

        else  { // normal bidding
            // retrieve strategy chunk with highest activation:
            let strategyQuery = Chunk(s: "strategyChunk", m: model )
            strategyQuery.setSlot(slot: "isa", value: "strategy")
            let (latencyStrategy, strategyChunk) = model.dm.retrieve(chunk: strategyQuery)
            if let modelCurrentStrategy = strategyChunk?.slotvals["strategy"]?.description {
                modelStrategy = modelCurrentStrategy
                model.addToTrace(string: " Retrieving model's strategy \(strategyChunk!)")
                model.time += 1.0 + latencyStrategy
                
            } else {
                model.addToTrace(string: "Failed retrieval, continue with previous strategy")
            }
            // it's not retrieving perfectly, but it does
            let query = Chunk(s: "query", m: model)
            query.setSlot(slot: "myStrategy", value: modelStrategy)
            query.setSlot(slot: "opponentMoveType", value: playerMoveType)
            query.setSlot(slot: "opponentIsFinal", value: playerIsFinalOffer.description)
            if playerIsFinalOffer == true{
                query.setSlot(slot: "myMoveType", value: "Decision")
            }
            changePlayerBid = playerCurrentOffer - playerPreviousOffer! //This works
            if playerPreviousOffer != nil { //if model plays first, playerPreviousffer is still nil after one play from the model
                //I leave this condition for now but we should enforce this, otherwise the saving of the chunks has to change too
                query.setSlot(slot: "opponentMove", value: changePlayerBid.description)// this also works
            }
            print(" Query chunk \(query)")
            let (latency, chunk) = model.dm.retrieve(chunk: query)
            
            // MARK: this is  not working, especially the decisions
            
            if let modelNewMoveType = chunk?.slotvals["myMoveType"]?.description {
                modelMoveType = modelNewMoveType
                print(modelMoveType)
                if modelNewMoveType == "Bid" {
                    if let modelChangeBid = chunk?.slotvals["myMove"]?.description {
                        print(modelChangeBid)
                        modelCurrentOffer = modelPreviousOffer! + Int(Float(modelChangeBid)!)// idk why this one is an optional thoug
                    }
                    
                } else {
                    if let modelNewDecision = chunk?.slotvals["myMove"]?.description{
                        modelDecision = modelNewDecision }
                    if let modelIsFinal = chunk?.slotvals["myIsFinal"]?.description {
                        modelIsFinalOffer = Bool(modelIsFinal)! }
                    model.addToTrace(string: "Retrieving \(chunk!)")
                    print("the model is actually making a decision")
                }
            }
            else {
                // eforcing cause it never retrieves the decision chunks
                if playerIsFinalOffer == true {
                    modelMoveType = "Decision"
                    modelDecision = "Reject"
                    model.addToTrace(string: "Failed retrieval, reject offer")
                }
                else{
                    model.addToTrace(string: "Failed retrieval, insist on previous offer") }
                
            }
            
            model.time += 1.0 + latency
            saveNewExperience(bidMNSDifference: bidMNSDifference, changePlayerBid: changePlayerBid)
            
        }
    }
    
    mutating func modelMadeADecision(){
        if modelDecision == "Accept" {
            newRound(playerOffered: true)}
        if modelDecision == "Reject" {
            print("its doing this")
            modelHasQuit = true
            newRound(playerOffered: true)}
        if modelMoveType == "Quit" {
            modelHasQuit = true
            newRound(playerOffered: true)}
    }
    
    mutating func runningAverageMNS(modelMNS: Int) -> Int{
        if averagedMNS.count < 5 {
            averagedMNS.append(modelMNS)
        } else{
            averagedMNS.remove(at: 0)
            averagedMNS.append(modelMNS)
        }
        print(averagedMNS)
        
        return Int(averagedMNS.reduce(0,+)/averagedMNS.count)
    }
    
    func ModelDeclMNSValueGet() -> Int{
        return self.modelDeclaredMNS!
    }
            
    // select new MNSs for both players (call this once a round finishes)
    mutating func pickMNS() { //-> (Int,Int)
        if verbose {print("M: picking new MNS values")}
        if let randomMNS = MNS_combinations.randomElement() {
            playerMNS = randomMNS.0
            modelMNS = randomMNS.1
            //return randomMNS
        }
        else { /// this should never happen, but swift won't pick a randomElement without it :/
            print("M: MNS error!")
            //return (3,3)
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
        resetGameVariables(newGame: false)
        // new MNS values for the next round
        pickMNS()
        runningMNSAverage = runningAverageMNS(modelMNS: modelMNS)
        // start next round, player makes move
        model.waitingForAction = true
        
        update()
        
    }
    
    mutating func resetGameVariables(newGame: Bool) {
        // reset offer history
        playerPreviousOffer = nil; playerCurrentOffer = 0
        modelPreviousOffer = nil; modelCurrentOffer  = nil
        playerIsFinalOffer = false; modelIsFinalOffer = false
        playerHasQuit = false; modelHasQuit = false
        playerDeclaredMNS = nil; modelDeclaredMNS = nil
        
        if newGame {
            playerScore = 0; modelScore = 0
        }
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

    
    
    
    
}
    
     
