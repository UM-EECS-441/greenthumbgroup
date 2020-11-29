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
    var deletingPlant = false
    var movingPlant = false
    // Must pass in user garden
    var userGarden: UserGarden!
    var gardenCorners: [GMSGroundOverlay] = [GMSGroundOverlay]()
    var gardenPolygon: GMSPolygon? = GMSPolygon()
    var plantOverlays: [GMSGroundOverlay]? = [GMSGroundOverlay]()
    var currentOverlay: GMSGroundOverlay = GMSGroundOverlay()
    var currentPlant: UserPlant? = nil
    var translatedGardenLoc: CLLocationCoordinate2D? = nil
    weak var returnDelegate : ReturnDelegate!
    var apiKey = "AIzaSyCQAqHC69Jq2-nTvK7BJa4MwX5WXqS0VQA"
    @IBOutlet weak var map: GMSMapView!
    @IBOutlet weak var drawGardenButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var deleteGardenButton: UIButton!
    @IBOutlet weak var addPlantLabel: UILabel!
    
    func didReturn(_ result: UserPlant) {
        self.currentPlant = result
        self.addPlantLabel.isHidden = false
    }
    
    func didReturnOverlay(_ result: GMSGroundOverlay, _ delete: Bool, _ move: Bool) {
        self.currentOverlay = result
        self.deletingPlant = delete
        self.movingPlant = move
        
        if (deletingPlant) {
            // delete plant from database
            var plantid = ""
            if let data: [String: String] = currentOverlay.userData as? [String : String]{
                print(data)
                plantid = data["uniq_id"] ?? ""
            }
            
            let url = URL(string: "http://192.81.216.18/api/v1/usergarden/\(self.userGarden.gardenId)/delete_plant/\(plantid)/")!
            var request = URLRequest(url: url)

            request.httpMethod = "DELETE"
            
            let cookie = UserDefaults.standard.object(forKey: "login") as? String
            request.setValue(cookie, forHTTPHeaderField: "Cookie")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                print(response!)
                if error != nil{
                    print(error!)
                }
            }

            task.resume()
            
            // delete plant overlay
            currentOverlay.map = nil
            if let overlayIndex = plantOverlays!.firstIndex(of:currentOverlay) {
                plantOverlays!.remove(at: overlayIndex)
            }
        }
        
        if (movingPlant) {
            // remove plant from map
            currentOverlay.map = nil
            // prompt user to change the plant location
            self.addPlantLabel.isHidden = false
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        
        
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
            self.drawGardenButton.setTitle("Redraw Garden", for: UIControl.State.normal)
            
            let gardenCenterLat = self.userGarden.brGeoData.lat + abs(self.userGarden.tlGeoData.lat - self.userGarden.brGeoData.lat)
            let gardenCenterLon = self.userGarden.tlGeoData.lon + abs(self.userGarden.brGeoData.lon - self.userGarden.tlGeoData.lon)
            let coordinate = CLLocationCoordinate2D(latitude: gardenCenterLat, longitude: gardenCenterLon)
            map.camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 22.0)
            drawGarden()
            
            // Add saved plants to garden
            let url = URL(string: "http://192.81.216.18/api/v1/usergarden/\(self.userGarden.gardenId)/")!
            
            var request = URLRequest(url: url)

            let cookie = UserDefaults.standard.object(forKey: "login") as? String
            request.setValue(cookie, forHTTPHeaderField: "Cookie")
            request.httpMethod = "GET"

            let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
                print(response!)
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
                                            let intensity = json["light_intensity"].doubleValue
                                            let duration = json["light_duration"].doubleValue
                                            let lon = json["longitude"].doubleValue
                                            let lat = json["latitude"].doubleValue
                                            let id = json["plant_type_id"].stringValue
                                            let name = json["name"].string ?? ""
                                            let price = json["price"].doubleValue
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
                                                "light_intensity": String(intensity),
                                                "light_duration": String(duration),
                                                "price": String(price)
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
            self.cancelButton.isHidden = true
            self.drawGardenButton.setTitle("Redraw Garden", for: UIControl.State.normal)

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
        else if (self.drawGardenButton.titleLabel?.text == "Redraw Garden"){
            self.cancelButton.isHidden = false
            self.drawGardenButton.setTitle("Next", for: UIControl.State.normal)
            self.gardenPolygon?.map = nil
            self.gardenPolygon = nil
            // Reset geodata on garden
            self.userGarden.brGeoData = GeoData(lat: -1, lon: -1)
            self.userGarden.tlGeoData = GeoData(lat: -1, lon: -1)
            
            // Update garden in database
            let url = URL(string: "http://192.81.216.18/api/v1/usergarden/\(self.userGarden.gardenId)/")!
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "PUT"
            
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
                print(response ?? "")
            }
            task.resume()
            
            let alertController = UIAlertController(title: "Step 1", message:
                "Tap the top left corner of your garden", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func deleteGardenClicked(_ sender: UIButton) {
        self.gardenPolygon?.map = nil
        self.gardenPolygon = nil
        
        // Segue back to main screen
        self.returnDelegate.didReturn(self.userGarden, true)
        self.dismiss(animated: true, completion: nil)
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
        else if (movingPlant){
            currentOverlay.map = self.map
            currentOverlay.position = coordinate
            
            var currentPlantId = ""
            var parameters: [String: Any] = [:]
            
            parameters["latitude"] = coordinate.latitude
            parameters["longitude"] = coordinate.longitude
            
            // Get plant data from overlay userdata
            if let data: [String: String] = currentOverlay.userData as? [String : String]{
                print(data)
                parameters["name"] = data["name"] ?? ""
                parameters["plant_type_id"] = data["type_id"] ?? ""
                currentPlantId = data["uniq_id"] ?? ""
                parameters["light_intensity"] = Double(data["light_intensity"] ?? "") ?? 0.0
                parameters["light_duration"] = Double(data["light_duration"] ?? "") ?? 0.0
                parameters["price"] = Double(data["price"] ?? "") ?? 0.0
                
                var lastWatered = data["last_watered"] ?? ""
                print(lastWatered)
                lastWatered = lastWatered.replacingOccurrences(of: " 00:00:00 GMT", with: "")
                lastWatered = lastWatered.replacingOccurrences(of: " 00:00:00", with: "")
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "E, d MMM yyyy"
                
                let originalDate = dateFormatter.date(from:lastWatered)!
                
                let dateFormatter2 = DateFormatter()
                dateFormatter2.dateFormat = "yyyy-MM-dd"
                var newDate = dateFormatter2.string(from: originalDate)
                newDate += " 00:00:00"
                
                print(newDate)
                parameters["last_watered"] = newDate
            }
            
            // Update plant data in database
            let url = URL(string: "http://192.81.216.18/api/v1/usergarden/\(self.userGarden.gardenId)/edit_plant/\(currentPlantId)/")!
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "PUT"

            let cookie = UserDefaults.standard.object(forKey: "login") as? String
            request.setValue(cookie, forHTTPHeaderField: "Cookie")
            
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
           } catch let error {
               print(error.localizedDescription)
           }
            
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                print(response ?? "")
            }
            task.resume()

            // Update overlay data coordinates
            var data = currentOverlay.userData as! [String: String]
            data["latitude"] = String(coordinate.latitude)
            data["longitude"] = String(coordinate.longitude)
            
            self.addPlantLabel.isHidden = true
        }
        else if (self.currentPlant != nil){
            let overlay = drawIcon(mapView: self.map, coordinate: coordinate, iconImage: currentPlant!.image)
            
            currentPlant?.geodata = GeoData(lat: coordinate.latitude, lon: coordinate.longitude)
            
            // Update plant data in database
            let url = URL(string: "http://192.81.216.18/api/v1/usergarden/\(self.userGarden.gardenId)/edit_plant/\(self.currentPlant!.userPlantId)/")!
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "PUT"
            print("check id \(self.currentPlant!.catalogPlantId)")

            let cookie = UserDefaults.standard.object(forKey: "login") as? String
            request.setValue(cookie, forHTTPHeaderField: "Cookie")
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            let date = df.string(from: Date()) + " 00:00:00"
            let parameters: [String: Any] = [
                "name": self.currentPlant!.name,
                "plant_type_id": self.currentPlant!.catalogPlantId,
                "latitude": self.currentPlant!.geodata.lat,
                "longitude": self.currentPlant!.geodata.lon,
                "light_intensity": self.currentPlant!.intensity,
                "light_duration": self.currentPlant!.duration,
                "price": self.currentPlant!.price,
                "last_watered": date
            ]
            print(parameters)
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
           } catch let error {
               print(error.localizedDescription)
           }
            
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                print(response ?? "")
            }
            task.resume()
            
            overlay.isTappable = true
            plantOverlays?.append(overlay)

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
                "light_intensity": String(0),
                "light_duration": String(0),
                "price": String(0)
            ]
            self.addPlantLabel.isHidden = true
            self.currentPlant = nil
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        // User tapped plant on map
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewGardenPlantVC = storyBoard.instantiateViewController(withIdentifier: "viewGardenPlantVC") as! viewGardenPlantVC
        viewGardenPlantVC.overlayDelegate = self
        viewGardenPlantVC.currentOverlay = overlay as? GMSGroundOverlay

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
