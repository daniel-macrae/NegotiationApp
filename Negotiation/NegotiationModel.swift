// This is the MODEL file

import Foundation


struct NGModel {
    // for printing of errors and function calls
    var verbose = true
    
    // MARK: Game state management
    var currentRoundNumber: Int = 1
    var maxRoundNumber: Int = 5
    
    var MNS_combinations: Array<(Int, Int)> = [(2,2),(1,3),(3,1),(2,2),(3,3),(2,3),(3,2),(3,4),(4,3),(2,4),(4,4)]
    /// Model's total score
    var modelScore = 0
    /// Player's total score
    var playerScore = 0
    /// Player's MNS, score and reward
    var playerMNS: Int = 0  // these now get randomly chosen before each round
    var modelMNS: Int = 0
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
    var assumedPlayerMNS = 0
    //Need some function to get these from JSONManager
    var playerNames: [String] = ["Daniel", "Sara", "Luka"]
    var currentPlayerName: String?
    
    /// Boolean that states whether the model is waiting for an action.
    var waitingForAction = true
    
    func printV(_ text: String) {if verbose {print(text)}}
    
    
    internal var model: Model = initNewModel() // just load an empty model
    
    
    mutating func loadPlayerModel(fileName: String) {
        let new: Bool // boolean to see if a new model was created
        
        (model, new) = loadModel(name: fileName)  // loading the model
        
        moveToTop(player: fileName) // put this player at the top of the player selection menu
        printV("M: Model loaded. Number of chunks = " + String(model.dm.chunks.count))
        
        if new {modelStrategy = "Neutral"}  // if a new model was made, make it's strategy neutral
        else {decideModelStrategy()}        // if a previous model was loaded, use the memory it has to decide the strategy
        
        model.softReset()
        update()
        
    }
 
    
    mutating func moveToTop(player: String) {
        let index = playerNames.firstIndex(of: player)
        playerNames.move(fromOffsets: IndexSet(integer: index!), toOffset: 0)
    }
    
    func savePlayerModel() {
        //print("M: Number of Chunks in model to save: " + String(model.dm.chunks.count))
        saveModel(model: model, filename: currentPlayerName!) // save the model
        printV("M: model saved!")
    }
    
    
    
    
    // MARK: CHUNK SLOT NAMES ARE NOW:
    // "myStrategy","myMNS","myBidMNSDifference","opponentMoveType","opponentMove","opponentIsFinal",
    // "myMoveType","myMove","myIsFinal"
    
    
    mutating func declareModelMNS(){
        decideModelStrategy()
        if modelStrategy == "Aggressive"{
            modelDeclaredMNS = modelMNS + 1
        }else{
            modelDeclaredMNS = modelMNS
        }
    }

    
    mutating func detectPlayerStrategy(bidMNSDifference: Int, changePlayerBid: Int){
    
        let query = Chunk(s: "query", m: model)
        query.setSlot(slot: "isa", value: "negotiation instance")  // added this isa slot, might improve chances of matching a chunk
        query.setSlot(slot: "myMNS", value: assumedPlayerMNS.description)
        query.setSlot(slot: "myBidMNSDifference", value: bidMNSDifference.description)
        query.setSlot(slot: "myMoveType", value: playerMoveType)
        query.setSlot(slot: "myIsFinal", value: playerIsFinalOffer.description)
        print("M: player strategy query chunk")
        print(query)
        
        
        if playerMoveType == "Bid" {
            query.setSlot(slot: "myMove", value: changePlayerBid.description)}
        else if playerMoveType == "Decision" || playerMoveType == "Quit" {// if quit the only point to find the strategy is to reinforce the chunk
            query.setSlot(slot: "myMove", value: playerDecision!)}
        // If opening you cant have any more chunks
        
        
        let (latency, chunk) = model.dm.partialRetrieve(chunk: query, mismatchFunction: chunkMismatchFunction)
        model.time +=  latency
        
        if let playerCurrentStrategy = chunk?.slotvals["myStrategy"]?.description {
            playerStrategy = playerCurrentStrategy
            model.addToTrace(string: "Retrieved detectPlayerStrategy() chunk: \(chunk!)")
            
            // reinforce strategy chunk, by adding to DM (not retrieval)
            printV("M: Reinforcing: " + playerStrategy)
            let strategyChunk = Chunk(s: "stategyChunk", m: model )  // check s
            strategyChunk.setSlot(slot: "isa", value: "strategy")
            strategyChunk.setSlot(slot: "strategy", value: playerStrategy)
            model.dm.addToDM(strategyChunk)
            
        } else {
            model.addToTrace(string: "detectPlayerStrategy() strategy chunk retrieval failed!")  // this still happens a few times
        }
        
        
        model.time += 0.1

    }
    
