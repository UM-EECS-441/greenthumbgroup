//
//  guidePage.swift
//  Green Thumb
//
//  Created by Tiger Shi on 10/27/20.
//

import UIKit

class guidePage: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var guideText: UILabel!
    
    var guideBody = "No guides available :("
    var toTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: guideText.bottomAnchor).isActive = true
        
        self.title = toTitle
        guideText.text = guideBody
//        self.title = "meme"
        // Do any additional setup after loading the view.
    }
}
