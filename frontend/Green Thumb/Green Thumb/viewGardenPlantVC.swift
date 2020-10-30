//
//  viewGardenPlantVC.swift
//  Green Thumb
//
//  Created by Megan Worrel on 10/29/20.
//

import UIKit

class viewGardenPlantVC: UIViewController {

    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var longitude: UILabel!
    var latText = ""
    var lonText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.latitude.text = latText
        self.longitude.text = lonText

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
