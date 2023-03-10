//
//  JSONManager.swift
//  Negotiation
//
//  Created by CogModel on 02/03/2023.
//

import Foundation


func saveModel(model: Model)  {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    
    // if we can save the codeable as a json format
    if let data = try? encoder.encode(model) {
        UserDefaults.standard.set(data, forKey: "UserData")
        
    }
}


func saveModel2(model: Model, filename: String) {
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


func loadModel2(filename: String) -> Model {
    do {
        let filename = filename + ".json"
        
        let fileURL = try FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(filename)
        
        let data = try Data(contentsOf: fileURL)
        //print(data)
        let model = try JSONDecoder().decode(Model.self, from: data)
        return model
 
    } catch {
        print("error while loading model, returning empty one")
        return Model() // just return an new empty model idk
    }
    
}


