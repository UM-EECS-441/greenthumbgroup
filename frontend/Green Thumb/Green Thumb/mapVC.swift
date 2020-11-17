//
//  mapVC.swift
//  Green Thumb
//
//  Created by Megan Worrel on 10/24/20.
//

import UIKit
import GoogleMaps
import SwiftyJSON

class mapVC: UIViewController, PlantReturnDelegate, OverlayReturnDelegate {

    let locmanager = CLLocationManager()
    var addingPlant = false
    // Must pass in user garden
    var userGarden: UserGarden!
    var gardenCorners: [GMSGroundOverlay] = [GMSGroundOverlay]()
    var gardenPolygon: GMSPolygon? = GMSPolygon()
    var plantOverlays: [GMSGroundOverlay]? = [GMSGroundOverlay]()
    var currentOverlay: GMSOverlay = GMSGroundOverlay()
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
    
    func didReturnOverlay(_ result: GMSOverlay) {
        self.currentOverlay = result
        print(self.currentOverlay)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        
        if (currentPlant != nil){
            self.addPlantLabel.isHidden = false
        }
        
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
            }

            task.resume()
        }
    }
    
    func centerMapOnGarden() {
        // Zoom in on saved user's garden if have already mapped garden
        if (userGarden.brGeoData.lat != -1 && userGarden.tlGeoData.lat != -1){
            let gardenCenterLat = self.userGarden.brGeoData.lat + abs(self.userGarden.tlGeoData.lat - self.userGarden.brGeoData.lat)
            let gardenCenterLon = self.userGarden.tlGeoData.lon + abs(self.userGarden.brGeoData.lon - self.userGarden.tlGeoData.lon)
            let coordinate = CLLocationCoordinate2D(latitude: gardenCenterLat, longitude: gardenCenterLon)
            map.camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 22.0)
            drawGarden()
            
            // Add saved plants to garden
            let url = URL(string: "http://192.81.216.18/api/v1/usergarden/\(self.userGarden.gardenId)/")!
            
            var request = URLRequest(url: url)
//            let delegate = UIApplication.shared.delegate as! AppDelegate
            let cookie = UserDefaults.standard.object(forKey: "login") as? String
            request.setValue(cookie, forHTTPHeaderField: "Cookie")
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
                            DispatchQueue.main.async {
                                // Get plant data
                                let plantId = plant["$oid"].stringValue
                                let url = URL(string: "http://192.81.216.18/api/v1/usergarden/get_plants/\(plantId)/")!
                                
                                var request = URLRequest(url: url)
//                                let delegate = UIApplication.shared.delegate as! AppDelegate
                                request.setValue(cookie, forHTTPHeaderField: "Cookie")
                                request.httpMethod = "GET"

                                let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
                                    print(response ?? "")
                                    guard let data = data else {
                                        return
                                    }
                                    DispatchQueue.main.async{
                                        do{
                                            let json = try JSON(data: data)
                                            let water = json["last_watered"].stringValue
                                            let light = json["light_level"].doubleValue
                                            let lon = json["longitude"].doubleValue
                                            let lat = json["latitude"].doubleValue
                                            let id = json["plant_type_id"].stringValue
                                            let name = json["name"].string ?? ""
                                            let overlay = self.drawIcon(mapView: self.map, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon), iconImage: UIImage(named: "planticon.png"))
                                            overlay.isTappable = true
                                            overlay.userData = [
                                                "name": String(name),
                                                "uniq_id": String(plantId),
                                                "type_id": String(id),
                                                "garden_id": String(self.userGarden.gardenId),
                                                "lat": String(lat),
                                                "lon": String(lon),
                                                "last_watered": String(water),
                                                "light_level": String(light)
                                            ]
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
                }
                catch {
                    print(error)
                }
                
            }
            
            task.resume()
        }
        // Haven't mapped garden yet, zoom in on garden address instead
        else if (self.translatedGardenLoc != nil){
            map.camera = GMSCameraPosition.camera(withTarget: self.translatedGardenLoc!, zoom: 22.0)
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
            // Add garden to database
            let url = URL(string: "http://192.81.216.18/api/v1/usergarden/\(self.userGarden.gardenId)/")!
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "PUT"
            
//            let delegate = UIApplication.shared.delegate as! AppDelegate
            let cookie = UserDefaults.standard.object(forKey: "login") as? String
            request.setValue(cookie, forHTTPHeaderField: "Cookie")
            
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
        // TODO: update database with values
    }
    
    func drawGarden() {
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
        let homeCatalogVC = storyBoard.instantiateViewController(withIdentifier: "catalogVC") as! catalogVC
        homeCatalogVC.userGarden = userGarden
        homeCatalogVC.returnDelegate = self
        self.present(homeCatalogVC, animated: true, completion: nil)
    }
    
}

