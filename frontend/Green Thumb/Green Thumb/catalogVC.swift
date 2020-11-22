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
    var searchedPlants = [["_id":["$oid":""], "name":"", "species":"", "tags": {},
                               "description": "", "days_to_water": 0,
                               "watering_description": ""]]
    //    var SearchBarValue:String!
    var sortedKeys : [String] = []
    var searching : Bool = false
//    var sections : [String : [Any]] = [:]
    var sections = ["":[["_id":["$oid":""], "name":"", "species":"", "tags": {},
                     "description": "", "days_to_water": 0,
                     "watering_description": ""]]]
    
    @IBOutlet var catalogTableView: UITableView!
    @IBOutlet var searchBar: UITableView!
    var userGarden: UserGarden?
    
    weak var returnDelegate : PlantReturnDelegate?
    
    override func viewWillDisappear(_ animated: Bool) {
            // plants info page we don't end up getting scrolled all the way back to the top
            // preferable for consistent behavior
            searchBar.endEditing(true)
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        self.searchBar.showsCancelButton = false

                /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                /// programmatic implementation scrap code in case I do it through just that
        //        let searchController = UISearchController(searchResultsController: nil)
        //        // 1
        //        searchController.searchResultsUpdater = self
        //        // 2
        //        searchController.obscuresBackgroundDuringPresentation = false
        //        // 3
        //        searchController.searchBar.placeholder = "Search Plants"
        //        // 4
        ////        navigationItem.searchController = searchController
        //        tableView.tableHeaderView = searchController.searchBar
        //        // 5
        //        definesPresentationContext = true
        //
        //        var isSearchBarEmpty: Bool {
        //          return searchController.searchBar.text?.isEmpty ?? true
        //        }
                /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
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
                    String($0["name"] as! String).prefix(1).uppercased()
                })
