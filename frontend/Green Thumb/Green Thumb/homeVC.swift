//
//  homeVC.swift
//  Green Thumb
//
//  Created by Joe Riggs on 11/16/20.
//

import UIKit

class homeVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func accountClicked(_ sender: Any) {
        let cookie = UserDefaults.standard.object(forKey: "login") as? String
        if cookie == "" {
            self.performSegue(withIdentifier: "toLogin", sender: self)
        } else {
            self.performSegue(withIdentifier: "toWelcome", sender: self)
        }
    }
    
}
