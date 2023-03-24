// This is the MODEL file

import Foundation


struct NGModel {
    // for printing of errors and function calls
    var verbose = true
    
    // MARK: Game state management
    var currentRoundNumber: Int = 1
    var maxRoundNumber: Int = 2
    var gameOver: Bool = false
    
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
    var playerCurrentOffer: Int? // = 0 // work on how to display this if it has no value?
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
    
    var modelInsists = false
    var playerInsists = false
    
    //MNS runnig average
    var assumedPlayerMNS = 0
    //Need some function to get these from JSONManager
    var playerNames: [String] = ["Daniel", "Sara", "Luka"]
    var currentPlayerName: String?
    
    /// Boolean that states whether the model is waiting for an action.
    var waitingForAction = true
    
    func printV(_ text: String) {if verbose {print(text)}}
    
    
    internal var model: Model // = initNewModel() // just load an empty model
    
    init() {
        if !playerNames.isEmpty {
            (model, _) = loadModel(name: playerNames.first!)
        } else {
            model = initNewModel()
        }
    }
    
    mutating func loadPlayerModel(playerName: String) {
        let new: Bool // boolean to see if a new model was created
        
        (model, new) = loadModel(name: playerName)  // loading the model
        printV("M: Model loaded. Number of chunks = " + String(model.dm.chunks.count))
        
        // move this player to the top of the list of player names, makes it quicker to select the same user next time
        let index = playerNames.firstIndex(of: playerName)
        playerNames.move(fromOffsets: IndexSet(integer: index!), toOffset: 0)
        
        // decide the model's strategy, Neutral if the model is newly initalised
        if new {modelStrategy = "Neutral"}
        else {decideModelStrategy()}
        
        model.softReset()
        update()
    }
    
    
    
    func savePlayerModel() {
        saveModel(model: model, filename: currentPlayerName!) // save the model
        printV("M: model saved!")
    }
    
    
    
    // MARK: CHUNK SLOT NAMES ARE NOW:
    // "myStrategy","myMNS","myBidMNSDifference","opponentMoveType","opponentMove","opponentIsFinal",
    // "myMoveType","myMove","myIsFinal"
    
    
    // function for the model to declare its MNS
    mutating func declareModelMNS(){
        decideModelStrategy()
        if modelStrategy == "Aggressive"{
            modelDeclaredMNS = modelMNS + 1
        }else{
            modelDeclaredMNS = modelMNS
        }
    }

