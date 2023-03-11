// Functions to make a model, with preloaded memories

import Foundation
import TabularData


func initNewModel() -> Model {
    var model = Model()
    
    let dataframe = readCSV()
    if let df = dataframe  {
        
        let slotNames = df.columns.map { col in col.name }
        print(slotNames)
        for rowNum in 0..<df.shape.0 {
            
            let Experience = model.generateNewChunk(string: "instance")
            let dataRow = df.rows[rowNum]
            
            for colNum in 0..<df.shape.1 {
                //print(slotNames[colNum])
                let val = dataRow[colNum, String.self]!
                Experience.setSlot(slot: slotNames[colNum], value: val)
            }
            model.dm.addToDM(Experience)
        }
                
    print("Number of Chunks in preloaded model:")
    print(model.dm.chunks.count)
    
    // add the two strategy chunks
    let aggresiveStrategy = model.generateNewChunk(string: "agressive")
    aggresiveStrategy.setSlot(slot: "isa", value: "strategy")
    aggresiveStrategy.setSlot(slot: "strategy", value: "agressive")
    model.dm.addToDM(aggresiveStrategy)
    
    let cooperativeStrategy = model.generateNewChunk(string: "cooperative")
    cooperativeStrategy.setSlot(slot: "isa", value: "strategy")
    cooperativeStrategy.setSlot(slot: "strategy", value: "cooperative")
    model.dm.addToDM(cooperativeStrategy)
        
    } else {
        print("CSV ERROR: failure to return csv data as dataframe, returning model with no memory...")
    }
    
    return model
}




func readCSV() -> DataFrame? {
    let options = CSVReadingOptions(hasHeaderRow: true, delimiter: ",")
    guard let fileUrl = Bundle.main.url(forResource: "PremadeMemory", withExtension: "csv") else { return nil }

    // this is cursed, but the only way to get around the CSV containing different types (integers...)
    let df = try! DataFrame(contentsOfCSVFile: fileUrl, types:["myStrategy":CSVType.string, "myMNS":CSVType.string, "myBidMNSDifference":CSVType.string, "opponentMoveType":CSVType.string, "opponentMove":CSVType.string, "opponentIsFinal":CSVType.string, "myMoveType":CSVType.string, "myMove":CSVType.string, "myIsFinal":CSVType.string], options: options)
    
    //"myStrategy","myMNS","myBidMNSDifference","opponentMoveType","opponentMove","opponentIsFinal","myMoveType","myMove","myIsFinal"
    
    //for columnNum in 0...df.shape.1 {
    //    let temp = df[columnNum].map(to: String)
    //    df[columnNum] = temp
    
    
    //print("\(df)")
    //print("HELLO")
    //print(df[row: 0])
    //print("HELLO")
    //var temp = df.rows[0]["modelMNS", String.self]!
    //let temp2 = String(temp)
    //print(temp2)
    
    //print("ROWS " + String(df.shape.0))
    return df
}





///"modelMoveType" = "move-type"
///"Strategy" = "Strategy"
///"modelMNS" = "Model-MNS"
///"bidMNSDifference" = "Bid-diff"  // NEW


///"changePlayer" = "Opponent-move"
///"playerIsFinal" = "NA - opponent-move (final)"



///"playerMoveType" = "NA - opponent-move (opening, final)"




// response
///"changeModel" = "My-move"

///"modelIsFinal" = "NA - "


//slot: "changePlayer", value: changePlayerBid.description  // STRING
//slot: "changeModel", value: changeModelBid.description)  // STRING
///slot: "playerMoveType", value: playerMoveType!)  // STRING
///slot: "modelMoveType", value: modelMoveType!)   // STRING
///slot: "playerIsFinal", value: playerIsFinalOffer)  // BOOL
///slot: "modelIsFinal", value: modelIsFinalOffer)    // BOOL
//slot: "Strategy", value: playerStrategy!)        // STRING

// let newExperience = model.generateNewChunk(string: "instance")
// newExperience.setSlot(slot: "model", value: lastModel!.description)
// newExperience.setSlot(slot: "player", value: lastPlayer!.description)
// newExperience.setSlot(slot: "new-player", value: playerAction)
// model.dm.addToDM(newExperience)




