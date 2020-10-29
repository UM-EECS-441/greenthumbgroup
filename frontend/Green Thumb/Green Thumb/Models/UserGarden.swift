//
//  UserGarden.swift
//  Green Thumb
//
//  Created by Achintya Kattemalavadi on 10/23/20.
//

import UIKit

class UserGarden {
    var gardenId: String
    var name: String
    var address: String
    var tlGeoData: GeoData = GeoData(lat: -1, lon: -1)
    var brGeoData: GeoData = GeoData(lat: -1, lon: -1)
    var image: UIImage?
    
    init (gardenId: String, name: String, address: String) {
        self.gardenId = gardenId
        self.name = name
        self.address = address
    }
}
