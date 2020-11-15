//
//  catalogVC.swift
//  Green Thumb
//
//  Created by Joe Riggs on 10/24/20.
//


import UIKit
import SwiftyJSON

class catalogVC: UITableViewController {
    
    var plants = [["_id":["$oid":""], "name":"", "species":"", "tags": {},
                   "description": "", "days_to_water": 0,
                   "watering_description": ""]]  // array of Plants
    
    @IBOutlet var catalogTableView: UITableView!
    var userGarden: UserGarden?
    
    weak var returnDelegate : PlantReturnDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.catalogTableView.delegate = self
        self.catalogTableView.dataSource = self
        // setup refreshControl here later
        
        self.refreshControl?.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Getting plant library ...")
        
        self.refreshControl?.beginRefreshing()
        getPlants()
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.refreshControl?.beginRefreshing()
        getPlants()
//        run(after: 0.5) {
//            self.refreshControl?.endRefreshing()
//            DispatchQueue.main.async { self.catalogTableView.reloadData() }
//        }
    }
    //    https://guides.codepath.com/ios/Using-UIRefreshControl
    func run(after wait: TimeInterval, closure: @escaping () -> Void) {
        let queue = DispatchQueue.main
        queue.asyncAfter(deadline: DispatchTime.now() + wait, execute: closure)
    }
    
    func getPlants() {
        let requestURL = "http://192.81.216.18/api/v1/catalog/"
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {
                print("NETWORKING ERROR")
                DispatchQueue.main.async {
                  self.refreshControl?.endRefreshing()
                }
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("HTTP STATUS: \(httpStatus.statusCode)")
                DispatchQueue.main.async {
                  self.refreshControl?.endRefreshing()
                }
                return
            }
            
            do {
//                self.plants = [CatalogPlant]()
                let json = try JSONSerialization.jsonObject(with: data!) as! [[String:Any]]
                //sorted
                let sortedJSON = json.sorted {
                    //would throw an error if we ever have a null name pls dont
                    String($0["name"] as! String).lowercased() < String($1["name"] as! String).lowercased()
                }
                let groupedPlants = Dictionary(grouping: json, by: {
                    String($0["name"] as! String).prefix(1).lowercased()
                })
                
                let keys = groupedPlants.keys.sorted()
                
                self.plants = sortedJSON
//                self.plants = groupedSortedPlants
                
                DispatchQueue.main.async {
                  self.tableView.estimatedRowHeight = 140
                  self.tableView.rowHeight = UITableView.automaticDimension
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                }
            } catch let error as NSError {
                print(error)
            }
        }
        task.resume()
    }
//    func base64toImage(img: String) -> UIImage? {
//        if (img == "") {
//          return nil
//        }
//        let dataDecoded : Data = Data(base64Encoded: img, options: .ignoreUnknownCharacters)!
//        let decodedimage = UIImage(data: dataDecoded)
//        return decodedimage!
//    }
}
    // MARK:- TableView handlers
    
