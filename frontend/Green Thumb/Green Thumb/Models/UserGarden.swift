//
//  UserGarden.swift
//  Green Thumb
//
//  Created by Achintya Kattemalavadi on 10/23/20.
//

class UserGarden {
    var gardenId: Int
    var tlGeoData: GeoData
    var brGeoData: GeoData
    
    init (gardenId: Int, tlGeoData: GeoData, brGeoData: GeoData) {
        self.gardenId = gardenId
        self.tlGeoData = tlGeoData
        self.brGeoData = brGeoData
    }
}
