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
    
    // Sort toggle, very cool!
    let sortToggle : [String:String] = ["alphabetical":"type",
                                        "type":"flowercolor",
                                        "flowercolor":"alphabetical"]
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
    
    @IBAction func changeSort(_ sender: Any) {
//        print("switching from", currentSort, "sort to", sortToggle[currentSort]!);
        currentSort = sortToggle[currentSort]!;
        if currentSort == "alphabetical" {
//            self.title = "Sorting by Name"
            showToast(message: "Now Sorting by Name", seconds: 0.3)
        }
        else if currentSort == "type" {
//            self.title = "Sorting by Plant Type"
            showToast(message: "Now Sorting by Plant Type", seconds: 0.3)
        }
        else if currentSort == "flowercolor" {
//            self.title = "Sorting by Flower Color"
            showToast(message: "Now Sorting by Flower Color", seconds: 0.3)
        }
        tableView.reloadData();
        self.scrollToTop()
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
                
//                print(self.sortedTypeKeys)
                
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
                }
                // Don't know why "" ends up as an empty key but bonk and its gone
                self.plantsByType.removeValue(forKey: "")
                self.sortedTypeKeys = self.plantsByType.keys.sorted()
                
//                print(self.sections)
//                self.plants = groupedSortedPlants
                
                self.plantsByFlowerColor.removeValue(forKey: "")
                self.sortedFlowerColorKeys = self.plantsByFlowerColor.keys.sorted()
//                print(self.sortedFlowerColorKeys)
                
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
            // TODO: just add species here

//            var newPlant: UserPlant = UserPlant(catalogPlantId: self.plants[indexPath.row]["_id"] as! String, gardenId: self.userGarden!.gardenId, name: self.plants[indexPath.row]["name"] as! String)
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
//            if searching {
//                name = selectedPlant["name"]
//            }
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
//            if searching {
//                species = selectedPlant["species"]
//            }
            var speciesString = "No Species Available"
            if case Optional<Any>.none = species {
                //nil
            } else {
                //not nil
                speciesString = String(describing: species!)
            }
            

            let description = selectedPlant["description"]
//            if searching {
//                description = selectedPlant["description"]
//            }
            var descriptionString = "No Description Available"
            if case Optional<Any>.none = description {
                //nil
            } else {
                //not nil
                descriptionString = String(describing: description!)
            }
            
    //        let tags = String(describing: plants[indexPath.row]["tags"])
            let tags: [String: [String]] = selectedPlant["tags"] as! [String: [String]]
//            if searching {
//                tags = selectedPlant["tags"] as! [String: [String]]
//            }
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
//            print(tagsString)
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
//            if searching {
//                days_to_water = selectedPlant["days_to_water"]
//            }
            var days_to_water_String = "N/A"
            if days_to_water is NSNull {
                //<null>
            }
            else {
                //not <null>
                print("days to water not nil")
                days_to_water_String = String(describing: days_to_water!)
            }
            
            let water_description = selectedPlant["watering_description"]
//            if searching {
//                water_description = selectedPlant["watering_description"]
//            }
            var water_description_string = "No Watering Description Available"

            if water_description is NSNull {
                //<null>
            } else {
                //not <null>
                water_description_string = String(describing: water_description!)
            }
            
            
            
            catalogPage?.name = nameString
            catalogPage?.species = "Species: " + speciesString
            catalogPage?.type = (type_array.count > 1 ? ("Plant types: ") : ("Plant type: ")) + typeString
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
            else {
                return plants.count
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "catalogCell", for: indexPath) as! catalogCell
        
        
        if searching {
            let name = searchedPlants[indexPath.row]["name"]
            let nameString = String(describing: name!)
            cell.textLabel?.text = nameString
        } else {
//            let name = plants[indexPath.row]["name"]
//            let nameString = String(describing: name!)
//            cell.textLabel?.text = nameString
            if currentSort == "alphabetical" {
                let name = plantsByAlphabetical[sortedAlphabeticalKeys[indexPath.section]]![indexPath.row]["name"]
                let nameString = String(describing: name!)
                cell.textLabel?.text = nameString
            }
            else if currentSort == "type" {
                let name = plantsByType[sortedTypeKeys[indexPath.section]]![indexPath.row]["name"]
                let nameString = String(describing: name!)
                cell.textLabel?.text = nameString
            }
            else if currentSort == "flowercolor" {
                let name = plantsByFlowerColor[sortedFlowerColorKeys[indexPath.section]]![indexPath.row]["name"]
                let nameString = String(describing: name!)
                cell.textLabel?.text = nameString
            }
            else {
                let name = plants[indexPath.row]["name"]
                let nameString = String(describing: name!)
                cell.textLabel?.text = nameString
            }
        }
        
        
        return cell
    }
}



