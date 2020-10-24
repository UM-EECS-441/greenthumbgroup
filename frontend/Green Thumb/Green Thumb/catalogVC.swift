//
//  catalogVC.swift
//  Green Thumb
//
//  Created by Joe Riggs on 10/24/20.
//


import UIKit

class MainVC: UITableViewController {
    
    var plants = [CatalogPlant]()  // array of Chatt

    override func viewDidLoad() {
        super.viewDidLoad()

        // setup refreshControl here later
        refreshControl?.addTarget(self, action: #selector(MainVC.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        getPlants()
    }
    
    func base64toImage(img: String) -> UIImage? {
        if (img == "") {
          return nil
        }
        let dataDecoded : Data = Data(base64Encoded: img, options: .ignoreUnknownCharacters)!
        let decodedimage = UIImage(data: dataDecoded)
        return decodedimage!
    }
    
    // MARK:- TableView handlers
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // how many sections are in table
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // how many rows per section
        return plants.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // event handler when a cell is tapped
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // populate a single cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "catalogTableCell", for: indexPath) as? catalogTableCell else {
            fatalError("No reusable cell!")
        }
        
        let plant = plants[indexPath.row]
        cell.plantName.text = plant.plantName
        cell.plantName.sizeToFit()
        if (plant.plantImage != "") {
            let img = UIImage(data: Data(base64Encoded: plant.plantImage, options: .ignoreUnknownCharacters)!)!
            cell.plantImage?.image = img.resizeImage(targetSize: CGSize(width: 150, height: 181))
        } else {
            cell.plantImage?.image = nil
        }
        return cell
    }
    // MARK:-
    func getPlants() {
//        Update request URL
        let requestURL = "https://digitaloceanIP/getcatalog/"
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
                self.plants = [CatalogPlant]()
                let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                let plantsReceived = json["plants"] as? [[String]] ?? []
                for plantEntry in plantsReceived {
                    let plant = CatalogPlant(plantName: plantEntry[1], plantImage: chattEntry[5])
                    self.plants += [plant]
                }
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
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        getPlants()
    }
}

