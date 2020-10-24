//
//  mapVC.swift
//  Green Thumb
//
//  Created by Megan Worrel on 10/24/20.
//

import UIKit
import GoogleMaps

class mapVC: UIViewController {

    let locmanager = CLLocationManager()
    var userGarden: UserGarden! = nil
    var addingPlant = false
    var gardenCorners: [GMSGroundOverlay] = [GMSGroundOverlay]()
    var gardenPolygon: GMSPolygon? = GMSPolygon()
    @IBOutlet weak var map: GMSMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var drawGardenButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var deleteGardenButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.map.mapType = .satellite
        map.delegate = self
         
        // Zoom in on saved user's garden
        if (userGarden != nil){
            let gardenCenterLat = self.userGarden.brGeoData.lat + abs(self.userGarden.tlGeoData.lat - self.userGarden.brGeoData.lat)
            let gardenCenterLon = self.userGarden.tlGeoData.lon + abs(self.userGarden.brGeoData.lon - self.userGarden.tlGeoData.lon)
            let coordinate = CLLocationCoordinate2D(latitude: gardenCenterLat, longitude: gardenCenterLon)
            map.camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 22.0)
            drawGarden()
        }
        // Don't have user's garden yet, zoom in on current location
        else {
            // Configure the location manager.
            locmanager.delegate = self
            locmanager.desiredAccuracy = kCLLocationAccuracyBest
            locmanager.requestWhenInUseAuthorization()

            // Start getting user's location
            locmanager.startUpdatingLocation()
        }
    }
    
    @IBAction func drawGardenClicked(_ sender: UIButton) {
        if (self.drawGardenButton.titleLabel?.text == "Draw Garden"){
            self.drawGardenButton.setTitle("Next", for: UIControl.State.normal)
            self.cancelButton.isHidden = false
            let alertController = UIAlertController(title: "Step 1", message:
                "Tap the top left corner of your garden", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(alertController, animated: true, completion: nil)
        }
        else if (self.drawGardenButton.titleLabel?.text == "Next"){
            self.drawGardenButton.setTitle("Done", for: UIControl.State.normal)
            let alertController = UIAlertController(title: "Step 2", message:
                "Tap the bottom right corner of your garden", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(alertController, animated: true, completion: nil)
        }
        else if (self.drawGardenButton.titleLabel?.text == "Done"){
            self.drawGardenButton.isHidden = true
            self.cancelButton.isHidden = true
            self.deleteGardenButton.isHidden = false
            // Draw garden on map
            drawGarden()
            // Delete garden corners
            for corner in gardenCorners {
                corner.map = nil
            }
            gardenCorners.removeAll()
        }
    }
    
    @IBAction func deleteGardenClicked(_ sender: UIButton) {
        self.drawGardenButton.setTitle("Draw Garden", for: UIControl.State.normal)
        self.drawGardenButton.isHidden = false
        self.deleteGardenButton.isHidden = true
        self.userGarden = nil
        self.gardenPolygon?.map = nil
        self.gardenPolygon = nil
    }
    
    func drawGarden() {
        // TODO: userGarden should be initialized with tl and br corners
        let path = GMSMutablePath()
        // Add top left corner
        path.add(CLLocationCoordinate2D(latitude: self.userGarden.tlGeoData.lat, longitude: self.userGarden.tlGeoData.lon))
        // Add top right corner
        path.add(CLLocationCoordinate2D(latitude: self.userGarden.tlGeoData.lat, longitude: self.userGarden.brGeoData.lon))
        // Add bottom right corner
        path.add(CLLocationCoordinate2D(latitude: self.userGarden.brGeoData.lat, longitude: self.userGarden.brGeoData.lon))
        // Add bottom left corner
        path.add(CLLocationCoordinate2D(latitude: self.userGarden.brGeoData.lat, longitude: self.userGarden.tlGeoData.lon))
        
        let polygon = GMSPolygon(path: path)
        polygon.fillColor = UIColor(red: 0.25, green: 0, blue: 0, alpha: 0.05);
        polygon.strokeColor = .black
        polygon.strokeWidth = 2
        polygon.map = self.map
        self.gardenPolygon = polygon
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        self.drawGardenButton.setTitle("Draw Garden", for: UIControl.State.normal)
        self.userGarden = nil
        for corner in gardenCorners {
            corner.map = nil
        }
        gardenCorners.removeAll()
    }

}

extension mapVC : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            // Zoom in to the user's current location
            let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            map.camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 22.0)
            // put mylocation marker down
            map.isMyLocationEnabled = true

            locmanager.stopUpdatingLocation()
        }
    }
}

extension mapVC : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if (self.drawGardenButton.titleLabel?.text == "Next" && self.userGarden == nil){
            // User is currently drawing their garden
            // Tap should correspond to top left corner of garden
            let topLeft = GeoData(lat: coordinate.latitude, lon: coordinate.longitude, loc: "topLeft")
            // TODO: garden id switching
            self.userGarden = UserGarden(gardenId: 0, tlGeoData: topLeft, brGeoData: GeoData(lat: 0, lon: 0, loc: ""))
            // Draw dot corresponding to tap
            drawIcon(mapView: mapView, coordinate: coordinate, iconName: "doticon.png")
        }
        else if (self.drawGardenButton.titleLabel?.text == "Done" && self.userGarden.brGeoData.loc != "bottomRight"){
            // User is currently drawing their garden
            // Tap should correspond to bottom right corner of garden
            let bottomRight = GeoData(lat: coordinate.latitude, lon: coordinate.longitude, loc: "bottomRight")
            self.userGarden.brGeoData = bottomRight
            
            // Draw dot corresponding to tap
            drawIcon(mapView: mapView, coordinate: coordinate, iconName: "doticon.png")
        }
        else if (self.addingPlant){
            
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        // TODO: when user taps plant icon segue to plant vc
    }
    
    func drawIcon(mapView: GMSMapView, coordinate: CLLocationCoordinate2D, iconName: String) {
        // Draw icon for tap
        let southWest = CLLocationCoordinate2D(latitude: coordinate.latitude-0.000008, longitude: coordinate.longitude+0.000008)
        let northEast = CLLocationCoordinate2D(latitude: coordinate.latitude+0.000008, longitude: coordinate.longitude-0.000008)
        let overlayBounds = GMSCoordinateBounds(coordinate: southWest, coordinate: northEast)
        
        let icon = UIImage(named: iconName)
        let overlay = GMSGroundOverlay(bounds: overlayBounds, icon: icon)
        if (iconName == "doticon.png"){
            self.gardenCorners.append(overlay)
        }
        overlay.bearing = 0
        overlay.map = mapView
    }
    
}