    // function that allows the model to infer the player's strategy
    mutating func detectPlayerStrategy(bidMNSDifference: Int, changePlayerBid: Int){
    
        let query = Chunk(s: "query", m: model)
        query.setSlot(slot: "isa", value: "negotiation instance")
        //query.setSlot(slot: "myMNS", value: assumedPlayerMNS.description)
        query.setSlot(slot: "myBidMNSDifference", value: bidMNSDifference.description)
        query.setSlot(slot: "myMoveType", value: playerMoveType)
        query.setSlot(slot: "myIsFinal", value: playerIsFinalOffer.description)
        
        
        if playerMoveType == "Bid" {
            query.setSlot(slot: "myMove", value: changePlayerBid.description)
            query.setSlot(slot: "myMNS", value: "N/A")
        } else if playerMoveType == "Opening" {
            query.setSlot(slot: "myMove", value: playerCurrentOffer!.description)
            query.setSlot(slot: "myBidMNSDifference", value: "N/A")
            query.setSlot(slot: "myMNS", value: assumedPlayerMNS.description)
        } else if playerMoveType == "Decision" || playerMoveType == "Quit" {
            query.setSlot(slot: "myMove", value: playerDecision!)
            query.setSlot(slot: "myMNS", value: "N/A")
        }
        
        print("M: player strategy query chunk")
        print(query)
        
        let (latency, chunk) = model.dm.partialRetrieve(chunk: query, mismatchFunction: chunkMismatchFunction)
        model.time +=  latency
        
        if let playerCurrentStrategy = chunk?.slotvals["myStrategy"]?.description {
            playerStrategy = playerCurrentStrategy
            model.addToTrace(string: "Retrieved detectPlayerStrategy() chunk: \(chunk!)")
            
            if playerCurrentStrategy != "Neutral" {
                // reinforce strategy chunk, by adding to DM (not retrieval)
                printV("M: Reinforcing: " + playerStrategy)
                let strategyChunk = Chunk(s: "stategyChunk", m: model )  // check s
                strategyChunk.setSlot(slot: "isa", value: "strategy")
                strategyChunk.setSlot(slot: "strategy", value: playerStrategy)
                model.dm.addToDM(strategyChunk)
            }
            
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
     
        var changeModelBid: Int
        
        if let ModelsLastOffer = modelPreviousOffer {
            changeModelBid = modelCurrentOffer! - ModelsLastOffer
        } else {
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
        else if playerMoveType == "Opening" {
            newExperience.setSlot(slot: "myMove", value: playerCurrentOffer!.description)
            newExperience.setSlot(slot: "myBidMNSDifference", value: "N/A")
        }

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
 
    
    mutating func isItTheSameOffer() {
        //This should be called too in case the player offers the same as the model just did instead of just accepting
        // For now it seems enough as it is
        if let playerOffer = playerCurrentOffer {
            if modelCurrentOffer! <= (9 - playerOffer) {
                modelMoveType = "Decision"
                modelDecision = "Accept"
                
                print(" \n \n MODEL IS DUMB \n \n")
                
                modelMadeADecision()
            }
        }
    }
    
    
    mutating func modelResponse() {
        if verbose {print("\n \nMODEL IS RESPONDING TO PLAYER. Number of chunks: " + String(model.dm.chunks.count))}
        var changePlayerBid = 0
        modelInsists = false // I only wrote the conditions for true, we can add for false or leave it like this
      
        let bidMNSDifference = playerCurrentOffer! - assumedPlayerMNS
        
        print(playerMoveType)
        // do the saving of a new experience, learning what the opponent just did
        if playerPreviousOffer != nil {
            changePlayerBid = playerCurrentOffer! - playerPreviousOffer!
            
            detectPlayerStrategy(bidMNSDifference: bidMNSDifference, changePlayerBid: changePlayerBid)  // detect player strategy
            saveNewExperience(bidMNSDifference: bidMNSDifference, changePlayerBid: changePlayerBid)    // then save a new memory
        }  else {
            changePlayerBid = 0 // it's never used (this is probably not good practice)
            
            detectPlayerStrategy(bidMNSDifference: bidMNSDifference, changePlayerBid: changePlayerBid)   // detect player strategy
            saveNewExperience(bidMNSDifference: bidMNSDifference, changePlayerBid: playerCurrentOffer!)  // then save a new memory
        }
        
        // some admin work
        modelPreviousOffer = modelCurrentOffer
    
        // if making the first offer ("Opening" offer)
        if modelCurrentOffer == nil {
            
            decideModelStrategy() // model decides what strategy it should use to respond
            modelMakeOpeningOffer() // make an opening offer
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
            query.setSlot(slot: "myBidMNSDifference", value: String(modelPreviousOffer! - modelMNS))
            if playerIsFinalOffer == true{ query.setSlot(slot: "myMoveType", value: "Decision") }

            if playerPreviousOffer != nil { // if model plays first, playerPreviousffer is still nil after one play from the model
                //I leave this condition for now but we should enforce this, otherwise the saving of the chunks has to change too
                query.setSlot(slot: "opponentMove", value: changePlayerBid.description)// this also works
            }
            else {
                query.setSlot(slot: "opponentMove", value: "N/A")
            }
            
            query.setSlot(slot: "myIsFinal", value: true.description)
            
            
            print("M: Query chunk \(query)")
            
            let (latency, chunk) = model.dm.partialRetrieve(chunk: query, mismatchFunction: chunkMismatchFunction)
            
            if let modelNewMoveType = chunk?.slotvals["myMoveType"]?.description {
                // get myMoveType and myIsFinal values
                modelMoveType = modelNewMoveType
                if let modelIsFinal = chunk?.slotvals["myIsFinal"]?.description {
                    modelIsFinalOffer = Bool(modelIsFinal)! }
                
                if modelMoveType == "Bid" {
                    if let modelChangeBid = chunk?.slotvals["myMove"]?.description {
                        modelCurrentOffer = modelPreviousOffer! + Int(Float(modelChangeBid)!)
                        if modelCurrentOffer == modelPreviousOffer { modelInsists = true} // bid hasn't changed
                        
                        //if modelCurrentOffer! < (9-playerCurrentOffer!) {
                        //    modelDecision = "Accept"
                        //    modelMoveType = "Decision"
                        //    modelMadeADecision()
                        //    print(" \n \n OVERRIDING BID BECAUSE ITS WORSE \n \n")
                        //}
                        
                    }
                // any non-bids (accept, reject, quit) fall into this else condition
                } else {
                    if let modelNewDecision = chunk?.slotvals["myMove"]?.description{
                        modelDecision = modelNewDecision
                        modelMadeADecision()
                    }
                }
                model.addToTrace(string: "modelResponse() Successfully Retrieved Bid \(chunk!)")
            }
            else {
                // eforcing cause it never retrieves the decision chunks
                if playerIsFinalOffer == true {
                    modelMoveType = "Decision"
                    modelDecision = "Reject"
                    modelMadeADecision()
                    model.addToTrace(string: "modelResponse() Failed bid retrieval, reject offer")
                }
                else {
                    model.addToTrace(string: "modelResponse() Failed bid retrieval, insist on previous offer")
                    modelIsFinalOffer = true
                    modelInsists = true
                }
                
            }
            
            isItTheSameOffer()  // checks to see if the model is going to make the same bid as the player just made, if yes, then accept the player's offer (as they both want the same split)
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
            modelHasQuit = true}
    }
    
    mutating func runningAverageMNS(modelMNS: Int) -> Int{
        if averagedMNS.count < 5 {
            averagedMNS.append(modelMNS)
        } else{
            averagedMNS.remove(at: 0)
            averagedMNS.append(modelMNS)
        }
        
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
            modelCurrentScoreGain = (9 - playerCurrentOffer!)-modelMNS
            playerCurrentScoreGain = playerCurrentOffer! - playerMNS
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
        
        
        if currentRoundNumber >= maxRoundNumber {
            gameOver=true
            //resetGameVariables(newGame: true)
        }  // do something here to end the game
        else {
            currentRoundNumber += 1
            gameOver=false
            
        }
        resetGameVariables(newGame: false)
        
        
        assumedPlayerMNS = runningAverageMNS(modelMNS: modelMNS) // the location fo this function is good
        
        update()
    }
    
    
    mutating func resetGameVariables(newGame: Bool) {
        // reset offer history
        playerPreviousOffer = nil; playerCurrentOffer = nil
        modelPreviousOffer = nil; modelCurrentOffer  = nil
        playerIsFinalOffer = false; modelIsFinalOffer = false
        playerHasQuit = false; modelHasQuit = false
        playerDeclaredMNS = nil; modelDeclaredMNS = nil
        modelInsists = false; playerInsists = false
        
        
        if newGame {
            if verbose {print("\n \n \n \n    !!  NEW GAME  !!  \n \n \n \n ")}
            playerScore = 0; modelScore = 0
            //gameOver=false
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

