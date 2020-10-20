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


}
extension gardenGuides: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("hah")
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