    // the model decide's its strategy by trying to retrieve one of the two strategy chunks
    mutating func decideModelStrategy() {
        // retrieve strategy chunk with highest activation:
        let strategyQuery = Chunk(s: "strategyChunk", m: model )
        strategyQuery.setSlot(slot: "isa", value: "strategy")
        let (latencyStrategy, strategyChunk) = model.dm.partialRetrieve(chunk: strategyQuery, mismatchFunction: chunkMismatchFunction)
        if let modelCurrentStrategy = strategyChunk?.slotvals["strategy"]?.description {
            modelStrategy = modelCurrentStrategy
            model.addToTrace(string: " Retrieved decideModelStrategy() chunk \(strategyChunk!)")
            model.time += 0.1 + latencyStrategy
            
        } else {
            model.addToTrace(string: "Failed decideModelStrategy() retrieval, continue with previous strategy")
            //modelStrategy = "Neutral"   // maybe do this?
        }
    }
    
    
    mutating func saveNewExperience(bidMNSDifference: Int, changePlayerBid: Int) {
     
        let changeModelBid: Int
        
        if let ModelsLastOffer = modelPreviousOffer {
            changeModelBid = modelCurrentOffer! - ModelsLastOffer
            print("change = " + String(changeModelBid))
        }
        else {
            changeModelBid = 0 // this is probably not good practice. ERROR if the model starts!!
        }
        
        let newExperience = model.generateNewChunk(string: "instance") // from the player's POV
         
        // "myStrategy","myMNS","myBidMNSDifference","opponentMoveType","opponentMove","opponentIsFinal",
        // "myMoveType","myMove","myIsFinal"
        newExperience.setSlot(slot: "isa", value: "negotiation instance")
        newExperience.setSlot(slot: "opponentMoveType", value: modelMoveType)
        newExperience.setSlot(slot: "myMoveType", value: playerMoveType)
        newExperience.setSlot(slot: "myStrategy", value: playerStrategy)
        newExperience.setSlot(slot: "myMNS", value: assumedPlayerMNS.description)
        newExperience.setSlot(slot: "myBidMNSDifference", value: bidMNSDifference.description)
        newExperience.setSlot(slot: "myIsFinal", value: playerIsFinalOffer.description)
        newExperience.setSlot(slot: "opponentIsFinal", value: modelIsFinalOffer.description)
        
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
        //else if modelMoveType == "Opening"{
        //    if modelCurrentOffer != nil {
        //      newExperience.setSlot(slot: "opponentMove", value: modelCurrentOffer!.description)}
        //    else {
        //        newExperience.setSlot(slot: "opponentMove", value: "N/A")
        //    }
        //}

        if verbose {print("M: New experience chunk is:") ; print(newExperience)}
        model.dm.addToDM(newExperience)

        model.time += 0.1
        update()
        waitingForAction = true
    }
 
    
    
