//
//  addGardenVC.swift
//  Green Thumb
//
//  Created by Megan Worrel on 10/24/20.
//

import UIKit
import SwiftyJSON

class addGardenVC: UIViewController {

    @IBOutlet weak var gardenName: UITextField!
    @IBOutlet weak var gardenLoc: UITextField!
    @IBOutlet weak var gardenImage: UIImageView!
    // TODO: update garden id
    var newGarden: UserGarden = UserGarden(gardenId: "", name: "", address: "")
    weak var returnDelegate : ReturnDelegate?
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue
        if self.view.frame.origin.y == 0{
            self.view.frame.origin.y -= keyboardFrame.height
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue
        if self.view.frame.origin.y != 0{
            self.view.frame.origin.y += keyboardFrame.height
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Dismiss keyboard on tap
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        // Move keyboard up when you type and back down when done typing
        /* Reference:
         https://www.hackingwithswift.com/example-code/uikit/how-to-adjust-a-uiscrollview-to-fit-the-keyboard
        */
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Do any additional setup after loading the view.
    }
    @IBAction func nameEdited(_ sender: UITextField) {
        newGarden.name = gardenName.text ?? ""
    }

    
    @IBAction func addressEdited(_ sender: Any) {
        newGarden.address = gardenLoc.text ?? ""
    }
    
    
    @IBAction func addButtonClicked(_ sender: UIButton) {
        // Check that both name and address provided
        if (newGarden.name == "" || newGarden.address == ""){
            let alertController = UIAlertController(title: "Missing Fields", message:
                "Please fill in both the garden name and address", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))

            self.present(alertController, animated: true, completion: nil)
        } else{
            // Add garden to database
            let url = URL(string: "http://192.81.216.18/api/v1/usergarden/add_garden/")!
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else {
                    print("no data")
                    return
                    
                }
                DispatchQueue.main.async {
                    do {
                        let json = try JSON(data: data)
                        let gardenId: String? = json["id"].stringValue
                        self.newGarden.gardenId = gardenId ?? ""
                        self.returnDelegate?.didReturn(self.newGarden)
                        self.dismiss(animated: true, completion: nil)
                    } catch {
                        print(error)
                    }
                }
            }

            task.resume()
        }
    }

}

// Generic return result delegate protocol
protocol ReturnDelegate: UIViewController {
    func didReturn(_ result: UserGarden)
}

