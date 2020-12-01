//
//  catalogPage.swift
//  Green Thumb
//
//  Created by Joe Riggs on 10/27/20.
//

import UIKit

class catalogPage: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var plantName: UILabel!
    @IBOutlet weak var plantSpecies: UILabel!
    @IBOutlet weak var plantType: UILabel!
    @IBOutlet weak var plantDescription: UILabel!
    @IBOutlet weak var plantTags: UILabel!
    @IBOutlet weak var daysTilWater: UILabel!
    @IBOutlet weak var plantWaterInfo: UILabel!
    
    var name = "Plant"
    var species = "Species"
    var type = "Type"
    var desc = "Description"
    var tags = ""
    var waterDays = ""
    var waterInfo = ""
    var id = ""
    
    @IBOutlet weak var plantImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: plantWaterInfo.bottomAnchor).isActive = true
        
        plantName.text = name
        plantSpecies.text = species
        plantType.text = type
        plantDescription.text = desc
        // Not done yet
        plantTags.numberOfLines = 0
        plantTags.text = tags
        daysTilWater.text = waterDays
        plantWaterInfo.text = waterInfo
        
        getImage()
        
    }
    
    func getImage() {
        let requestURL = "http://192.81.216.18/api/v1/catalog/\(self.id)"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {
                print("NETWORKING ERROR")
                DispatchQueue.main.async {
    //              self.refreshControl?.endRefreshing()
                }
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("HTTP STATUS: \(httpStatus.statusCode)")
                DispatchQueue.main.async {
    //              self.refreshControl?.endRefreshing()
                }
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
//                self.base64ImageString = json["image"] as! String
                let base64ImageString = json["image"] as! String
                
                DispatchQueue.main.async {
                    self.plantImage.image = base64toImage(img: base64ImageString)
                    self.plantImage.layer.cornerRadius = 20.0
                    self.plantImage.layer.masksToBounds = true
                }
            } catch let error as NSError {
                print(error)
            }
        }
        task.resume()
    }
}

func base64toImage(img: String) -> UIImage? {
    if (img == "") {
      return nil
    }
    let dataDecoded : Data = Data(base64Encoded: img, options: .ignoreUnknownCharacters)!
    let decodedimage = UIImage(data: dataDecoded)
    return decodedimage!
}
