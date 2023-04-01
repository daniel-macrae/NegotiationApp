// This is the MODEL file

import Foundation


struct NGModel {
    // for printing of errors and function calls
    var verbose = true
    
    // MARK: Game state management
    var currentRoundNumber: Int = 1
    var maxRoundNumber: Int = 5
    var gameOver: Bool = false
    var modelResponseDuration: Double = 3.0
    var playerResponseDuration: Double?
    var defaultDuration: Double = 3.0  /// in cases of failed retrieval, or the MNS declaration, it takes the model this long to send a messge
    
    //var MNS_combinations: Array<(Int, Int)> = [(2,2),(1,3),(3,1),(2,2),(3,3),(2,3),(3,2),(3,4),(4,3),(2,4),(4,4)]
    var MNS_combinations: Array<(Int, Int)> = [(1,1),(2,2),(3,3),(4,4),
                                               (1,2),(2,1),(1,3),(3,1),(1,4),(4,1),(1,5),(5,1),
                                               (2,3),(3,2),(2,4),(4,2),(2,5),(5,2),
                                               (3,4),(4,3),(3,5),(5,3),
                                               (4,5),(5,4)]
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
    var playerMoveType: String?
    var modelMoveType: String?
    
    var playerDecision: String?
    var modelDecision: String?
    
    var modelInsists = false
    var playerInsists = false
    
    //MNS running average
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
        model.time += playerResponseDuration!
        
        assumedPlayerMNS = runningAverageMNS()
        
        decideModelStrategy()
        if modelStrategy == "Aggressive"{
            modelDeclaredMNS = modelMNS + 1 // lie about the MNS
        } else {
            modelDeclaredMNS = modelMNS  // tell the truth
        }
        modelResponseDuration = defaultDuration
        
