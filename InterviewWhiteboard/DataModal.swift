//
//  DataModal.swift
//  InterviewWhiteboard
//
//  Created by Hans Wang on 1/17/21.
//

import UIKit
import PencilKit
import os

class DataModelController {
    /// Dispatch queues for the background operations done by this controller.
    private let serializationQueue = DispatchQueue(label: "SerializationQueue", qos: .background)
    
    /// The URL of the file in which the current data model is saved.
    private var saveURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths.first!
        return documentsDirectory.appendingPathComponent("Whiteboard.data")
    }
    
    /// Save the data model to persistent storage.
    func saveDrawing(_ drawing: PKDrawing) {
        let savingDataModel = drawing
        let url = saveURL
        serializationQueue.async {
            do {
                let encoder = PropertyListEncoder()
                let data = try encoder.encode(savingDataModel)
                try data.write(to: url)
                os_log("Drawing saved.", type: .info)
            } catch {
                os_log("Could not save data model: %s", type: .error, error.localizedDescription)
            }
        }
    }
    
    /// Load the data model from persistent storage
    func loadDataModel(_ callback: @escaping (PKDrawing) -> Void) {
        let url = saveURL
        serializationQueue.async {
            // Load the data model, or the initial test data.
            let drawingData: PKDrawing
            
            if FileManager.default.fileExists(atPath: url.path) {
                do {
                    let decoder = PropertyListDecoder()
                    let data = try Data(contentsOf: url)
                    drawingData = try decoder.decode(PKDrawing.self, from: data)
                } catch {
                    os_log("Could not load data model: %s", type: .error, error.localizedDescription)
                    drawingData = PKDrawing()
                }
            } else {
                drawingData = PKDrawing()
            }
            
            DispatchQueue.main.async {
                callback(drawingData)
            }
        }
    }
}
