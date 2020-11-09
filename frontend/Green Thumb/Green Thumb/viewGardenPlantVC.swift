//
//  viewGardenPlantVC.swift
//  Green Thumb
//
//  Created by Megan Worrel on 10/29/20.
//

import UIKit
import SwiftyJSON

class viewGardenPlantVC: UIViewController {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var species: UILabel!
    
    var nameText = ""
    @IBOutlet weak var lightEstimation: UITextField!
    @IBOutlet weak var lastWateredPicker: UIDatePicker!
    var speciesText = ""
    var lastWatered = ""
    var lightEst = ""
    var id: String!
    @IBOutlet weak var lastWateredLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.name.text = nameText
        self.species.text = speciesText
        self.lightEstimation.text = lightEst
        self.lastWateredLabel.text = lastWatered
        
        // Get the plant data from catalogue
        let url = URL(string: "http://192.81.216.18/api/v1/usergarden/api/v1/catalog/\(self.id!)/")!
        
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
                print(json)
            }
            catch {
                print(error)
            }
        }
        
        task.resume()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func lightEstimationChanged(_ sender: Any) {
        // Potentially don't even need this
        self.lightEst = lightEstimation.text ?? ""
    }
    
    @IBAction func dateChanged(_ sender: Any) {
        let newLastWatered: Date = lastWateredPicker.date
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let date = df.string(from: newLastWatered)
        print(date)
        self.lastWatered = date
    }
    
    @IBAction func saveClicked(_ sender: UIButton) {
        // TODO: send changes to the backend
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
