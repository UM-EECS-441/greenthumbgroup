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
    // Searchbar files
    var searching : Bool = false
    var searchedPlants = [["_id":["$oid":""], "name":"", "species":"", "tags": {},
                               "description": "", "days_to_water": 0,
                               "watering_description": ""]]
    
    var currentSort : String = "alphabetical"
    
    // Alphabetical Sort
    var sortedAlphabeticalKeys : [String] = []
    var plantsByAlphabetical = ["":[["_id":["$oid":""], "name":"", "species":"", "tags": {},
                     "description": "", "days_to_water": 0,
                     "watering_description": ""]]]
    // Plant Type Sort
    var sortedTypeKeys : [String] = []
    var plantsByType = ["":[["_id":["$oid":""], "name":"", "species":"", "tags": {},
                     "description": "", "days_to_water": 0,
                     "watering_description": ""]]]
    // Flower Color Sort
    var sortedFlowerColorKeys : [String] = []
    var plantsByFlowerColor = ["":[["_id":["$oid":""], "name":"", "species":"", "tags": {},
                     "description": "", "days_to_water": 0,
                     "watering_description": ""]]]
    // Zones Sort
    var sortedZoneKeys : [String] = []
    var plantsByZone = ["":[["_id":["$oid":""], "name":"", "species":"", "tags": {},
                     "description": "", "days_to_water": 0,
                     "watering_description": ""]]]
    // Special Features Sort
    var sortedFeatureKeys : [String] = []
    var plantsByFeature = ["":[["_id":["$oid":""], "name":"", "species":"", "tags": {},
                     "description": "", "days_to_water": 0,
                     "watering_description": ""]]]
    // Problem Solver Sort
    var sortedSolverKeys : [String] = []
    var plantsBySolver = ["":[["_id":["$oid":""], "name":"", "species":"", "tags": {},
                     "description": "", "days_to_water": 0,
                     "watering_description": ""]]]
    // Sun Solver Sort
    var sortedSunKeys : [String] = []
    var plantsBySun = ["":[["_id":["$oid":""], "name":"", "species":"", "tags": {},
                     "description": "", "days_to_water": 0,
                     "watering_description": ""]]]
    // Water Solver Sort
    var sortedWaterKeys : [String] = []
    var plantsByWater = ["":[["_id":["$oid":""], "name":"", "species":"", "tags": {},
                     "description": "", "days_to_water": 0,
                     "watering_description": ""]]]
    
    @IBOutlet var catalogTableView: UITableView!
    @IBOutlet var searchBar: UITableView!
    @IBOutlet var sortButton: UIBarButtonItem!
    var userGarden: UserGarden?
    
    weak var returnDelegate : PlantReturnDelegate?
    
    override func viewWillDisappear(_ animated: Bool) {
            // plants info page we don't end up getting scrolled all the way back to the top
            // preferable for consistent behavior
            searchBar.endEditing(true)
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Bar Button Menu
        let barButtonMenu = UIMenu(title: "Filter Options", children: [
            UIAction(title: NSLocalizedString("Sort by Name", comment: ""), image: UIImage(systemName: "a.book.closed"), handler: menuHandler),
            UIAction(title: NSLocalizedString("Sort by Plant Type", comment: ""), image: UIImage(systemName: "leaf"), handler: menuHandler),
            UIAction(title: NSLocalizedString("Sort by Lowest Zone", comment: ""), image: UIImage(systemName: "globe"), handler: menuHandler),
            UIAction(title: NSLocalizedString("Sort by Flower Color", comment: ""), image: UIImage(systemName: "paintpalette"), handler: menuHandler),
            UIAction(title: NSLocalizedString("Sort by Problem Solvers", comment: ""), image: UIImage(systemName: "lightbulb"), handler: menuHandler),
            UIAction(title: NSLocalizedString("Sort by Special Features", comment: ""), image: UIImage(systemName: "books.vertical"), handler: menuHandler),
            UIAction(title: NSLocalizedString("Sort by Light Reqs", comment: ""), image: UIImage(systemName: "sun.max"), handler: menuHandler),
            UIAction(title: NSLocalizedString("Sort by Days Between Watering", comment: ""), image: UIImage(systemName: "drop"), handler: menuHandler)
            
        ])
        
        sortButton.menu = barButtonMenu
//        sortButton.image = UIImage(systemName: "arrow.up.arrow.down")
        
        
        self.refreshControl = UIRefreshControl()
        self.catalogTableView.delegate = self
        self.catalogTableView.dataSource = self
        // setup refreshControl here later
        
        self.refreshControl?.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Getting plant library ...")
        
        self.refreshControl?.beginRefreshing()
        getPlants()
    }
    
    func menuHandler(action: UIAction) {
//        Swift.debugPrint("Menu handler: \(action.title)")
        print(action.title)
        if action.title == "Sort by Name" {
            if self.currentSort != "alphabetical" {
                self.currentSort = "alphabetical"
                tableView.reloadData();
                self.scrollToTop()
            }
        }
        else if action.title == "Sort by Plant Type" {
            if self.currentSort != "type" {
                self.currentSort = "type"
                tableView.reloadData();
                self.scrollToTop()
            }
        }
        else if action.title == "Sort by Flower Color" {
            if self.currentSort != "flowercolor" {
                self.currentSort = "flowercolor"
                tableView.reloadData();
                self.scrollToTop()
            }
        }
        else if action.title == "Sort by Special Features" {
            if self.currentSort != "features" {
                self.currentSort = "features"
                tableView.reloadData();
                self.scrollToTop()
            }
        }
        else if action.title == "Sort by Lowest Zone" {
            if self.currentSort != "zones" {
                self.currentSort = "zones"
                tableView.reloadData();
                self.scrollToTop()
            }
        }
        else if action.title == "Sort by Problem Solvers" {
            if self.currentSort != "solver" {
                self.currentSort = "solver"
                tableView.reloadData();
                self.scrollToTop()
            }
        }
        else if action.title == "Sort by Light Reqs" {
            if self.currentSort != "sun" {
                self.currentSort = "sun"
                tableView.reloadData();
                self.scrollToTop()
            }
        }
        else if action.title == "Sort by Days Between Watering" {
            if self.currentSort != "water" {
                self.currentSort = "water"
                tableView.reloadData();
                self.scrollToTop()
            }
        }
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
    
    
    func showToast(message : String, seconds: Double){
        // https://stackoverflow.com/questions/31540375/how-to-toast-message-in-swift
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = .white
        alert.view.alpha = 0.5
        alert.view.layer.cornerRadius = 15
        self.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }
     
    
    func scrollToTop() {
        // 1
        let topRow = IndexPath(row: 0,
                               section: 0)
                               
        // 2
        self.tableView.scrollToRow(at: topRow,
                                   at: .top,
                                   animated: true)
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
                let json = try JSONSerialization.jsonObject(with: data!) as! [[String:Any]]
                let sortedJSON = json.sorted {
                    //would throw an error if we ever have a null name pls dont
                    String($0["name"] as! String).lowercased() < String($1["name"] as! String).lowercased()
                }
                // Plants sorted alphabetically by name, one big array
                self.plants = sortedJSON
                
                
                // Using group function to turn them into [first letter of name : plant]
                let groupedAlphabeticalPlants = Dictionary(grouping: json, by: {
                    String($0["name"] as! String).prefix(1).uppercased()
                })
                self.sortedAlphabeticalKeys = groupedAlphabeticalPlants.keys.sorted()
                
                
                
                var duplicateNames = [String:Int]()
//                var groupedTypePlants = [String:[Any]]()
                // Manually grouping by type here because I don't know how to group when theres an array inside LOL ;_;
                // Two for loops is necessary for the name/species editing, otherwise
                // the first plant with the same name does not get species appended to its name
                // so the plant grouping for types and color has to be done in second loop after the name has been changed
                
                
                for (index, _) in self.plants.enumerated() {
                    // Editing names to have the species if duplicates
                    if let _ = duplicateNames[self.plants[index]["name"] as! String] {
                        // now val is not nil and the Optional has been unwrapped, so use it
                        duplicateNames[self.plants[index]["name"] as! String]! += 1
                    }
                    else {
                        duplicateNames[self.plants[index]["name"] as! String] = 0
                    }
                    // Editing names end
                    
                }
                
                
                for (index, _) in self.plants.enumerated() {
                    if duplicateNames[self.plants[index]["name"] as! String]! > 0 {
                        self.plants[index]["name"] =
                            self.plants[index]["name"] as! String + " (" +
                            String(self.plants[index]["species"] as! String) + ")"
                    }
                    let firstLetter = String(self.plants[index]["name"] as! String).prefix(1).uppercased()
                    if let _ = self.plantsByAlphabetical[firstLetter] {
                        self.plantsByAlphabetical[firstLetter]?.append(self.plants[index])
                    }
                    else {
                        self.plantsByAlphabetical[firstLetter] = []
                        self.plantsByAlphabetical[firstLetter]?.append(self.plants[index])
                    }
                    
                    // Grouping plants by water begin
                    
                    if let water : Int = self.plants[index]["days_to_water"] as? Int {
                        let new_water = String(water)
                        if let _ = self.plantsByWater[new_water] {
                            self.plantsByWater[new_water]?.append(self.plants[index])
                        }
                        else {
                            self.plantsByWater[new_water] = []
                            self.plantsByWater[new_water]?.append(self.plants[index])
                        }
                    }
                    // Grouping plants by water end
                    
                    // Grouping plants by type begin
                    let tags: [String: [String]] = self.plants[index]["tags"] as! [String: [String]]
                    let type_array: [String] = tags["plant type"]!
                    for type in type_array {
                        if let _ = self.plantsByType[type] {
                            // now val is not nil and the Optional has been unwrapped, so use it
                            self.plantsByType[type]?.append(self.plants[index])
                        }
                        else {
                            self.plantsByType[type] = []
                            self.plantsByType[type]?.append(self.plants[index])
                        }
                    }
                    // Grouping end
                    
                    // Grouping plants by flowercolor begin
//                    let flower_color_array: [String] = tags["flower color"]
                    if let flower_color_array: [String] = tags["flower color"] {
                        for color in flower_color_array {
                            if let _ = self.plantsByFlowerColor[color] {
                                self.plantsByFlowerColor[color]?.append(self.plants[index])
                            }
                            else {
                                self.plantsByFlowerColor[color] = []
                                self.plantsByFlowerColor[color]?.append(self.plants[index])
                            }
                        }
                    }
                    // Grouping plants by flowercolor end
                    
                    // Grouping plants by min zones begin
                    if let zone_array: [String] = tags["zones"] {
//                        let min_zone = zone_array.min {a,b in Int(a)! < Int(b)!}
                        let min_zone = zone_array[0]
                        let num = Int(min_zone)
                        // Check if its a number because some of the zones in the pulled data had random stuff in it
                        if num != nil {
                            if let _ = self.plantsByZone[min_zone] {
                                self.plantsByZone[min_zone]?.append(self.plants[index])
                            }
                            else {
                                self.plantsByZone[min_zone] = []
                                self.plantsByZone[min_zone]?.append(self.plants[index])
                            }
                        }
                    }
                    // Grouping plants by min zones end
                    
                    // Grouping plants by special features begin
                    
                    if let features_array: [String] = tags["special features"] {
                        for feature in features_array {
                            if let _ = self.plantsByFeature[feature] {
                                self.plantsByFeature[feature]?.append(self.plants[index])
                            }
                            else {
                                self.plantsByFeature[feature] = []
                                self.plantsByFeature[feature]?.append(self.plants[index])
                            }
                        }
                    }
                    // Grouping plants by special features end
                    
                    // Grouping plants by problem solver begin
                    
                    if let solve_array: [String] = tags["problem solvers"] {
                        for solve in solve_array {
                            if let _ = self.plantsBySolver[solve] {
                                self.plantsBySolver[solve]?.append(self.plants[index])
                            }
                            else {
                                self.plantsBySolver[solve] = []
                                self.plantsBySolver[solve]?.append(self.plants[index])
                            }
                        }
                    }
                    // Grouping plants by problem solver end
                    
                    // Grouping plants by sun begin
                    
                    if let sun_array: [String] = tags["light"] {
//                        print(sun_array)
                        for sun in sun_array {
                            if let _ = self.plantsBySun[sun] {
                                self.plantsBySun[sun]?.append(self.plants[index])
                            }
                            else {
                                self.plantsBySun[sun] = []
                                self.plantsBySun[sun]?.append(self.plants[index])
                            }
                        }
                    }
                    // Grouping plants by sun end
                    
                }
                // Don't know why "" ends up as an empty key but bonk and its gone
                self.plantsByType.removeValue(forKey: "")
                self.sortedTypeKeys = self.plantsByType.keys.sorted()
                
                
                self.plantsByFlowerColor.removeValue(forKey: "")
                self.sortedFlowerColorKeys = self.plantsByFlowerColor.keys.sorted()
                
                self.plantsByZone.removeValue(forKey: "")
                self.sortedZoneKeys = self.plantsByZone.keys.sorted(by: {
                    a,b in Int(a)! < Int(b)!
                })
                
                self.plantsByFeature.removeValue(forKey: "")
                self.sortedFeatureKeys = self.plantsByFeature.keys.sorted()
                
                self.plantsBySolver.removeValue(forKey: "")
                self.sortedSolverKeys = self.plantsBySolver.keys.sorted()
                
                self.plantsBySun.removeValue(forKey: "")
                self.sortedSunKeys = self.plantsBySun.keys.sorted()
                
                self.plantsByWater.removeValue(forKey: "")
                self.sortedWaterKeys = self.plantsByWater.keys.sorted()
                
                
//                print(self.plantsBySun)
//                print(self.plantsByWater)


                print(self.sortedSunKeys)
                print(self.sortedWaterKeys)
                
                
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
}
    // MARK:- TableView handlers
    
extension catalogVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("Tapped")
        // This line deselects the search bar so that when coming back from the
        // plants info page we don't end up getting scrolled all the way back to the top
        searchBar.endEditing(true)
        var selectedPlant : [String : Any] = ["_id":["$oid":""], "name":"", "species":"", "tags": {},
                             "description": "", "days_to_water": 0,
                             "watering_description": ""]
        if searching {
            selectedPlant = searchedPlants[indexPath.row]
        }
        else {
            if currentSort == "alphabetical" {
                selectedPlant = plantsByAlphabetical[sortedAlphabeticalKeys[indexPath.section]]![indexPath.row]
            }
            else if currentSort == "type" {
                selectedPlant = plantsByType[sortedTypeKeys[indexPath.section]]![indexPath.row]
            }
            else if currentSort == "flowercolor" {
                selectedPlant = plantsByFlowerColor[sortedFlowerColorKeys[indexPath.section]]![indexPath.row]
            }
            else if currentSort == "features" {
                selectedPlant = plantsByFeature[sortedFeatureKeys[indexPath.section]]![indexPath.row]
            }
            else if currentSort == "zones" {
                selectedPlant = plantsByZone[sortedZoneKeys[indexPath.section]]![indexPath.row]
            }
            else if currentSort == "solver" {
                selectedPlant = plantsBySolver[sortedSolverKeys[indexPath.section]]![indexPath.row]
            }
            else if currentSort == "sun" {
                selectedPlant = plantsBySun[sortedSunKeys[indexPath.section]]![indexPath.row]
            }
            else if currentSort == "water" {
                selectedPlant = plantsByWater[sortedWaterKeys[indexPath.section]]![indexPath.row]
            }
            else {
                selectedPlant = plants[indexPath.row]
            }
        }
        
        
        if self.presentingViewController?.title == "Map" {
            // Create plant for tap
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let addPlantVC = storyBoard.instantiateViewController(withIdentifier: "addPlantVC") as! addPlantVC
            addPlantVC.userGarden = userGarden
            addPlantVC.returnDelegate = self.returnDelegate

            var newPlant: UserPlant = UserPlant(catalogPlantId: self.plantsByAlphabetical[sortedAlphabeticalKeys[indexPath.section]]![indexPath.row]["_id"] as! String, gardenId: self.userGarden!.gardenId, name: self.plantsByAlphabetical[sortedAlphabeticalKeys[indexPath.section]]![indexPath.row]["name"] as! String)
            newPlant.image = self.plantsByAlphabetical[sortedAlphabeticalKeys[indexPath.section]]![indexPath.row]["image"] as? String ?? ""
            
            if searching {
                newPlant = UserPlant(catalogPlantId: self.searchedPlants[indexPath.row]["_id"] as! String, gardenId: self.userGarden!.gardenId, name: self.searchedPlants[indexPath.row]["name"] as! String)
                newPlant.image = self.searchedPlants[indexPath.row]["image"] as? String ?? ""
            }
            addPlantVC.currentPlant = newPlant
            self.present(addPlantVC, animated: true, completion: nil)
        }
        else{
            let catalogPage = storyboard?.instantiateViewController(identifier: "catalogPage") as? catalogPage
            
            let name = selectedPlant["name"]
            var nameString = "I been thru the desert on a plant with no name :("
            if case Optional<Any>.none = name {
                //nil
            } else {
                //not nil
                nameString = String(describing: name!)
                // getting rid of parenthesis for the plants that have species in name
                nameString = nameString.components(separatedBy: "(")[0]
            }

            
            let species = selectedPlant["species"]
            var speciesString = "No Species Available"
            if case Optional<Any>.none = species {
                //nil
            } else {
                //not nil
                speciesString = String(describing: species!)
            }
            

            let description = selectedPlant["description"]
            var descriptionString = "No Description Available"
            if case Optional<Any>.none = description {
                //nil
            } else {
                //not nil
                descriptionString = String(describing: description!)
            }
            
            let tags: [String: [String]] = selectedPlant["tags"] as! [String: [String]]
            var tagsString = ""
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
            let type_array: [Any] = tags["plant type"]!
            
            var typeString = "No Type Found"
            
            if case Optional<Any>.none = type_array {
                //nil
            } else {
                //not nil
//                typeString = String(describing: type_array![0])
                typeString = ""
                for type in type_array {
                    typeString += "\(type), "
                }
                typeString = String(typeString.dropLast(2))
            }
            
            let days_to_water = selectedPlant["days_to_water"]
            var days_to_water_String = ""
            if days_to_water is NSNull {
                //<null>
            }
            else {
                //not <null>
                print("days to water not nil")
                days_to_water_String = String(describing: days_to_water!)
            }
            
            
            
            
            catalogPage?.name = nameString
            catalogPage?.species = "Species: " + speciesString
            catalogPage?.type = (type_array.count > 1 ? ("Plant types: ") : ("Plant type: ")) + typeString
            catalogPage?.desc = descriptionString
            catalogPage?.tags = tagsString
            if days_to_water_String != "" {
                catalogPage?.waterDays = "Days until next watering: " + days_to_water_String
            }
            catalogPage?.id = selectedPlant["_id"] as! String

            
            
            
            self.navigationController?.pushViewController(catalogPage!, animated: true)
            
        }
    }
}

