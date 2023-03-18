//
//  JSONManager.swift
//  Negotiation
//
//  Created by CogModel on 02/03/2023.
//

import Foundation


//func saveModel(model: Model)  {
//    let encoder = JSONEncoder()
//    encoder.outputFormatting = .prettyPrinted
//
//    // if we can save the codeable as a json format
//    if let data = try? encoder.encode(model) {
//        UserDefaults.standard.set(data, forKey: "UserData")
//
//    }
//}


func saveModel(model: Model, filename: String) {
    do {
        let filename = filename + ".json"
        let fileURL = try FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(filename)
        try JSONEncoder()
            .encode(model)
            .write(to: fileURL)
    } catch {
        print("error while saving model")
    }
}


func loadModel(name: String) -> Model {
    do {
        let filename = name + ".json"
        
        let fileURL = try FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(filename)
        
        let data = try Data(contentsOf: fileURL)
        //print(data)
        let model = try JSONDecoder().decode(Model.self, from: data)
        
        for chunk in model.dm.chunks {  // assign the new model to each chunk...
            chunk.value.model = model
        }
        
        return model
 
    } catch {
        print("JSON: error while loading model (or filename not found)")
        let model = initNewModel()
        return model // just return an new model
    }
    
}



func deletePlayerFile(name: String) {
    do {
        let filename = name + ".json"
        let fileURL = try FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(filename)
        
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("User " + name + " file deleted")
        } catch {
            print("User file not found, can't delete")
        }
        //try FileManager.removeItem(fileURL)
    }
    catch {
        print("Player file could not be found, and was not deleted")
    }
    
    
    
}
