//
//  catalogCell.swift
//  Green Thumb
//
//  Created by Megan Worrel on 10/29/20.
//

import UIKit

class catalogCell: UITableViewCell {

    @IBOutlet weak var addButton: UIButton!
    var addClickAction : (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func addButtonClicked(_ sender: UIButton) {
        addClickAction?()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
