//
//  addPlantVC.swift
//  Green Thumb
//
//  Created by Megan Worrel on 10/24/20.
//

import UIKit

class addPlantVC: UIViewController {

    @IBOutlet weak var plantImage: UIImageView!
    @IBOutlet weak var name: UITextView!
    var userGarden: UserGarden!
    weak var returnDelegate : PlantReturnDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func doneButtonClicked(_ sender: UIButton) {
        // TODO: update plant id
        let newPlant = UserPlant(userPlantId: 0, catalogPlantId: nil, gardenId: userGarden.gardenId, name: name.text, image: plantImage.image!)
        returnDelegate?.didReturn(newPlant)
        dismiss(animated: true, completion: nil)
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

// Generic return result delegate protocol
protocol PlantReturnDelegate: UIViewController {
    func didReturn(_ result: UserPlant)
}