    mutating func modelResponse() {
        if verbose {print("MODEL IS RESPONDING TO PLAYER. Number of chunks: " + String(model.dm.chunks.count))}
        
        var changePlayerBid = 0
        
        // MARK: this next line is a problem; at the start of each game the runningMNSAverage is 0 (I think), maybe replace by using blended retrieval and just storing chunks that contain only the MNS?
        let bidMNSDifference = playerCurrentOffer - assumedPlayerMNS  // find the player's "myBidMNSDifference" slot value
        
        // detect player strategy
        detectPlayerStrategy(bidMNSDifference: bidMNSDifference, changePlayerBid: changePlayerBid)
        
        
        // do the saving of a new experience, learning what the opponent just did
        if playerPreviousOffer != nil {
            changePlayerBid = playerCurrentOffer - playerPreviousOffer!
            saveNewExperience(bidMNSDifference: bidMNSDifference, changePlayerBid: changePlayerBid)
        }
        else {
            changePlayerBid = 0 // it's never used (this is probably not good practice)
            saveNewExperience(bidMNSDifference: bidMNSDifference, changePlayerBid: playerCurrentOffer)
        }
        
        // admin
        modelPreviousOffer = modelCurrentOffer
        printV("M: model is responding/making a new offer")
    
        // first offer
        if modelCurrentOffer == nil { // make an opening bid
            // now the model decides what strategy it should use to respond
            decideModelStrategy()
            // we haven't made an opening offer, so specifically do that (the values in an opening bid chunk work differently to a normal bid chunk)
            modelMakeOpeningOffer()
        }

        else if !(playerMoveType == "Decision" || playerMoveType == "Quit") { // if the player has not ended the round, normal bidding
            // model decides what strategy its using
            decideModelStrategy()
            
            // it's not retrieving perfectly, but it does
            let query = Chunk(s: "query", m: model)
            query.setSlot(slot: "isa", value: "negotiation instance")
            query.setSlot(slot: "myStrategy", value: modelStrategy)
            query.setSlot(slot: "opponentMoveType", value: playerMoveType)
            query.setSlot(slot: "opponentIsFinal", value: playerIsFinalOffer.description)
            query.setSlot(slot: "myBidMNSDifference", value: bidMNSDifference.description)
            if playerIsFinalOffer == true{ query.setSlot(slot: "myMoveType", value: "Decision") }

            if playerPreviousOffer != nil { // if model plays first, playerPreviousffer is still nil after one play from the model
                //I leave this condition for now but we should enforce this, otherwise the saving of the chunks has to change too
                query.setSlot(slot: "opponentMove", value: changePlayerBid.description)// this also works
            }
            else {
                query.setSlot(slot: "opponentMove", value: "N/A")
            }
            
            print("M: Query chunk \(query)")
            
            let (latency, chunk) = model.dm.partialRetrieve(chunk: query, mismatchFunction: chunkMismatchFunction)
            
            // MARK: this is  not working, especially the decisions
            
            if let modelNewMoveType = chunk?.slotvals["myMoveType"]?.description {
                // get myMoveType and myIsFinal values
                modelMoveType = modelNewMoveType
                if let modelIsFinal = chunk?.slotvals["myIsFinal"]?.description {
                    modelIsFinalOffer = Bool(modelIsFinal)! }
                
                if modelMoveType == "Bid" {
                    if let modelChangeBid = chunk?.slotvals["myMove"]?.description {
                        modelCurrentOffer = modelPreviousOffer! + Int(Float(modelChangeBid)!)// idk why this one is an optional thoug
                    }
                
                // any non-bids (accept, reject, quit) fall into this else condition
                } else {
                    if let modelNewDecision = chunk?.slotvals["myMove"]?.description{
                        modelDecision = modelNewDecision
                        modelMadeADecision()
                    }
                }
                model.addToTrace(string: "Successfully Retrieved Bid \(chunk!)")
            }
            else {
                // eforcing cause it never retrieves the decision chunks
                if playerIsFinalOffer == true {
                    modelMoveType = "Decision"
                    modelDecision = "Reject"
                    modelMadeADecision()
                    model.addToTrace(string: "Failed bid retrieval, reject offer")
                }
                else {
                    model.addToTrace(string: "Failed bid retrieval, insist on previous offer") }
                
            }
            
            model.time += 0.1 + latency
            
        }
    }
    
