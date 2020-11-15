//
//  UserPlant.swift
//  Green Thumb
//
//  Created by Achintya Kattemalavadi on 10/23/20.
//

import UIKit

class UserPlant {
    var userPlantId: String = ""
    var catalogPlantId: String
    var geodata: GeoData = GeoData(lat: -1, lon: -1)
    var gardenId: String
    var name: String
    var image: UIImage = UIImage(named: "planticon.png") ?? UIImage()
    
    // TODO: Add more stuff as we add more properties to user customizable plants such as light data etc.
    
    init (catalogPlantId: String, gardenId: String, name: String) {
        self.catalogPlantId = catalogPlantId
        self.gardenId = gardenId
        self.name = name
    }
}
