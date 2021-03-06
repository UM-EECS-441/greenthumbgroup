//
//  loginVC.swift
//  Green Thumb
//
//  Created by Megan Worrel on 10/28/20.
//

import UIKit
import SwiftyJSON

class loginVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.email.delegate = self
        self.password.delegate = self
        self.setupHideKeyboardOnTap()
        // Do any additional setup after loading the view.
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.switchBasedNextTextField(textField)
        return true
    }
    private func switchBasedNextTextField(_ textField: UITextField) {
        switch textField {
            case self.email:
                self.password.becomeFirstResponder()
            case self.password:
                self.view.endEditing(true)
            default:
                self.email.resignFirstResponder()
        }
    }
    
    func setupHideKeyboardOnTap() {
        self.view.addGestureRecognizer(self.endEditingRecognizer())
        self.navigationController?.navigationBar.addGestureRecognizer(self.endEditingRecognizer())
    }
    private func endEditingRecognizer() -> UIGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
        tap.cancelsTouchesInView = false
        return tap
    }

    
    @IBAction func loginButtonClicked(_ sender: UIButton) {
        let url = URL(string: "http://192.81.216.18/accounts/login/")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        //request.httpShouldHandleCookies = true
        
        let parameters: [String: Any] = [
            "email": self.email.text!,
            "password": self.password.text!
        ]
        do {
               request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
           } catch let error {
               print(error.localizedDescription)
           }
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, let fields = httpResponse.allHeaderFields as? [String: String] else { return }
            print(response ?? "")
            DispatchQueue.main.async {
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: url)
                let delegate = UIApplication.shared.delegate as! AppDelegate
                if !cookies.isEmpty{
                    delegate.cookie = "\(cookies[0].name)=\(cookies[0].value)"
                    UserDefaults.standard.set(delegate.cookie, forKey: "login")
                    UserDefaults.standard.set(self.email.text!, forKey: "email")
                    print(delegate.cookie)
                }
            }
        }

        task.resume()
    }
    @IBAction func unwindToLogin(_ unwindSegue: UIStoryboardSegue) {}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
