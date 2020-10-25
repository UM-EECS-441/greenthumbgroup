//
//  mapVC.swift
//  Green Thumb
//
//  Created by Megan Worrel on 10/24/20.
//

import UIKit
import GoogleMaps
import SwiftyJSON

class mapVC: UIViewController, PlantReturnDelegate {

    let locmanager = CLLocationManager()
    var addingPlant = false
    // Must pass in user garden
    var userGarden: UserGarden!
    var gardenCorners: [GMSGroundOverlay] = [GMSGroundOverlay]()
    var gardenPolygon: GMSPolygon? = GMSPolygon()
    var plantArray: [UserPlant]? = [UserPlant]()
    var plantOverlays: [GMSGroundOverlay]? = [GMSGroundOverlay]()
    var currentPlant: UserPlant? = nil
    var translatedGardenLoc: CLLocationCoordinate2D? = nil
    // TODO: store in secure location
    var apiKey = "AIzaSyCQAqHC69Jq2-nTvK7BJa4MwX5WXqS0VQA"
    @IBOutlet weak var map: GMSMapView!
    @IBOutlet weak var drawGardenButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var deleteGardenButton: UIButton!
    @IBOutlet weak var addPlantLabel: UILabel!
    
    func didReturn(_ result: UserPlant) {
        self.currentPlant = result
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.map.mapType = .satellite
        map.delegate = self
        
        
        // Geocode the address
        let urlEncoded = userGarden.address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let fullUrl = "https://maps.googleapis.com/maps/api/geocode/json?address=\(urlEncoded ?? "")&key=\(apiKey)"
        
        let url = URL(string: fullUrl)!

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            do {
                let json = try JSON(data: data)
                let gardenLat: Double? = json["results"][0]["geometry"]["location"]["lat"].double ?? nil
                let gardenLong: Double? = json["results"][0]["geometry"]["location"]["lng"].double ?? nil
                if let lat = gardenLat {
                    if let lng = gardenLong {
                        self.translatedGardenLoc = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                    }
                }
                self.centerMapOnGarden()
            } catch {
                print(error)
            }
            print(String(data: data, encoding: .utf8)!)
        }

        task.resume()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (currentPlant != nil){
            self.addPlantLabel.isHidden = false
        }
    }
    
    func centerMapOnGarden() {
        // TODO: eventually get map data from backend
        // TODO: either zoom in on garden's location from user address input or saved garden coordinates
        // Zoom in on saved user's garden
        if (userGarden.brGeoData.loc != "" && userGarden.tlGeoData.loc != ""){
            let gardenCenterLat = self.userGarden.brGeoData.lat + abs(self.userGarden.tlGeoData.lat - self.userGarden.brGeoData.lat)
            let gardenCenterLon = self.userGarden.tlGeoData.lon + abs(self.userGarden.brGeoData.lon - self.userGarden.tlGeoData.lon)
            let coordinate = CLLocationCoordinate2D(latitude: gardenCenterLat, longitude: gardenCenterLon)
            map.camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 22.0)
            drawGarden()
        }
        else if (self.translatedGardenLoc != nil){
            map.camera = GMSCameraPosition.camera(withTarget: self.translatedGardenLoc!, zoom: 22.0)
        }
        /*
        // Don't have user's garden yet, zoom in on current location
        else {
            // Configure the location manager.
            locmanager.delegate = self
            locmanager.desiredAccuracy = kCLLocationAccuracyBest
            locmanager.requestWhenInUseAuthorization()

            // Start getting user's location
            locmanager.startUpdatingLocation()
        }
        */
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
        // Reset user garden to default
        self.userGarden = UserGarden(gardenId: 0, name: "", address: "")
        self.gardenPolygon?.map = nil
        self.gardenPolygon = nil
        // Remove plants
        if let plantOverlaysUnwrapped = plantOverlays {
            for overlay in plantOverlaysUnwrapped {
                overlay.map = nil
            }
            self.plantOverlays = nil
        }
        self.plantArray = nil
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
    
    @IBAction func addPlantClicked(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let addPlantOptionsVC = storyBoard.instantiateViewController(withIdentifier: "addPlantOptionsVC") as! addPlantOptionsVC
        addPlantOptionsVC.userGarden = userGarden
        self.present(addPlantOptionsVC, animated: true, completion: nil)
    }
    
}

/*
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
 */

extension mapVC : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if (self.drawGardenButton.titleLabel?.text == "Next" && self.userGarden.tlGeoData.loc == ""){
            // User is currently drawing their garden
            // Tap should correspond to top left corner of garden
            let topLeft = GeoData(lat: coordinate.latitude, lon: coordinate.longitude, loc: "topLeft")
            // TODO: garden id switching
            self.userGarden.tlGeoData = topLeft
            // Draw dot corresponding to tap
            drawIcon(mapView: mapView, coordinate: coordinate, iconImage: nil)
        }
        // TODO: make sure this works
        else if (self.drawGardenButton.titleLabel?.text == "Done" && self.userGarden.brGeoData.loc == ""){
            // User is currently drawing their garden
            // Tap should correspond to bottom right corner of garden
            let bottomRight = GeoData(lat: coordinate.latitude, lon: coordinate.longitude, loc: "bottomRight")
            self.userGarden.brGeoData = bottomRight
            
            // Draw dot corresponding to tap
            drawIcon(mapView: mapView, coordinate: coordinate, iconImage: nil)
        }
        else if (self.currentPlant != nil){
            drawIcon(mapView: self.map, coordinate: coordinate, iconImage: currentPlant!.image)
            self.addPlantLabel.isHidden = true
            self.currentPlant = nil
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        // TODO: when user taps plant icon segue to plant vc
    }
    
    func drawIcon(mapView: GMSMapView, coordinate: CLLocationCoordinate2D, iconImage: UIImage?) {
        // Draw icon for tap
        
        if (iconImage == nil) {
            // Adding garden corner
            let southWest = CLLocationCoordinate2D(latitude: coordinate.latitude-0.000008, longitude: coordinate.longitude+0.000008)
            let northEast = CLLocationCoordinate2D(latitude: coordinate.latitude+0.000008, longitude: coordinate.longitude-0.000008)
            let overlayBounds = GMSCoordinateBounds(coordinate: southWest, coordinate: northEast)
            
            let icon = UIImage(named: "doticon.png")
            let overlay = GMSGroundOverlay(bounds: overlayBounds, icon: icon)
            self.gardenCorners.append(overlay)
            overlay.bearing = 0
            overlay.map = mapView
        }
        else {
            // Adding plant
            let southWest = CLLocationCoordinate2D(latitude: coordinate.latitude-0.000004, longitude: coordinate.longitude+0.000004)
            let northEast = CLLocationCoordinate2D(latitude: coordinate.latitude+0.000004, longitude: coordinate.longitude-0.000004)
            let overlayBounds = GMSCoordinateBounds(coordinate: southWest, coordinate: northEast)
            
            let overlay = GMSGroundOverlay(bounds: overlayBounds, icon: iconImage)
            
            currentPlant?.geodata = GeoData(lat: coordinate.latitude, lon: coordinate.longitude, loc: "plantLoc")
            self.plantArray?.append(currentPlant!)
            plantOverlays?.append(overlay)
            
            self.gardenCorners.append(overlay)
            overlay.bearing = 0
            overlay.map = mapView
        }
    }
    
}
