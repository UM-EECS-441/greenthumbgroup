//
//  gardensTableVC.swift
//  Green Thumb
//
//  Created by Megan Worrel on 10/24/20.
//

import UIKit

class gardensTableVC: UITableViewController, ReturnDelegate {
    
    @IBOutlet var gardens: UITableView!
    var gardenArray = [UserGarden]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
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
