//
//  UserPlant.swift
//  Green Thumb
//
//  Created by Achintya Kattemalavadi on 10/23/20.
//

import UIKit

class UserPlant {
    var userPlantId: String
    var catalogPlantId: String?
    // Make optional bc might not have location data yet when plant created
    var geodata: GeoData = GeoData(lat: 0, lon: 0, loc: "")
    var gardenId: String
    var name: String
    var image: UIImage
    
    // TODO: Add more stuff as we add more properties to user customizable plants such as light data etc.
    
    init (userPlantId: String, catalogPlantId: String?, gardenId: String, name: String, image: UIImage) {
        self.userPlantId = userPlantId
        self.catalogPlantId = catalogPlantId
        self.gardenId = gardenId
        self.name = name
        self.image = image
    }
}
