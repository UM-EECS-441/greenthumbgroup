//
//  viewGardenPlantVC.swift
//  Green Thumb
//
//  Created by Megan Worrel on 10/29/20.
//

import UIKit
import SwiftyJSON
import GoogleMaps

class viewGardenPlantVC: UIViewController {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var species: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    var nameText = ""
    var speciesText = ""
    var lastWatered = ""
    var intensity = 0.0
    var duration = 0.0
    var type_id = ""
    var uniq_id = ""
    var garden_id = ""
    var lat = 0.0
    var lon = 0.0
    var priceInput = 0.0
    var imageString = ""
    var outdoors = true

    
    @IBOutlet weak var lightIntensity: UITextField!
    @IBOutlet weak var lightDuration: UITextField!
    @IBOutlet weak var price: UITextField!
    @IBOutlet weak var lastWateredPicker: UIDatePicker!
    
    var currentOverlay: GMSGroundOverlay!
    
    var overlayDelegate: OverlayReturnDelegate!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(currentOverlay.userData!)
        
        if let data: [String: String] = currentOverlay.userData as? [String : String]{
            print(data)
            self.nameText = data["name"] ?? ""
            self.uniq_id = data["uniq_id"] ?? ""
            self.type_id = data["type_id"] ?? ""
            self.garden_id = data["garden_id"] ?? ""
            self.lat = Double(data["lat"] ?? "") ?? -1
            self.lon = Double(data["lon"] ?? "") ?? -1
            self.intensity = Double(data["light_intensity"] ?? "") ?? 0.0
            self.duration = Double(data["light_duration"] ?? "") ?? 0.0
            self.priceInput = Double(data["price"] ?? "") ?? 0.0
            self.lastWatered = data["last_watered"] ?? ""
            self.imageString = data["image"] ?? "planticon.png"
            self.outdoors = Bool(data["outdoors"] ?? "") ?? true
        }
        
        self.name.text = nameText
        self.species.text = speciesText
        
        let imageData : Data = Data(base64Encoded: self.imageString, options: .ignoreUnknownCharacters)!
        print(imageData)
        self.image.image = UIImage(data: imageData)
        
        // Initialize last watered date
        lastWatered = lastWatered.replacingOccurrences(of: " 00:00:00 GMT", with: "")
        lastWatered = lastWatered.replacingOccurrences(of: " 00:00:00", with: "")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy"
        let date = dateFormatter.date(from:lastWatered)!
        self.lastWateredPicker.datePickerMode = UIDatePicker.Mode.date
        self.lastWateredPicker.date = date
        
        self.lightIntensity.text = String(self.intensity)
        
        self.lightDuration.text = String(self.duration)
        
        self.price.text = String(self.priceInput)
        
        // Get the plant data from catalogue
        let url = URL(string: "http://192.81.216.18/api/v1/catalog/\(self.type_id)/")!
        
        var request = URLRequest(url: url)

        let cookie = UserDefaults.standard.object(forKey: "login") as? String
        request.setValue(cookie, forHTTPHeaderField: "Cookie")
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            print(response ?? "")
            //print(data)
            DispatchQueue.main.async {
                guard let data = data else {
                    return
                }
                do{
                    let json = try JSON(data: data)
                    print(json)
                    self.species.text = json["species"].stringValue
                }
                catch {
                    print(error)
                }
            }
        }
        
        task.resume()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func dateChanged(_ sender: Any) {
        let newLastWatered: Date = lastWateredPicker.date
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        var date = df.string(from: newLastWatered)
        date += " 00:00:00"
        print(date)
        self.lastWatered = date
    }
    
    @IBAction func lightIntensityChanged(_ sender: Any) {
        self.intensity = Double(lightIntensity.text ?? "") ?? 0.0
    }
    
    @IBAction func lightDurationChanged(_ sender: Any) {
        self.duration = Double(lightDuration.text ?? "") ?? 0.0
    }
    
    @IBAction func nameChanged(_ sender: Any) {
        self.nameText = name.text ?? ""
    }
    
    @IBAction func priceChanged(_ sender: Any) {
        self.priceInput = Double(price.text ?? "") ?? 0.0
    }
    
    @IBAction func deleteClicked(_ sender: Any) {
        overlayDelegate.didReturnOverlay(currentOverlay, true, false);
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func moveClicked(_ sender: Any) {
        overlayDelegate.didReturnOverlay(currentOverlay, false, true);
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func saveClicked(_ sender: UIButton) {
        // Update plant data in database
        let url = URL(string: "http://192.81.216.18/api/v1/usergarden/\(garden_id )/edit_plant/\(uniq_id )/")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PUT"
//        let delegate = UIApplication.shared.delegate as! AppDelegate
        let cookie = UserDefaults.standard.object(forKey: "login") as? String
        request.setValue(cookie, forHTTPHeaderField: "Cookie")
        let parameters: [String: Any] = [
            "plant_type_id": self.type_id,
            "name": self.nameText,
            "latitude": self.lat,
            "longitude": self.lon,
            "light_intensity": self.intensity,
            "light_duration": self.duration,
            "price": self.priceInput,
            "last_watered": self.lastWatered,
            "outdoors": self.outdoors
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
        
        var data = currentOverlay.userData as! [String: String]
        data["name"] = self.nameText
        data["light_intensity"] = String(self.intensity)
        data["light_duration"] = String(self.duration)
        data["price"] = String(self.priceInput)
        
        let dfsave = DateFormatter()
        dfsave.dateFormat = "E, d MMM yyyy"
        let datesave = dfsave.string(from: self.lastWateredPicker.date) + " 00:00:00 GMT"
        
        data["last_watered"] = datesave
        
        currentOverlay.userData = data
        
        print(currentOverlay.userData!)
        print(data)
        
        overlayDelegate.didReturnOverlay(currentOverlay, false, false);
        self.dismiss(animated: false, completion: nil)
    }
    
    

}

// Generic return result delegate protocol
protocol OverlayReturnDelegate: UIViewController {
    func didReturnOverlay(_ result: GMSGroundOverlay, _ delete: Bool, _ move: Bool)
}

