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

        DispatchQueue.main.async {
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                guard let data = data else { return }
                DispatchQueue.main.async {
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
                }
                //print(String(data: data, encoding: .utf8)!)
            }

            task.resume()
        }
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
        if (userGarden.brGeoData.lat != -1 && userGarden.tlGeoData.lat != -1){
            let gardenCenterLat = self.userGarden.brGeoData.lat + abs(self.userGarden.tlGeoData.lat - self.userGarden.brGeoData.lat)
            let gardenCenterLon = self.userGarden.tlGeoData.lon + abs(self.userGarden.brGeoData.lon - self.userGarden.tlGeoData.lon)
            let coordinate = CLLocationCoordinate2D(latitude: gardenCenterLat, longitude: gardenCenterLon)
            map.camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 22.0)
            drawGarden()
            // TODO: add saved plants to garden
            let url = URL(string: "http://192.81.216.18/api/v1/usergarden/\(self.userGarden.gardenId)/")!
            
            var request = URLRequest(url: url)
            let delegate = UIApplication.shared.delegate as! AppDelegate
            request.setValue(delegate.cookie, forHTTPHeaderField: "Cookie")
            request.httpMethod = "GET"

            let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
                print(response)
                //print(data)
                guard let data = data else {
                    return
                }
                do{
                    let json = try JSON(data: data)
                    let plants = json["plants"].array
                    if let unwrappedplants = plants{
                        for plant in unwrappedplants {
                            // Get plant data
                            let plantId = plant["$oid"].stringValue
                            let url = URL(string: "http://192.81.216.18/api/v1/usergarden/get_plants/\(plantId)/")!
                            
                            var request = URLRequest(url: url)
                            let delegate = UIApplication.shared.delegate as! AppDelegate
                            request.setValue(delegate.cookie, forHTTPHeaderField: "Cookie")
                            request.httpMethod = "GET"

                            let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
                                print(response)
                                //print(data)
                                guard let data = data else {
                                    return
                                }
                                DispatchQueue.main.async{
                                    do{
                                        let json = try JSON(data: data)
                                        let lat = json["latitude"].doubleValue
                                        let lon = json["longitude"].doubleValue
                                        let overlay = self.drawIcon(mapView: self.map, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon), iconImage: UIImage(named: "planticon.png"))
                                        self.plantOverlays?.append(overlay)
                                    }
                                    catch {
                                        print(error)
                                    }
                                }
                            }
                            
                            task.resume()
                        }
                    }
                }
                catch {
                    print(error)
                }
                
            }
            
            task.resume()
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
            // TODO: add garden bounds to database
            // Add garden to database
            let url = URL(string: "http://192.81.216.18/api/v1/usergarden/\(self.userGarden.gardenId)/")!
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "PUT"
            
            let delegate = UIApplication.shared.delegate as! AppDelegate
            request.setValue(delegate.cookie, forHTTPHeaderField: "Cookie")
            
            let parameters: [String: Any] = [
                "name": self.userGarden.name,
                "address": self.userGarden.address,
                "latitudetl": self.userGarden.tlGeoData.lat,
                "longitudetl": self.userGarden.tlGeoData.lon,
                "latitudebr": self.userGarden.brGeoData.lat,
                "longitudebr": self.userGarden.brGeoData.lon
            ]
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
           } catch let error {
               print(error.localizedDescription)
           }
            
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                // TODO: handle bad response
                print(response ?? "")
            }
            task.resume()
        }
    }
    
    @IBAction func deleteGardenClicked(_ sender: UIButton) {
        self.drawGardenButton.setTitle("Draw Garden", for: UIControl.State.normal)
        self.drawGardenButton.isHidden = false
        self.deleteGardenButton.isHidden = true
        // Reset user garden to default
        self.userGarden = UserGarden(gardenId: "", name: "", address: "")
        self.gardenPolygon?.map = nil
        self.gardenPolygon = nil
        // Remove plants
        if let plantOverlaysUnwrapped = plantOverlays {
            for overlay in plantOverlaysUnwrapped {
                overlay.map = nil
            }
            self.plantOverlays = nil
        }
        self.userGarden.plants.removeAll()
    }
    
    func drawGarden() {
        // TODO: assert userGarden should be initialized with tl and br corners
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
        if (self.drawGardenButton.titleLabel?.text == "Next" && self.userGarden.tlGeoData.lat == -1){
            // User is currently drawing their garden
            // Tap should correspond to top left corner of garden
            let topLeft = GeoData(lat: coordinate.latitude, lon: coordinate.longitude)
            // TODO: garden id switching
            self.userGarden.tlGeoData = topLeft
            // Draw dot corresponding to tap
            let overlay = drawIcon(mapView: mapView, coordinate: coordinate, iconImage: UIImage(named: "doticon.png"))
            self.gardenCorners.append(overlay)
        }
        // TODO: make sure this works
        else if (self.drawGardenButton.titleLabel?.text == "Done" && self.userGarden.brGeoData.lat == -1){
            // User is currently drawing their garden
            // Tap should correspond to bottom right corner of garden
            let bottomRight = GeoData(lat: coordinate.latitude, lon: coordinate.longitude)
            self.userGarden.brGeoData = bottomRight
            
            // Draw dot corresponding to tap
            let overlay = drawIcon(mapView: mapView, coordinate: coordinate, iconImage: UIImage(named: "doticon.png"))
            self.gardenCorners.append(overlay)
        }
        else if (self.currentPlant != nil){
            let overlay = drawIcon(mapView: self.map, coordinate: coordinate, iconImage: currentPlant!.image)
            
            currentPlant?.geodata = GeoData(lat: coordinate.latitude, lon: coordinate.longitude)
            if let plantToAppend = currentPlant{
                self.userGarden.plants.append(plantToAppend)
            }
            // Update plant data in database
            let url = URL(string: "http://192.81.216.18/api/v1/usergarden/\(self.userGarden.gardenId)/edit_plant/\(self.currentPlant!.userPlantId)/")!
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "PUT"
            
            let delegate = UIApplication.shared.delegate as! AppDelegate
            request.setValue(delegate.cookie, forHTTPHeaderField: "Cookie")
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd hh:mm:ss"
            let date = df.string(from: Date())
            let parameters: [String: Any] = [
                "plant_type_id": "5f97617fcebc5357248531e9",
                "latitude": self.currentPlant!.geodata.lat,
                "longitude": self.currentPlant!.geodata.lon,
                "light_level": -1,
                "last_watered": date
            ]
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
           } catch let error {
               print(error.localizedDescription)
           }
            
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                // TODO: handle bad response
                print(response ?? "")
            }
            task.resume()
            
            
            plantOverlays?.append(overlay)
            self.addPlantLabel.isHidden = true
            self.currentPlant = nil
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        // TODO: when user taps plant icon segue to plant vc
    }
    
    func drawIcon(mapView: GMSMapView, coordinate: CLLocationCoordinate2D, iconImage: UIImage?) -> GMSGroundOverlay {
        // Draw icon for tap
        let southWest = CLLocationCoordinate2D(latitude: coordinate.latitude-0.000008, longitude: coordinate.longitude+0.000008)
        let northEast = CLLocationCoordinate2D(latitude: coordinate.latitude+0.000008, longitude: coordinate.longitude-0.000008)
        let overlayBounds = GMSCoordinateBounds(coordinate: southWest, coordinate: northEast)
        
        let overlay = GMSGroundOverlay(bounds: overlayBounds, icon: iconImage)

        overlay.bearing = 0
        overlay.map = mapView
        return overlay
        
    }
    
}
