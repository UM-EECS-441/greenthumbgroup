//
//  catalogVC.swift
//  Green Thumb
//
//  Created by Joe Riggs on 10/24/20.
//


import UIKit

class catalogVC: UITableViewController {
    
    var plants = [["_id":["$oid":""], "name":"", "species":"", "tags": {},
                   "description": "", "days_to_water": 0,
                   "watering_description": ""]]  // array of Plants
    
    @IBOutlet var catalogTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.catalogTableView.delegate = self
        self.catalogTableView.dataSource = self
        // setup refreshControl here later
        refreshControl?.addTarget(self, action: #selector(catalogVC.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        getPlants()
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        getPlants()
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
                self.plants = json
                
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
        print("Tapped")
        let catalogPage = storyboard?.instantiateViewController(identifier: "catalogPage") as? catalogPage
        
        let name = plants[indexPath.row]["name"]
        let nameString = String(describing: name!)
        
        let species = plants[indexPath.row]["species"]
        let speciesString = String(describing: species!)
        
        let type = plants[indexPath.row]["type"]
        let typeString = String(describing: type!)
        
        let description = plants[indexPath.row]["description"]
        let descriptionString = String(describing: description!)
       
        
        
        catalogPage?.name = nameString
        catalogPage?.species = speciesString
        catalogPage?.type = typeString
        catalogPage?.desc = descriptionString
        
        
        self.navigationController?.pushViewController(catalogPage!, animated: true)
//        performSegue(withIdentifier: "guideSegue", sender: self)

    }
}

extension catalogVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // how many rows per section
        return plants.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "catalogTableCell", for: indexPath)
        
        
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



