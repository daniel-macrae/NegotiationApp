// Functions to make a model, with preloaded memories

import Foundation
import TabularData

// make a new model, and give it chunks in memory to start off with
func initNewModel() -> Model {
    let model = Model()
    
    let dataframe = readCSV()
    if let df = dataframe  {
        
        let slotNames = df.columns.map { col in col.name }
        for rowNum in 0..<df.shape.0 {
            
            let Experience = model.generateNewChunk(string: "instance")
            let dataRow = df.rows[rowNum]
            Experience.setSlot(slot: "isa", value: "negotiation instance")
        
            for colNum in 0..<df.shape.1 {
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



// Function that reads the premadememory csv file, returns a dataframe
func readCSV() -> DataFrame? {
    let options = CSVReadingOptions(hasHeaderRow: true, delimiter: ",")
    guard let fileUrl = Bundle.main.url(forResource: "PremadeMemory", withExtension: "csv") else { return nil }

    
    let df = try! DataFrame(contentsOfCSVFile: fileUrl, types:["myStrategy":CSVType.string, "myMNS":CSVType.string, "myBidMNSDifference":CSVType.string, "opponentMoveType":CSVType.string, "opponentMove":CSVType.string, "opponentIsFinal":CSVType.string, "myMoveType":CSVType.string, "myMove":CSVType.string, "myIsFinal":CSVType.string], options: options)
    
    return df
}



// this is the mismatch function used for partial retrieval in the NegotiationModel file

func chunkMismatchFunction(_ x: Value, _ y: Value) -> Double? {
    // similarity score
    var M_li: Double? = nil
    
    let defaultMli = -0.2
    
    /// this one should be covered in the Declarative memory already, but put it here for completeness' sake
    if x.isEqual(value: y) { M_li = 0 }
    
    
    /// in the case that both slot values are numbers, compute a similarity score
    /// as in the equation at the top of page 7 of the paper
    else if let l = x.number(), let i = y.number() {
        
        let fraq = pow((l-i), 2) / 2
        M_li = (1 / (fraq + 1)) - 1
        
    /// if both slots are strings, check to see if they are similar strategy values
    } else if let string1 = x.text(), let string2 = y.text() {
        if string1 == string2 { M_li = 0 }
        if string1 == "Cooperative" {
            if string2 == "Cooperative" { M_li = 0 }
            else if string1 == "Aggressive" { M_li = -1 }
            else if string1 == "Neutral" { M_li =  -0.1 }
            else { M_li = defaultMli }
        }
        else if string1 == "Aggressive" {
            if string2 == "Cooperative" { M_li =  -1}
            else if string1 == "Aggressive" { M_li = 0 }
            else if string1 == "Neutral" { M_li =  -0.1 }
            else { M_li = defaultMli }
        }
        else if string1 == "Neutral" {
            if string2 == "Cooperative" { M_li =  -0.1 }
            else if string1 == "Aggressive" { M_li =  -0.1 }
            else if string1 == "Neutral" { M_li = 0 }
            else { M_li = defaultMli }
        }
        else if string2 == "Decision" && string1 != "Decision" { /// if requesting a decision, and the chunk in memory is not a decision
            return nil
        }
        else if string2 == "Opening" && string1 != "Opening" { /// if requesting an opening offer
            return nil
        }
        else { M_li =  defaultMli }  /// paper does -1 here, but we have more slots so that would cause those additional slots to contribute to a very high mismatch penalty
        
    /// else, the slots values don't match, they are dissimilar
    } else { M_li = defaultMli }
    
    
    return M_li
}


// MARK: Functions for the model's timekeeping

let a = 1.1
let b = 0.015
let t_0 = 0.011

func noise(s: Double) -> Double {
    let random = Double.random(in: 0.001 ..< 0.999)
    return s * log((1-random)/random)
}

func timeToPulses(time_val: Double) -> Int {
    var time = time_val
    var pulses = 0
    var pulse_duration = t_0
    
    while time >= pulse_duration {
        time -= pulse_duration
        pulses += 1
        pulse_duration = a * pulse_duration + noise(s: (a * b * pulse_duration))
    }
    
    return pulses
}

func pulsesToTime(pulses_val: Int) -> Double {
    var pulses = pulses_val
    var time = 0.0
    var pulse_duration = t_0
    
    while pulses >= 0 {
        time += pulse_duration
        pulses -= 1
        pulse_duration = a * pulse_duration + noise(s: (a * b * pulse_duration))
    }
    
    return time
}
