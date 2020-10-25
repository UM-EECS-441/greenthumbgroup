//
//  gardenCell.swift
//  Green Thumb
//
//  Created by Megan Worrel on 10/24/20.
//

import UIKit

class gardenCell: UITableViewCell {

    @IBOutlet weak var gardenImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    var address: String?
    var mapClickAction : (() -> ())?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func mapClicked(_ sender: UIButton) {
        mapClickAction?()
    }

}
