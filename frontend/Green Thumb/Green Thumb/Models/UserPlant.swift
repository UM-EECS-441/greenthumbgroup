//
//  UserPlant.swift
//  Green Thumb
//
//  Created by Achintya Kattemalavadi on 10/23/20.
//

class UserPlant {
    var userPlantId: String
    var catalogPlantId: String
    var geodata: GeoData
    var gardenId: String
    
    // TODO: Add more stuff as we add more properties to user customizable plants such as light data etc.
    
    init (userPlantId: string, catalogPlantId: String, geodata: GeoData, gardenId: String) {
        self.userPlantId = userPlantId
        self.catalogPlantId = catalogPlantId
        self.geodata = GeoData
        self.gardenId = gardenId
    }
}
