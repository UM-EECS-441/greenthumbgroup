//
//  catalogPage.swift
//  Green Thumb
//
//  Created by Joe Riggs on 10/27/20.
//

import UIKit

class catalogPage: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var plantName: UILabel!
    @IBOutlet weak var plantSpecies: UILabel!
    @IBOutlet weak var plantType: UILabel!
    @IBOutlet weak var plantDescription: UILabel!
    @IBOutlet weak var plantTags: UILabel!
    @IBOutlet weak var daysTilWater: UILabel!
    @IBOutlet weak var plantWaterInfo: UILabel!
    
    var name = "Plant"
    var species = "Species"
    var type = "Type"
    var desc = "Description"
    var tags = ""
    var waterDays = ""
    var waterInfo = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: plantWaterInfo.bottomAnchor).isActive = true
        
        plantName.text = name
        plantSpecies.text = species
        plantType.text = type
        plantDescription.text = desc
        // Not done yet
        plantTags.numberOfLines = 0
        plantTags.text = tags
        daysTilWater.text = waterDays
        plantWaterInfo.text = waterInfo
    }
}
