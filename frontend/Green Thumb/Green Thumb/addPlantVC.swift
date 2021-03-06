//
//  addPlantVC.swift
//  Green Thumb
//
//  Created by Megan Worrel on 10/24/20.
//

import UIKit
import SwiftyJSON

class addPlantVC: UIViewController {

    @IBOutlet weak var plantImage: UIImageView!
    @IBOutlet weak var name: UITextField!
    
    var userGarden: UserGarden!
    var currentPlant: UserPlant!
    weak var returnDelegate : PlantReturnDelegate?
    var imageString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.name.text = currentPlant.name
        
        // get plant image
        // Get the plant data from catalogue
        let url = URL(string: "http://192.81.216.18/api/v1/catalog/\(self.currentPlant.catalogPlantId)/")!
        
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
                    //print(json)
                    self.imageString = json["image"].stringValue
                    self.plantImage.image = base64toImage(img: self.imageString)
                }
                catch {
                    print(error)
                }
            }
        }
        
        task.resume()
        
        self.imageString = currentPlant.image 
        if (self.imageString == ""){
            self.plantImage.image = UIImage(named: "planticon.png")
        } else {
            self.plantImage.image = base64toImage(img: self.imageString)
        }

        // Do any additional setup after loading the view.
    }
    
    @IBAction func doneButtonClicked(_ sender: UIButton) {
        // Add plant to database
        let url = URL(string: "http://192.81.216.18/api/v1/usergarden/\(userGarden.gardenId)/add_plant/")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
//        let delegate = UIApplication.shared.delegate as! AppDelegate
        let cookie = UserDefaults.standard.object(forKey: "login") as? String
        request.setValue(cookie, forHTTPHeaderField: "Cookie")
        print(cookie)
        print(Date())
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let date = df.string(from: Date()) + " 00:00:00"
        
        let parameters: [String: Any] = [
            "plant_type_id": self.currentPlant.catalogPlantId,
            "name": self.currentPlant.name ?? "",
            "latitude": -1,
            "longitude": -1,
            "price": 0,
            "light_intensity": 0,
            "light_duration": 0,
            "last_watered": date,
            "outdoors": true
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)

       } catch let error {
            print("json error")
           print(error.localizedDescription)
       }
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("no data")
                return
            }
            DispatchQueue.main.async {
                do {
                    print(response)
                    let json = try JSON(data: data, options: .allowFragments)
                    let plantId: String? = json["id"].stringValue
                    self.currentPlant.userPlantId = plantId ?? ""
                    self.returnDelegate?.didReturn(self.currentPlant)
                    // Go back to map
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                } catch {
                    print("error with response data")
                    print(error)
                }
            }
        }

        task.resume()
    }
    
    @IBAction func nameChanged(_ sender: Any) {
        if name.text != nil {
            self.currentPlant.name = name.text!
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// Generic return result delegate protocol
protocol PlantReturnDelegate: UIViewController {
    func didReturn(_ result: UserPlant)
}