        model.time += 0.1 + modelResponseDuration
    }

    // function that allows the model to infer the player's strategy
    mutating func detectPlayerStrategy() {
    
        let playerMNSBidDifference = playerCurrentOffer! - assumedPlayerMNS
       
        
        let query = Chunk(s: "query", m: model)
        query.setSlot(slot: "isa", value: "negotiation instance")
        query.setSlot(slot: "myBidMNSDifference", value: playerMNSBidDifference.description)
        query.setSlot(slot: "myMoveType", value: playerMoveType!)
        query.setSlot(slot: "myIsFinal", value: playerIsFinalOffer.description)
        query.setSlot(slot: "myMNS", value: "N/A") // gets overwritten below if it actually needs a value
        
        
        if playerMoveType! == "Bid" {
            if playerPreviousOffer != nil {
                let changePlayerBid = playerPreviousOffer! - playerCurrentOffer!
                query.setSlot(slot: "myMove", value: changePlayerBid.description)
            }
        } else if playerMoveType! == "Opening" {
            query.setSlot(slot: "myMove", value: playerCurrentOffer!.description)
            query.setSlot(slot: "myBidMNSDifference", value: "N/A")
            query.setSlot(slot: "myMNS", value: assumedPlayerMNS.description)
        } else if playerMoveType! == "Decision" || playerMoveType! == "Quit" {
            query.setSlot(slot: "myMove", value: playerDecision!)
            
        }
        
        if modelMoveType == "Bid" {
            query.setSlot(slot: "opponentMoveType", value: "Bid")
            query.setSlot(slot: "opponentMove", value: (modelCurrentOffer!-modelPreviousOffer!).description)
        }
        query.setSlot(slot: "opponentIsFinal", value: modelIsFinalOffer.description)
        
        
        print("M: player strategy query chunk")
        print(query)
        
        let (latency, chunk) = model.dm.partialRetrieve(chunk: query, mismatchFunction: chunkMismatchFunction)
        model.time +=  latency
        
        if let playerCurrentStrategy = chunk?.slotvals["myStrategy"]?.description {
            playerStrategy = playerCurrentStrategy
            model.addToTrace(string: "Retrieved detectPlayerStrategy() chunk: \(chunk!)")
            
            // if the player's strategy is cooperative or aggressive, reinforce that strategy chunk in the model's memory
            if playerCurrentStrategy != "Neutral" {
                printV("M: Reinforcing: " + playerStrategy)
                let strategyChunk = Chunk(s: "strategy", m: model )
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
        let (latencyStrategy, strategyChunk) = model.dm.retrieve(chunk: strategyQuery)
        if let modelCurrentStrategy = strategyChunk?.slotvals["strategy"]?.description {
            modelStrategy = modelCurrentStrategy
            model.addToTrace(string: " Retrieved decideModelStrategy() chunk \(strategyChunk!)")
            model.time += 0.1 + latencyStrategy
        } else {
            model.addToTrace(string: "Failed decideModelStrategy() retrieval, continue with previous strategy")
            //modelStrategy = "Neutral"   // maybe do this?
        }
    }
    
    
    mutating func saveNewExperience() {
     
        let playerMNSBidDifference = playerCurrentOffer! - assumedPlayerMNS
        
        
        let newExperience = model.generateNewChunk(string: "instance") // from the player's POV
         
        // "myStrategy","myMNS","myBidMNSDifference","opponentMoveType","opponentMove","opponentIsFinal",
        // "myMoveType","myMove","myIsFinal"
        newExperience.setSlot(slot: "isa", value: "negotiation instance")
        
        newExperience.setSlot(slot: "myMoveType", value: playerMoveType!)
        newExperience.setSlot(slot: "myStrategy", value: playerStrategy)
        newExperience.setSlot(slot: "myMNS", value: assumedPlayerMNS.description)
        newExperience.setSlot(slot: "myBidMNSDifference", value: playerMNSBidDifference.description)
        newExperience.setSlot(slot: "myIsFinal", value: playerIsFinalOffer.description)
        newExperience.setSlot(slot: "opponentIsFinal", value: modelIsFinalOffer.description)
        
        newExperience.setSlot(slot: "myDuration", value: time_to_pulses(time_val: playerResponseDuration!).description)
        
        // deal with the "my" slots, from the POV of the player (player='my')
        if playerMoveType! == "Bid" {
            let changePlayerBid = playerPreviousOffer! - playerCurrentOffer!
            newExperience.setSlot(slot: "myMove", value: changePlayerBid.description)}
        else if playerMoveType! == "Decision" || playerMoveType! == "Quit" {// if quit the only point to find the strategy is to reinforce the chunk
            newExperience.setSlot(slot: "myMove", value: playerDecision!)}
        else if playerMoveType! == "Opening" {
            newExperience.setSlot(slot: "myMove", value: playerCurrentOffer!.description)
            newExperience.setSlot(slot: "myBidMNSDifference", value: "N/A")
        }

        // deal with the "opponent" slots, from the POV of the model (model's previous bid = opponent move)
        // filling these slots does require that the model has already made its opening offer, otherwise, these slots are not filled
        if modelMoveType != nil {
            newExperience.setSlot(slot: "opponentMoveType", value: modelMoveType!)
            if modelMoveType! == "Bid" {
                if modelCurrentOffer != nil && modelPreviousOffer != nil  {
                    let changeModelBid = modelCurrentOffer! - modelPreviousOffer!
                    newExperience.setSlot(slot: "opponentMove", value: changeModelBid.description)
                } else {
                    newExperience.setSlot(slot: "opponentMove", value: modelCurrentOffer!.description)
                }
            } else if modelMoveType! == "Opening" {
                newExperience.setSlot(slot: "opponentMove", value: modelCurrentOffer!.description)
            }
            else if modelMoveType! == "Decision" || modelMoveType! == "Quit" {// if quit the only point to find the strategy is to reinforce the chunk
                newExperience.setSlot(slot: "opponentMove", value: modelDecision!)}
        }

        if verbose {print("M: New experience chunk is:") ; print(newExperience)}
        model.dm.addToDM(newExperience)

        model.time += 0.1
        update()
        waitingForAction = true
    }
 
    
    mutating func isItTheSameOffer() {
        // this function is called if the model makes a bid thats identical, or worse, than the player's offer
        // it is very rarely used, but helps the model "reason" about its bids better in edge cases
        if let playerOffer = playerCurrentOffer {
            if modelCurrentOffer! <= (9 - playerOffer) {
                modelMoveType = "Decision"
                modelDecision = "Accept"
                
                modelResponseDuration = defaultDuration
                
                modelMadeADecision()
            }
        }
    }
    
    
    mutating func modelResponse() {
        model.time += playerResponseDuration!
        
        if verbose {print("\n \n MODEL IS RESPONDING TO PLAYER BID. Number of chunks in its memory: " + String(model.dm.chunks.count))}
        
        detectPlayerStrategy()
        saveNewExperience()
        decideModelStrategy() // model decides what strategy it should use to respond
        
        
        modelPreviousOffer = modelCurrentOffer
        // reset variable indicating if the model is making an identical bid
        modelInsists = false
    
        // if making the first offer ("Opening" offer)
        if modelCurrentOffer == nil {

            modelMakeOpeningOffer() // make an opening offer
        }

        else if !(playerMoveType! == "Decision" || playerMoveType! == "Quit") { // if the player has not ended the round, normal bidding
            let query = Chunk(s: "query", m: model)
            query.setSlot(slot: "isa", value: "negotiation instance")
            query.setSlot(slot: "myStrategy", value: modelStrategy)
            query.setSlot(slot: "myBidMNSDifference", value: String(modelPreviousOffer! - modelMNS))
            query.setSlot(slot: "opponentMoveType", value: playerMoveType!)
            query.setSlot(slot: "opponentIsFinal", value: playerIsFinalOffer.description)
            
            if playerPreviousOffer != nil {
                let changePlayerBid = playerCurrentOffer! - playerPreviousOffer!
                query.setSlot(slot: "opponentMove", value: changePlayerBid.description)
            }
            // if the player has made a final offer, we'd prefer a decision chunk, else, "bid" or "decision" chunks are both fine
            if playerIsFinalOffer == true { query.setSlot(slot: "myMoveType", value: "Decision") }
            else {query.setSlot(slot: "myMoveType", value: "Bid")}
            
            print("M: Query chunk \(query)")
            
            let (latency, chunk) = model.dm.partialRetrieve(chunk: query, mismatchFunction: chunkMismatchFunction)
            
            if let modelNewMoveType = chunk?.slotvals["myMoveType"]?.description {
                // get myMoveType and myIsFinal values
                modelMoveType = modelNewMoveType
                if let modelIsFinal = chunk?.slotvals["myIsFinal"]?.description {
                    modelIsFinalOffer = Bool(modelIsFinal)! }
                
                if modelMoveType! == "Bid" {
                    if let modelChangeBid = chunk?.slotvals["myMove"]?.description {
                        modelCurrentOffer = modelPreviousOffer! + Int(Float(modelChangeBid)!)
                        if modelCurrentOffer == modelPreviousOffer { modelInsists = true} // bid hasn't changed
                    }
                // any non-bids (accept, reject, quit) fall into this else condition
                } else {
                    if let modelNewDecision = chunk?.slotvals["myMove"]?.description {
                        modelDecision = modelNewDecision
                        modelMadeADecision()
                    }
                }
                model.addToTrace(string: "modelResponse() Successfully Retrieved Bid \(chunk!)")
            }
            else {
                // enforcing cause it never retrieves the decision chunks
                if playerIsFinalOffer == true {
                    modelMoveType = "Decision"
                    modelDecision = "Reject"
                    modelMadeADecision()
                    model.addToTrace(string: "modelResponse() Failed bid retrieval, reject offer")
                } else {
                    model.addToTrace(string: "modelResponse() Failed bid retrieval, insist on previous offer")
                    modelInsists = true
                }
            }
            
            // MARK: Timing
            // determine how long it takes the model to make an offer
            if let duration = chunk?.slotvals["myDuration"]?.description {
                modelResponseDuration = pulses_to_time(pulses_val: Int(Double(duration)!))
            } else {
                modelResponseDuration = defaultDuration
            }
            
            isItTheSameOffer()  // checks to see if the model is going to make the same bid as the player just made, if yes, then accept the player's offer (as they both want the same split)
            model.time += 0.1 + latency + modelResponseDuration
            
        }
    }
    
    mutating func modelMakeOpeningOffer() {
        let query = Chunk(s: "query", m: model)
    
        query.setSlot(slot: "isa", value: "negotiation instance")
        query.setSlot(slot: "myMNS", value: modelMNS.description)
        query.setSlot(slot: "myMoveType", value: "Opening")
        query.setSlot(slot: "myStrategy", value: modelStrategy)
        
        print("M: Model opening offer query chunk: \(query)")
        
        let (latency, chunk) = model.dm.partialRetrieve(chunk: query, mismatchFunction: chunkMismatchFunction)
        
        
        if let modelOffer = chunk?.slotvals["myMove"]?.description {
            model.addToTrace(string: "Retrieved Opening Offer: \(chunk!)")
            // MARK: We might have to check first if the retrieved chunk is actually an opening bid chunk (sometimes it got a decision chunk here, which causes the next line to crash because the myMove is a string)
            modelCurrentOffer = Int(Float(modelOffer)!) // This is a mess we need to fix it
            modelMoveType = "Opening" // say bid instead of 'opening', makes saving chunks later on better
        } else {
            modelCurrentOffer = Int.random(in: modelDeclaredMNS!..<10)  /// model makes a completely random offer above their declared MNS
            model.addToTrace(string: "Failed retrieval of opening offer, random offer")
            modelMoveType = "Opening"
        }
        
        // MARK: Timing
        // determine how long it takes the model to make an opening offer
        if let duration = chunk?.slotvals["myDuration"]?.description {
            print(duration)
            modelResponseDuration = pulses_to_time(pulses_val: Int(Double(duration)!))
        } else {
            modelResponseDuration = defaultDuration
        }
        model.time += 0.1 + latency + modelResponseDuration
    }
    
    mutating func modelMadeADecision() {
        if modelDecision == "Accept" {
            modelHasQuit = false}
        else if modelDecision == "Reject" {
            modelHasQuit = true}
        else if modelMoveType! == "Quit" {
            modelHasQuit = true}
    }
    
    mutating func runningAverageMNS() -> Int {
        
        let playerMNSQuery = Chunk(s: "queryMNS", m: model)
        playerMNSQuery.setSlot(slot: "isa", value: "MNS")
        
        let (latency, chunk) = model.dm.blendedRetrieve(chunk: playerMNSQuery)
        model.time += latency
        
        if let expectedplayerMNS = chunk!.slotvals["myMNS"]?.description {
            let assumedPlayerMNS = Int(round(Double(expectedplayerMNS)!))  // round to an integer MNs value
            return assumedPlayerMNS
        } else {
            return 3 // just a default, never gets used anyway
        }
    }

    
    // MARK: GAME MANAGEMENT FUNCTIONS
    
    // select new MNSs for both players (call this once a round finishes)
    mutating func pickMNS() {
        if verbose {print("M: picking new MNS values")}
        let randomMNS = MNS_combinations.randomElement()!
 
        playerMNS = randomMNS.0
        modelMNS = randomMNS.1
        
        
        // MARK: ATTEMPT AT BLENDED RETREIVAL OF MNSs
        let newMNS = Chunk(s: "MNS" + model.time.description, m: model)
        newMNS.setSlot(slot: "isa", value: "MNS")
        newMNS.setSlot(slot: "myMNS", value: modelMNS.description)
        
        model.dm.addToDM(newMNS)
        model.addToTrace(string: "Added MNS of this new round to memory")
        model.time += 0.1
        update()

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
        
        // if neither player has quit, an agreement was made and their scores should be updated
        if !(playerHasQuit || modelHasQuit) {
            updateScores(playerOffered: playerOffered)
        }
        
        if currentRoundNumber >= maxRoundNumber {
            gameOver=true // this variable causes changes in the buttons on the view if the game is finished
        } else {
            currentRoundNumber += 1
            gameOver=false
        }
        // set up a new round
        resetGameVariables(newGame: false)
        //assumedPlayerMNS = runningAverageMNS()
        
        savePlayerModel() // save the model's memories into a json file
        update()
    }
    
    
    mutating func resetGameVariables(newGame: Bool) {
        // reset offer history
        playerMoveType = nil; modelMoveType = nil
        playerPreviousOffer = nil; playerCurrentOffer = nil
        modelPreviousOffer = nil; modelCurrentOffer  = nil
        playerIsFinalOffer = false; modelIsFinalOffer = false
        playerHasQuit = false; modelHasQuit = false
        playerDeclaredMNS = nil; modelDeclaredMNS = nil
        modelInsists = false; playerInsists = false
        modelResponseDuration = defaultDuration
        
        
        if newGame {
            if verbose {print("\n \n \n \n    !!!  NEW GAME  !!!  \n \n \n \n ")}
            playerScore = 0; modelScore = 0
            currentRoundNumber = 1
        } else {
            if verbose {print("\n \n \n \n    ~  NEW ROUND  ~   \n \n \n \n ")}
        }
        
        pickMNS()  // new MNS values for the next round
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

