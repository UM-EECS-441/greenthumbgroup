//
//  gardenGuides.swift
//  Green Thumb
//
//  Created by Tiger Shi on 10/20/20.
//

import UIKit

class gardenGuides: UIViewController {

    @IBOutlet var guideView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        guideView.delegate = self
        guideView.dataSource = self
    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "guideSegue" {
//            // Setup new view controller
//        }
//    }


}
extension gardenGuides: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("hah")
//        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//        let destination = storyboard.instantiateViewController(withIdentifier: "thisGuide")
//        navigationController?.pushViewController(destination, animated: true)
        
//        performSegue(withIdentifier: "guideSegue", sender: self)

        

//        print("hah2")
    }
}


extension gardenGuides: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "guideCell", for: indexPath)
        
        cell.textLabel?.text = "Guide " + String(indexPath.row)
        
        return cell
    }
}
