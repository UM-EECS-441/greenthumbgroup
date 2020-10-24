//
//  CatalogPlant.swift
//  Green Thumb
//
//  Created by Achintya Kattemalavadi on 10/23/20.
//

class CatalogPlant {
    var plantId: String
    var plantName: String
    var plantScientific: String
    var plantType: String
    var plantInfo: String
    
    init (plantId: String, plantName: String, plantScientific: String, plantType: String, plantInfo: String) {
        self.plantId = plantId
        self.plantName = plantName
        self.plantScientific = plantScientific
        self.plantType = plantType
        self.plantInfo = plantInfo
    }
}
