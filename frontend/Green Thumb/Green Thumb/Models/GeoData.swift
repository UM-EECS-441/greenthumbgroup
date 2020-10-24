//
//  GeoData.swift
//  Green Thumb
//
//  Created by Achintya Kattemalavadi on 10/23/20.
//

class GeoData {
    var lat: Double
    var lon: Double
    var loc: String

    init(lat: Double, lon: Double, loc: String) {
        self.lat = lat
        self.lon = lon
        self.loc = loc
    }
}
