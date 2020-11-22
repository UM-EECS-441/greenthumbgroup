//
//  gardensTableVC.swift
//  Green Thumb
//
//  Created by Megan Worrel on 10/24/20.
//

import UIKit
import SwiftyJSON

class gardensTableVC: UITableViewController, ReturnDelegate {
    
    @IBOutlet var gardens: UITableView!
    var gardenArray = [UserGarden]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get user's gardens
        let url = URL(string: "http://192.81.216.18/api/v1/usergarden/")!
        
        var request = URLRequest(url: url)
//        let delegate = UIApplication.shared.delegate as! AppDelegate
        let cookie = UserDefaults.standard.object(forKey: "login") as? String
        request.setValue(cookie, forHTTPHeaderField: "Cookie")
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            print(response)
            print(data)
            guard let data = data else {
                return
            }
            do{
                let json = try JSON(data: data).array
                if let gardens = json{
                    for garden in gardens {
                        let newGarden = UserGarden(gardenId: garden["_id"]["$oid"].stringValue, name: garden["name"].stringValue, address: garden["address"].stringValue)
                        newGarden.brGeoData = GeoData(lat: Double(garden["bottomright_lat"].stringValue) ?? -1, lon: Double(garden["bottomright_long"].stringValue) ?? -1)
                        newGarden.tlGeoData = GeoData(lat: Double(garden["topleft_lat"].stringValue) ?? -1, lon: Double(garden["topleft_long"].stringValue) ?? -1)

                        self.gardenArray.append(newGarden)
                    }
                    
                    print(json)
                }
                
                DispatchQueue.main.async{
                    self.tableView.reloadData()
                }
            }
            catch {
                print(error)
            }
            
        }
        
        task.resume()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    //need to make sure this is working or whatever
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mapVC = storyboard?.instantiateViewController(withIdentifier: "mapVC") as! mapVC
        mapVC.userGarden = self.gardenArray[indexPath.row]
        self.present(mapVC, animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.gardenArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gardenCell", for: indexPath) as! gardenCell

        // Configure the cell...
        cell.address = self.gardenArray[indexPath.row].address
        cell.name.text = self.gardenArray[indexPath.row].name
        if let gardenImage = cell.gardenImage.image {
            self.gardenArray[indexPath.row].image = gardenImage
        }
        
        cell.mapClickAction = { () in
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let mapVC = storyBoard.instantiateViewController(withIdentifier: "mapVC") as! mapVC
            mapVC.userGarden = self.gardenArray[indexPath.row]
            self.present(mapVC, animated: true, completion: nil)
        }
        
        return cell
    }
    
    func didReturn(_ result: UserGarden) {
        gardenArray.append(result)
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let addGardenVC = segue.destination as? addGardenVC
        addGardenVC?.returnDelegate = self
    }
    

}