extension catalogVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        print("called searchbar function")
        if searchText == "" {
            searching = false
            tableView.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
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
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searching {
            return ""
        }
        else {
            if currentSort == "alphabetical" {
                return sortedAlphabeticalKeys[section]
            }
            else if currentSort == "type" {
                return sortedTypeKeys[section]
            }
            else if currentSort == "flowercolor" {
                return sortedFlowerColorKeys[section]
            }
            else if currentSort == "features" {
                return sortedFeatureKeys[section]
            }
            else if currentSort == "zones" {
                return sortedZoneKeys[section]
            }
            else if currentSort == "solver" {
                return sortedSolverKeys[section]
            }
            else if currentSort == "sun" {
                return sortedSunKeys[section]
            }
            else if currentSort == "water" {
                return sortedWaterKeys[section]
            }
            else {
                return ""
            }
        }
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        // Scrollbar text
        if searching {
            return [""]
        }
        else {
            if currentSort == "alphabetical" {
                return sortedAlphabeticalKeys
            }
            else if currentSort == "type" {
//                var shortenedKeys : [String] = []
//                for key in sortedTypeKeys {
//                    shortenedKeys.append(String(key.prefix(6)))
//                }
//                return shortenedKeys
                return sortedTypeKeys
            }
            else if currentSort == "flowercolor" {
                return sortedFlowerColorKeys
            }
            else if currentSort == "features" {
                return sortedFeatureKeys
            }
            else if currentSort == "zones" {
                return sortedZoneKeys
            }
            else if currentSort == "solver" {
                return sortedSolverKeys
            }
            else if currentSort == "sun" {
                return sortedSunKeys
            }
            else if currentSort == "water" {
                return sortedWaterKeys
            }
            else {
                return [""]
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if searching {
            return 1
        }
        else {
            if currentSort == "alphabetical" {
                return sortedAlphabeticalKeys.count // or sortedFirstLetters.count
            }
            else if currentSort == "type" {
                return sortedTypeKeys.count
            }
            else if currentSort == "flowercolor" {
                return sortedFlowerColorKeys.count
            }
            else if currentSort == "features" {
                return sortedFeatureKeys.count
            }
            else if currentSort == "zones" {
                return sortedZoneKeys.count
            }
            else if currentSort == "solver" {
                return sortedSolverKeys.count
            }
            else if currentSort == "sun" {
                return sortedSunKeys.count
            }
            else if currentSort == "water" {
                return sortedWaterKeys.count
            }
            else {
                return 1
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // how many rows per section
        if searching {
            return searchedPlants.count
        } else {
//            return plants.count
            if currentSort == "alphabetical" {
                return plantsByAlphabetical[sortedAlphabeticalKeys[section]]!.count
            }
            else if currentSort == "type" {
                return plantsByType[sortedTypeKeys[section]]!.count
            }
            else if currentSort == "flowercolor" {
                return plantsByFlowerColor[sortedFlowerColorKeys[section]]!.count
            }
            else if currentSort == "features" {
                return plantsByFeature[sortedFeatureKeys[section]]!.count
            }
            else if currentSort == "zones" {
                return plantsByZone[sortedZoneKeys[section]]!.count
            }
            else if currentSort == "solver" {
                return plantsBySolver[sortedSolverKeys[section]]!.count
            }
            else if currentSort == "sun" {
                return plantsBySun[sortedSunKeys[section]]!.count
            }
            else if currentSort == "water" {
                return plantsByWater[sortedWaterKeys[section]]!.count
            }
            else {
                return plants.count
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "catalogCell", for: indexPath) as! catalogCell
        
        var name : (Any)? = nil
        
        if searching {
            name = searchedPlants[indexPath.row]["name"]
        } else {
            if currentSort == "alphabetical" {
                name = plantsByAlphabetical[sortedAlphabeticalKeys[indexPath.section]]![indexPath.row]["name"]
            }
            else if currentSort == "type" {
                name = plantsByType[sortedTypeKeys[indexPath.section]]![indexPath.row]["name"]
            }
            else if currentSort == "flowercolor" {
                name = plantsByFlowerColor[sortedFlowerColorKeys[indexPath.section]]![indexPath.row]["name"]
            }
            else if currentSort == "features" {
                name = plantsByFeature[sortedFeatureKeys[indexPath.section]]![indexPath.row]["name"]
            }
            else if currentSort == "zones" {
                name = plantsByZone[sortedZoneKeys[indexPath.section]]![indexPath.row]["name"]
            }
            else if currentSort == "solver" {
                name = plantsBySolver[sortedSolverKeys[indexPath.section]]![indexPath.row]["name"]
            }
            else if currentSort == "sun" {
                name = plantsBySun[sortedSunKeys[indexPath.section]]![indexPath.row]["name"]
            }
            else if currentSort == "water" {
                name = plantsByWater[sortedWaterKeys[indexPath.section]]![indexPath.row]["name"]
            }
            else {
                name = plants[indexPath.row]["name"]
            }
        }
        let nameString = String(describing: name!)
        cell.textLabel?.text = nameString
        
        return cell
    }
}



