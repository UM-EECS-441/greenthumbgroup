//
//  UserGarden.swift
//  Green Thumb
//
//  Created by Achintya Kattemalavadi on 10/23/20.
//

import UIKit

class UserGarden {
    var gardenId: Int
    var name: String
    var address: String
    var tlGeoData: GeoData = GeoData(lat: 0, lon: 0, loc: "")
    var brGeoData: GeoData = GeoData(lat: 0, lon: 0, loc: "")
    var image: UIImage?
    
    init (gardenId: Int, name: String, address: String) {
        self.gardenId = gardenId
        self.name = name
        self.address = address
    }
}