extension mapVC : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if (self.drawGardenButton.titleLabel?.text == "Next" && self.userGarden.tlGeoData.lat == -1){
            // User is currently drawing their garden
            // Tap should correspond to top left corner of garden
            let topLeft = GeoData(lat: coordinate.latitude, lon: coordinate.longitude)
            self.userGarden.tlGeoData = topLeft
            // Draw dot corresponding to tap
            let overlay = drawIcon(mapView: mapView, coordinate: coordinate, iconImage: UIImage(named: "doticon.png"))
            self.gardenCorners.append(overlay)
        }
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
            print("check id \(self.currentPlant!.catalogPlantId)")
//            let delegate = UIApplication.shared.delegate as! AppDelegate
            let cookie = UserDefaults.standard.object(forKey: "login") as? String
            request.setValue(cookie, forHTTPHeaderField: "Cookie")
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            let date = df.string(from: Date()) + " 00:00:00"
            // TODO: edit last watered
            // TODO: edit light level
            let parameters: [String: Any] = [
                "name": self.currentPlant!.name,
                "plant_type_id": self.currentPlant!.catalogPlantId,
                "latitude": self.currentPlant!.geodata.lat,
                "longitude": self.currentPlant!.geodata.lon,
                "light_level": -1,
                "last_watered": date
            ]
            print(parameters)
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
            
            overlay.isTappable = true
            plantOverlays?.append(overlay)
            // TODO: fix user data
            let light = -1
            let dfsave = DateFormatter()
            dfsave.dateFormat = "E, d MMM yyyy"
            let datesave = dfsave.string(from: Date()) + " 00:00:00 GMT"
            let water = datesave
            overlay.userData = [
                "name": String(currentPlant!.name),
                "uniq_id": String(currentPlant!.userPlantId),
                "type_id": String(currentPlant!.catalogPlantId),
                "garden_id": String(currentPlant!.gardenId),
                "lat": String(self.currentPlant!.geodata.lat),
                "lon": String(self.currentPlant!.geodata.lon),
                "last_watered": String(water),
                "light_level": String(light)
            ]
            self.addPlantLabel.isHidden = true
            self.currentPlant = nil
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        // Check that tapped a plant
        print("tapped")
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewGardenPlantVC = storyBoard.instantiateViewController(withIdentifier: "viewGardenPlantVC") as! viewGardenPlantVC
        viewGardenPlantVC.overlayDelegate = self
        viewGardenPlantVC.currentOverlay = overlay
        print(overlay.userData ?? "")
        if let data: [String: String] = overlay.userData as? [String : String]{
            print(data)
            viewGardenPlantVC.nameText = data["name"] ?? ""
            viewGardenPlantVC.uniq_id = data["uniq_id"] ?? ""
            viewGardenPlantVC.type_id = data["type_id"] ?? ""
            viewGardenPlantVC.garden_id = data["garden_id"] ?? ""
            viewGardenPlantVC.lat = Double(data["lat"] ?? "") ?? -1
            viewGardenPlantVC.lon = Double(data["lon"] ?? "") ?? -1
            viewGardenPlantVC.lightEst = data["light_level"] ?? ""
            viewGardenPlantVC.nameText = data["name"] ?? ""
            viewGardenPlantVC.lastWatered = data["last_watered"] ?? ""
        }
        self.present(viewGardenPlantVC, animated: true, completion: nil)
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
