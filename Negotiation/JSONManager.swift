//
//  JSONManager.swift
//  Negotiation
//
//  Created by CogModel on 02/03/2023.
//
import Foundation


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


func loadModel(name: String) -> (Model, Bool) {
    do {
        let filename = name + ".json"
        
        let fileURL = try FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(filename)
        
        let data = try Data(contentsOf: fileURL)
        //print(data)
        let model = try JSONDecoder().decode(Model.self, from: data)
        
        for chunk in model.dm.chunks {  /// assign the new model to each chunk
            chunk.value.model = model
        }
        
        return (model, false)
 
    } catch {
        print("JSON: filename not found")
        let model = initNewModel()
        return (model, true) /// just return an new model
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
            print("JSON: User " + name + " file deleted")
        } catch {
            print("JSON: User file not found, can't delete")
        }
    }
    catch {
        print("JSON: Player file could not be found, and was not deleted")
    }
}



func listFiles() -> [String]  {
    var playerNames: [String] = []
    
    do {
        /// get the contents of the documents folder
        let Path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let directoryContents = try FileManager.default.contentsOfDirectory(at: Path, includingPropertiesForKeys: nil, options: .skipsHiddenFiles).sorted { $0.path < $1.path }

        /// process the file directories so that its just the players' names
        for filepath in directoryContents {
            let jsonfilepath = filepath.deletingPathExtension().lastPathComponent//.path
            playerNames.append(jsonfilepath)
            }
    } catch {
        print("JSON: No exisiting files found, returning empty player list")
    }
    return playerNames
}
