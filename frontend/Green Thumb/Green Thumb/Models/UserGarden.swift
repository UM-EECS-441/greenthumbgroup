//
//  UserGarden.swift
//  Green Thumb
//
//  Created by Achintya Kattemalavadi on 10/23/20.
//

class UserGarden {
    var gardenId: String
    var tlGeoData: GeoData
    var brGeoData: GeoData
    
    init (gardenId: String, var tlGeoData: String, var brGeoData: String) {
        self.gardenId = gardenId
        self.tlGeoData = tlGeoData
        self.brGeoData = brGeoData
    }
}