//                print(groupedPlants)
                self.sortedKeys = groupedPlants.keys.sorted()
                
                self.plants = sortedJSON
                
                
                var duplicateNames = [String:Int]()
                
                for (index, _) in self.plants.enumerated() {
                    if let val = duplicateNames[self.plants[index]["name"] as! String] {
                        // now val is not nil and the Optional has been unwrapped, so use it
                        duplicateNames[self.plants[index]["name"] as! String]! += 1
//                        print(val + 1)
                    }
                    else {
                        duplicateNames[self.plants[index]["name"] as! String] = 0
                    }
                }
                
                for (index, _) in self.plants.enumerated() {
                    if duplicateNames[self.plants[index]["name"] as! String]! > 0 {
                        self.plants[index]["name"] =
                            self.plants[index]["name"] as! String + " (" +
                            String(self.plants[index]["species"] as! String) + ")"
                    }
                    let firstLetter = String(self.plants[index]["name"] as! String).prefix(1).uppercased()
                    if let val = self.sections[firstLetter] {
                        self.sections[firstLetter]?.append(self.plants[index])
                    }
                    else {
                        self.sections[firstLetter] = []
                        self.sections[firstLetter]?.append(self.plants[index])
                    }
//                    print(self.sections)
//                    print(String(self.plants[index]["name"] as! String).prefix(1))
//                    if let val = duplicateNames[self.plants[index]["name"] as! String] {
//                        // now val is not nil and the Optional has been unwrapped, so use it
//                        print(self.plants[index]["name"] as! String)
//                        self.plants[index]["name"] =
//                            self.plants[index]["name"] as! String + " (" +
//                            String(self.plants[index]["species"] as! String) + ")"
//                    }
//                    else {
////                        duplicateNames[self.plants[index]["name"] as! String] = true
//                    }
                }
                print(self.sections)
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
        // This line deselects the search bar so that when coming back from the
        // plants info page we don't end up getting scrolled all the way back to the top
        searchBar.endEditing(true)
        if self.presentingViewController?.title == "Map" {
            // Create plant for tap
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let addPlantVC = storyBoard.instantiateViewController(withIdentifier: "addPlantVC") as! addPlantVC
            addPlantVC.userGarden = userGarden
            addPlantVC.returnDelegate = self.returnDelegate
            // TODO: just add species here
            var newPlant: UserPlant = UserPlant(catalogPlantId: self.plants[indexPath.row]["_id"] as! String, gardenId: self.userGarden!.gardenId, name: self.searchedPlants[indexPath.row]["name"] as! String)
            if searching {
                newPlant = UserPlant(catalogPlantId: self.plants[indexPath.row]["_id"] as! String, gardenId: self.userGarden!.gardenId, name: self.searchedPlants[indexPath.row]["name"] as! String)
            }
            addPlantVC.currentPlant = newPlant
            self.present(addPlantVC, animated: true, completion: nil)
        }
        else{
            let catalogPage = storyboard?.instantiateViewController(identifier: "catalogPage") as? catalogPage
            
            var name = plants[indexPath.row]["name"]
            if searching {
                name = searchedPlants[indexPath.row]["name"]
            }
            var nameString = "I been thru the desert on a plant with no name :("
            if case Optional<Any>.none = name {
                //nil
            } else {
                //not nil
                nameString = String(describing: name!)
                nameString = nameString.components(separatedBy: "(")[0]
            }

            
            var species = plants[indexPath.row]["species"]
            if searching {
                species = searchedPlants[indexPath.row]["species"]
            }
            var speciesString = "No Species Available"
            if case Optional<Any>.none = species {
                //nil
            } else {
                //not nil
                speciesString = String(describing: species!)
            }
            

            var description = plants[indexPath.row]["description"]
            if searching {
                description = searchedPlants[indexPath.row]["description"]
            }
            var descriptionString = "No Description Available"
            if case Optional<Any>.none = description {
                //nil
            } else {
                //not nil
                descriptionString = String(describing: description!)
            }
            
    //        let tags = String(describing: plants[indexPath.row]["tags"])
            var tags: [String: [String]] = plants[indexPath.row]["tags"] as! [String: [String]]
            if searching {
                tags = searchedPlants[indexPath.row]["tags"] as! [String: [String]]
            }
            var tagsString = ""
    //        print(tags["plant type"])
            for (tag, items) in tags {
                if tag != "plant type" {
                    tagsString += "\(tag.capitalized): "
                    for item in items {
                        tagsString += "\(item), "
                    }
                    tagsString = String(tagsString.dropLast(2))
                    tagsString += "\n"
                }
            }
            print(tagsString)
            let type_array = tags["plant type"]
            
            var typeString = "No Type Found"
            
            if case Optional<Any>.none = type_array {
                //nil
            } else {
                //not nil
                typeString = String(describing: type_array![0])
            }
            
            var days_to_water = plants[indexPath.row]["days_to_water"]
            if searching {
                days_to_water = searchedPlants[indexPath.row]["days_to_water"]
            }
            var days_to_water_String = "N/A"
            if days_to_water is NSNull {
                //<null>
            }
            else {
                //not <null>
                print("days to water not nil")
                days_to_water_String = String(describing: days_to_water!)
            }
            
            var water_description = plants[indexPath.row]["watering_description"]
            if searching {
                water_description = searchedPlants[indexPath.row]["watering_description"]
            }
            var water_description_string = "No Watering Description Available"

            if water_description is NSNull {
                //<null>
            } else {
                //not <null>
                water_description_string = String(describing: water_description!)
            }
            
            
            
            catalogPage?.name = nameString
            catalogPage?.species = "Species: " + speciesString
            catalogPage?.type = "Plant type: " + typeString
            catalogPage?.desc = descriptionString
            catalogPage?.tags = tagsString
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

extension catalogVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        print("called searchbar function")
        if searchText == "" {
            searching = false
            tableView.reloadData()
        }
        else {
//            print(searchText.lowercased())
            searchedPlants = plants.filter({
                String($0["name"] as! String).lowercased().prefix(searchText.count) == searchText.lowercased()
            })
//            print(searchedPlants)
            searching = true
            tableView.reloadData()
        }
    }
}

extension catalogVC {
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if searching {
//            return ""
//        }
//        else {
//            return sortedKeys[section]
//        }
//    }
//
//    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
//        if searching {
//            return [""]
//        }
//        else {
//            return sortedKeys
//        }
//    }
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        if searching {
//            return 1
//        }
//        else {
//            return sortedKeys.count // or sortedFirstLetters.count
//        }
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // how many rows per section
        if searching {
            return searchedPlants.count
        } else {
            return plants.count
//            return sections[sortedKeys[section]]!.count
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "catalogCell", for: indexPath) as! catalogCell
        
        
        if searching {
            let name = searchedPlants[indexPath.row]["name"]
            let nameString = String(describing: name!)
            cell.textLabel?.text = nameString
        } else {
            let name = plants[indexPath.row]["name"]
            let nameString = String(describing: name!)
            cell.textLabel?.text = nameString
            
//            let name = sections[sortedKeys[indexPath.section]]![indexPath.row]["name"]
//            let nameString = String(describing: name!)
//            cell.textLabel?.text = nameString
        }
        
        
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



