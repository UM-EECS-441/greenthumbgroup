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
    
    var nameText = ""
    @IBOutlet weak var lightEstimation: UITextField!
    @IBOutlet weak var lastWateredPicker: UIDatePicker!
    var speciesText = ""
    var lastWatered = ""
    var lightEst = ""
    var type_id: String!
    var uniq_id: String!
    var garden_id: String!
    var lat: Double!
    var lon: Double!
    @IBOutlet weak var lastWateredLabel: UILabel!
    var currentOverlay: GMSOverlay!
    
    var overlayDelegate: OverlayReturnDelegate!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.name.text = nameText
        self.species.text = speciesText
        self.lightEstimation.text = lightEst
        lastWatered = lastWatered.replacingOccurrences(of: " 00:00:00 GMT", with: "")
        lastWatered = lastWatered.replacingOccurrences(of: " 00:00:00", with: "")
        self.lastWateredLabel.text = lastWatered
        self.lastWateredPicker.datePickerMode = UIDatePicker.Mode.date

        
        
        // Get the plant data from catalogue
        let url = URL(string: "http://192.81.216.18/api/v1/catalog/\(self.type_id!)/")!
        
        var request = URLRequest(url: url)
        let delegate = UIApplication.shared.delegate as! AppDelegate
        request.setValue(delegate.cookie, forHTTPHeaderField: "Cookie")
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
    
    @IBAction func lightEstimationChanged(_ sender: Any) {
        self.lightEst = lightEstimation.text ?? ""
        print(self.lightEst)
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
    
    @IBAction func nameChanged(_ sender: Any) {
        self.nameText = name.text ?? ""
    }
    
    @IBAction func saveClicked(_ sender: UIButton) {
        // Update plant data in database
        let url = URL(string: "http://192.81.216.18/api/v1/usergarden/\(garden_id ?? "")/edit_plant/\(uniq_id ?? "")/")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PUT"
        let delegate = UIApplication.shared.delegate as! AppDelegate
        request.setValue(delegate.cookie, forHTTPHeaderField: "Cookie")
        let parameters: [String: Any] = [
            "plant_type_id": self.type_id ?? "",
            "name": self.nameText,
            "latitude": self.lat ?? 0,
            "longitude": self.lon ?? 0,
            "light_level": Double(self.lightEst) ?? -1,
            "last_watered": self.lastWatered
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
        
        var data = currentOverlay.userData as! [String: String]
        data["name"] = self.nameText
        data["light_level"] = self.lightEst
        
        let dfsave = DateFormatter()
        dfsave.dateFormat = "E, d MMM yyyy"
        let datesave = dfsave.string(from: self.lastWateredPicker.date) + " 00:00:00 GMT"
        
        data["last_watered"] = datesave
        
        currentOverlay.userData = data
        
        print(currentOverlay.userData)
        print(data)
        
        overlayDelegate.didReturnOverlay(currentOverlay);
        self.dismiss(animated: false, completion: nil)
    }
    
    

}

// Generic return result delegate protocol
protocol OverlayReturnDelegate: UIViewController {
    func didReturnOverlay(_ result: GMSOverlay)
}

