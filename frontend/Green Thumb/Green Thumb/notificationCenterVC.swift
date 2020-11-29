//
//  updatePasswordVC.swift
//  Green Thumb
//
//  Created by Joe Riggs on 11/28/20.
//

import UIKit
import SwiftyJSON

class notificationCenterVC: UIViewController, UITextFieldDelegate {
    
    var notifications = UserDefaults.standard.object(forKey: "notifications") as? Bool ?? false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(notifications)
        if notifications {
            subscribeButton.setTitle("Unsubscribe", for: .normal)
        }
        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var subscribeButton: UIButton!
    @IBAction func subscribeButtonClicked(_ sender: Any) {
        let email = UserDefaults.standard.object(forKey: "email") as? String ?? ""
        var url_string = ""
        if notifications {
            url_string = "http://192.81.216.18/accounts/unsubscribe/"
        } else {
            url_string =  "http://192.81.216.18/accounts/subscribe/"
        }
        url_string += email
        let url = URL(string: url_string)!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, let _ = httpResponse.allHeaderFields as? [String: String] else { return }
            print(response ?? "")
            if httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    if self.notifications {
                        UserDefaults.standard.set(false, forKey: "notifications")
                        self.notifications = false
                        self.subscribeButton.setTitle("Subscribe", for: .normal)
                    } else {
                        UserDefaults.standard.set(true, forKey: "notifications")
                        self.notifications = true
                        self.subscribeButton.setTitle("Unsubscribe", for: .normal)
                    }
                }
            }
        }
        task.resume()
        print(notifications)
    }
}