extension catalogVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("Tapped")
        if self.presentingViewController?.title == "Add Plant Options" {
            // Create plant for tap, add to database, and return using delegate
            // Add plant to database
            let url = URL(string: "http://192.81.216.18/api/v1/usergarden/\(userGarden!.gardenId)/add_plant/")!
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            
            let delegate = UIApplication.shared.delegate as! AppDelegate
            request.setValue(delegate.cookie, forHTTPHeaderField: "Cookie")

            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd hh:mm:ss"
            let date = df.string(from: Date())
            print(plants[indexPath.row])
            print("id \(plants[indexPath.row]["_id"])")
            let parameters: [String: Any] = [
                "plant_type_id": plants[indexPath.row]["_id"] ?? "",
                "latitude": -1,
                "longitude": -1,
                "light_level": -1,
                "last_watered": date
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
                        let plantId = json["id"].stringValue
                        print("plantid \(plantId)")
                        // TODO: don't force unwrap
                        let newPlant: UserPlant = UserPlant(userPlantId: plantId, gardenId: self.userGarden!.gardenId, name: self.plants[indexPath.row]["name"] as! String, image: UIImage(named: "planticon.png")!)
                        newPlant.catalogPlantId = self.plants[indexPath.row]["_id"] as! String
                        self.returnDelegate?.didReturn(newPlant)
                        self.dismiss(animated: true, completion: nil)
                    } catch {
                        print("error with response data")
                        print(error)
                    }
                }
            }

            task.resume()
            self.dismiss(animated: true, completion: nil)
        }
        else{
            let catalogPage = storyboard?.instantiateViewController(identifier: "catalogPage") as? catalogPage
            
            let name = plants[indexPath.row]["name"]
            var nameString = "I been thru the desert on a plant with no name :("
            if case Optional<Any>.none = name {
                //nil
            } else {
                //not nil
                nameString = String(describing: name!)
            }

            let species = plants[indexPath.row]["species"]
            var speciesString = "No Species Available"
            if case Optional<Any>.none = species {
                //nil
            } else {
                //not nil
                speciesString = String(describing: species!)
            }
            
            let description = plants[indexPath.row]["description"]
            var descriptionString = "No Description Available"
            if case Optional<Any>.none = description {
                //nil
            } else {
                //not nil
                descriptionString = String(describing: description!)
            }
            
    //        let tags = String(describing: plants[indexPath.row]["tags"])
            let tags: [String: [String]] = plants[indexPath.row]["tags"] as! [String: [String]]
    //        print(tags["plant type"])
            let height_array = tags["height"]
            let light_array = tags["light"]
            let type_array = tags["plant type"]
            
    //        var heightString = "No Height Found"
    //        var lightString = "No Light Found"
            var typeString = "No Type Found"
            
            if case Optional<Any>.none = type_array {
                //nil
            } else {
                //not nil
                typeString = String(describing: type_array![0])
            }
    //        print(typeString)
            
    //        print(height_array)
    //        print(light_array)
    //        print(type_array)
            
            let days_to_water = plants[indexPath.row]["days_to_water"]
            var days_to_water_String = "N/A"
            if days_to_water is NSNull {
                //<null>
            }
            else {
                //not <null>
                print("days to water not nil")
                days_to_water_String = String(describing: days_to_water!)
            }
            
            let water_description = plants[indexPath.row]["watering_description"]
            var water_description_string = "No Watering Description Available"
            if water_description is NSNull {
                //<null>
            } else {
                //not <null>
                water_description_string = String(describing: water_description!)
            }
            
            
            // currently not working in backend
            //days_to_water
            //watering_description
            
            catalogPage?.name = nameString
            catalogPage?.species = "Species: " + speciesString
            catalogPage?.type = "Plant type: " + typeString
            catalogPage?.desc = descriptionString
            //
            catalogPage?.tags = "No Tags for this Plant"
            if days_to_water_String == "N/A" {
                catalogPage?.waterDays = ""
            }
            else {
                catalogPage?.waterDays = "Days until next watering: " + days_to_water_String
            }
            catalogPage?.waterInfo = water_description_string
            
            
            self.navigationController?.pushViewController(catalogPage!, animated: true)
    //        performSegue(withIdentifier: "guideSegue", sender: self)

        }
        }
}

extension catalogVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // how many rows per section
        return plants.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "catalogCell", for: indexPath) as! catalogCell
        
        
        let name = plants[indexPath.row]["name"]
        let nameString = String(describing: name!)
        cell.textLabel?.text = nameString
        
        
        return cell
    }
}
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // how many sections are in table
//        return 1
//    }
//

//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        // event handler when a cell is tapped
//        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
//    }
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        // populate a single cell
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "catalogTableCell", for: indexPath) as? catalogTableCell else {
//            fatalError("No reusable cell!")
//        }
//
//        let plantName = plants[indexPath.row]["name"]
//        let nameString = String(describing: plantName!)
//        cell.plantName.text = nameString
//        cell.plantName.sizeToFit()
////        if (plant.plantImage != "") {
////            let img = UIImage(data: Data(base64Encoded: plant.plantImage, options: .ignoreUnknownCharacters)!)!
////            cell.plantImage?.image = img.resizeImage(targetSize: CGSize(width: 150, height: 181))
////
////        } else {
////            cell.plantImage?.image = nil
////        }
//
//        return cell
//    }
//



