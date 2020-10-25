//
//  addPlantOptionsVC.swift
//  Green Thumb
//
//  Created by Megan Worrel on 10/24/20.
//

import UIKit

class addPlantOptionsVC: UIViewController {
    
    var userGarden: UserGarden!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addOwnPlantClicked(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let addPlantVC = storyBoard.instantiateViewController(withIdentifier: "addPlantVC") as! addPlantVC
        addPlantVC.userGarden = userGarden
        addPlantVC.returnDelegate = presentingViewController as? PlantReturnDelegate
        self.present(addPlantVC, animated: true, completion: nil)
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
