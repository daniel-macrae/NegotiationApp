// Functions to make a model, with preloaded memories

import Foundation
import TabularData


func initNewModel() -> Model {
    var model = Model()
    
    let dataframe = readCSV()
    if let df = dataframe  {
        
        let slotNames = df.columns.map { col in col.name }
        //print(slotNames)
        for rowNum in 0..<df.shape.0 {
            
            let Experience = model.generateNewChunk(string: "instance")
            let dataRow = df.rows[rowNum]
            Experience.setSlot(slot: "isa", value: "negotiation instance")
        
            for colNum in 0..<df.shape.1 {
                //print(slotNames[colNum])
                let val = dataRow[colNum, String.self]!
                Experience.setSlot(slot: slotNames[colNum], value: val)
            }
            model.dm.addToDM(Experience)
        }

    // add the two strategy chunks
    let aggresiveStrategy = model.generateNewChunk(string: "Aggressive")
    aggresiveStrategy.setSlot(slot: "isa", value: "strategy")
    aggresiveStrategy.setSlot(slot: "strategy", value: "Aggressive")
    model.dm.addToDM(aggresiveStrategy)
    
    let cooperativeStrategy = model.generateNewChunk(string: "Cooperative")
    cooperativeStrategy.setSlot(slot: "isa", value: "strategy")
    cooperativeStrategy.setSlot(slot: "strategy", value: "Cooperative")
    model.dm.addToDM(cooperativeStrategy)
        
    print("MAKING NEW MODEL, number of chunks = " + String(model.dm.chunks.count))
        
    } else {
        print("CSV ERROR: failure to return csv data as dataframe, returning model with no memory...")
    }
    
    model.time += 1.0
    
    return model
}




func readCSV() -> DataFrame? {
    let options = CSVReadingOptions(hasHeaderRow: true, delimiter: ",")
    guard let fileUrl = Bundle.main.url(forResource: "PremadeMemory", withExtension: "csv") else { return nil }

    // this is cursed, but the only way to get around the CSV containing different types (integers...)
    let df = try! DataFrame(contentsOfCSVFile: fileUrl, types:["myStrategy":CSVType.string, "myMNS":CSVType.string, "myBidMNSDifference":CSVType.string, "opponentMoveType":CSVType.string, "opponentMove":CSVType.string, "opponentIsFinal":CSVType.string, "myMoveType":CSVType.string, "myMove":CSVType.string, "myIsFinal":CSVType.string], options: options)
    
    return df
}




func chunkMismatchFunction(_ x: Value, _ y: Value) -> Double? {
    // similarity score
    var M_li: Double? = nil
    
    // this one should be covered in the Declarative memory already, but put it here for completeness' sake
    if x.isEqual(value: y) { M_li = 0 }
    
    // in the case that both slot values are numbers, compute a similarity score
    // as in the equation at the top of page 7 of the paper
    else if let l = x.number(), let i = y.number() {
        
        let fraq = pow((l-i),2) / 2
        M_li = (1 / (fraq + 1)) - 1
        
    // if both slots are strings, check to see if they are similar strategy values
    } else if let string1 = x.text(), let string2 = y.text() {
        if string1 == string2 { M_li = 0 }
        if string1 == "Cooperative" {
            if string2 == "Cooperative" { M_li = 0 }
            else if string1 == "Aggressive" { M_li = -1 }
            else if string1 == "Neutral" { M_li =  -0.1 }
            else { M_li = -0.4 }
        }
        else if string1 == "Aggressive" {
            if string2 == "Cooperative" { M_li =  -1}
            else if string1 == "Aggressive" { M_li = 0 }
            else if string1 == "Neutral" { M_li =  -0.1 }
            else { M_li = -0.4 }
        }
        else if string1 == "Neutral" {
            if string2 == "Cooperative" { M_li =  -0.1 }
            else if string1 == "Aggressive" { M_li =  -0.1 }
            else if string1 == "Neutral" { M_li = 0 }
            else { M_li = -0.4 }
        }
        else { M_li =  -0.4 }  // paper does -1 here, but we have more slots so that would cause those additional slots to contribute to a very high mismatch penalty
        
    // else, the slots values don't match, they are dissimilar
    } else { M_li = -0.4 }
    
    //if M_li == 0 {print("MATCH!")}
    return M_li
}
