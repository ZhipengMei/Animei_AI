//
//  telesignVC.swift
//  Animei_AI
//
//  Created by Adrian on 4/22/18.
//  Copyright © 2018 Mei. All rights reserved.
//

import UIKit
import Alamofire

class telesignVC: UIViewController {

    @IBOutlet weak var login_action: UIButton!
    @IBOutlet weak var verf_code_view: UIView!
    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var confirm_button: UIButton!
    @IBOutlet weak var send_newcode_button: UIButton!
    let urlString = "http://localhost:3000/tasks/telesign"
    var server_code: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        login_action.layer.cornerRadius = 8
        confirm_button.layer.cornerRadius = 8
        send_newcode_button.layer.cornerRadius = 8
        
        self.login_action.isHidden = false
        swapbuttons()
    }
    
    @IBAction func loginbtn_action(_ sender: Any) {
        print("clicked login")
        get_request(urlString: urlString)
    }
    
    @IBAction func confirm_action(_ sender: Any) {
        if self.server_code! == textfield.text! {
            print("code is correct")
            
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "homeVC") as! ViewController            
            let navigationController = UINavigationController(rootViewController: vc)
            self.present(navigationController, animated: true, completion: nil)
            
        } else {
            print("code is incorrect")
            textfield.text = "code is incorrect"
        }
    }
    
    @IBAction func new_code_action(_ sender: Any) {
        get_request(urlString: urlString)
    }
    
    func swapbuttons() {
        if login_action.isHidden == true {
            verf_code_view.isHidden = false
            send_newcode_button.isHidden = false
        } else {
            verf_code_view.isHidden = true
            send_newcode_button.isHidden = true
        }
    }
    
    func get_request(urlString: String) {
        // Alamofire 4
        Alamofire.request(urlString).response { response in // method defaults to `.get`
            //parse retured data
            if let json = try? JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! [String:AnyObject] {
                
                self.server_code = json["code"]! as? String
                self.login_action.isHidden = true
                self.swapbuttons()
            }
        }
    }
    
    @IBAction func end_editing(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    
}

