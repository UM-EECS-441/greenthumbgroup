//
//  welcomeVC.swift
//  Green Thumb
//
//  Created by Joe Riggs on 11/16/20.
//

import UIKit

class welcomeVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func logoutButtonClicked(_ sender: UIButton) {
        let url = URL(string: "http://192.81.216.18/accounts/logout/")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        //request.httpShouldHandleCookies = true
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, let _ = httpResponse.allHeaderFields as? [String: String] else { return }
            print(response ?? "")
            DispatchQueue.main.async {
                UserDefaults.standard.set("", forKey: "login")
                UserDefaults.standard.set("", forKey: "email")
            }
        }

        task.resume()
    }
    @IBAction func unwindToWelcomeBack(_ unwindSegue: UIStoryboardSegue) {}
}