    mutating func modelMakeOpeningOffer() {
        let query = Chunk(s: "query", m: model)
    
        query.setSlot(slot: "isa", value: "negotiation instance")
        query.setSlot(slot: "myMNS", value: modelMNS.description)
        query.setSlot(slot: "myMoveType", value: "Opening")
        query.setSlot(slot: "myStrategy", value: modelStrategy)
        //query.setSlot(slot: "opponentMoveType", value: "Opening")
        //query.setSlot(slot: "opponentMove", value: playerCurrentOffer.description)
        //query.setSlot(slot: "opponentIsFinal", value: playerIsFinalOffer.description)  // possible (but unlikely) that the player makes their first bid 'final'
    
        print("M: Model opening offer query chunk:")
        print(query)
        
        let (latency, chunk) = model.dm.partialRetrieve(chunk: query, mismatchFunction: chunkMismatchFunction)
        
        
        if let modelOffer = chunk?.slotvals["myMove"]?.description {
            model.addToTrace(string: "Retrieved Opening Offer: \(chunk!)")
            // MARK: We might have to check first if the retrieved chunk is actually an opening bid chunk (sometimes it got a decision chunk here, which causes the next line to crash because the myMove is a string)
            modelCurrentOffer = Int(Float(modelOffer)!) // This is a mess we need to fix it
            modelMoveType = "Bid" // say bid instead of 'opening', makes saving chunks later on better
            
        } else {
            modelCurrentOffer = Int.random(in: modelDeclaredMNS!..<10)  /// model makes a completely random offer above their declared MNS
            model.addToTrace(string: "Failed retrieval of opening offer, random offer")
            modelMoveType = "Bid"
        }
        model.time += 0.1 + latency
        
        
    }
    
    mutating func modelMadeADecision(){
        if modelDecision == "Accept" {
            modelHasQuit = false}
        else if modelDecision == "Reject" {
            modelHasQuit = true}
        else if modelMoveType == "Quit" {
            modelHasQuit = true    }

        //newRound(playerOffered: true)  a bit easier to keep this one in the viewModel
    }
    
    mutating func runningAverageMNS(modelMNS: Int) -> Int{
        if averagedMNS.count < 5 {
            averagedMNS.append(modelMNS)
        } else{
            averagedMNS.remove(at: 0)
            averagedMNS.append(modelMNS)
        }
        //print(averagedMNS)
        
        return Int(averagedMNS.reduce(0,+)/averagedMNS.count)
    }

    
    // MARK: GAME MANAGEMENT FUNCTIONS
    
            
    // select new MNSs for both players (call this once a round finishes)
    mutating func pickMNS() {
        if verbose {print("M: picking new MNS values")}
        let randomMNS = MNS_combinations.randomElement()!
        playerMNS = randomMNS.0
        modelMNS = randomMNS.1
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
        if verbose {print("\n \n \n \n    ~  NEW ROUND  ~   \n \n \n \n ")}

        // if neither player has quit, an agreement was made and their scores should be updated
        if !(playerHasQuit || modelHasQuit) {
            updateScores(playerOffered: playerOffered)
        }
        
        resetGameVariables(newGame: false)
        currentRoundNumber += 1
        
        assumedPlayerMNS = runningAverageMNS(modelMNS: modelMNS) // the location fo this function is good
        
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
            if verbose {print("\n \n \n \n    !!  NEW GAME  !!  \n \n \n \n ")}
            playerScore = 0; modelScore = 0
            currentRoundNumber = 1
        }
        savePlayerModel()
        
        pickMNS()  // new MNS values for the next round
        assumedPlayerMNS = runningAverageMNS(modelMNS: modelMNS)
        model.waitingForAction = true
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

