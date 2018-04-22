//
//  ResultVC.swift
//  Animei_AI
//
//  Created by Adrian on 4/21/18.
//  Copyright © 2018 Mei. All rights reserved.
//

import UIKit
import Alamofire

class ResultVC: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    var path: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlString = "http://localhost:3000/tasks/path"
        get_image_request(urlString: urlString)
    }
    
    func get_image_request(urlString: String) {
        print("inside get_image_request")
        // Alamofire 4
        Alamofire.request(urlString).response { response in // method defaults to `.get`
            
            //parse retured data
            let json = try? JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! [String:AnyObject]
            
            if json!["url"] != nil {
                print(json!["url"]!)
                let pic_url = "file://" + (json!["url"]! as! String)
                let url = URL(string: pic_url)
                let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                self.imageView.image = UIImage(data: data!)
            }
        }
    }

//    func get_request(urlString: String) {
//
//        // Alamofire 4
//        Alamofire.request(urlString).response { response in // method defaults to `.get`
//
//            //parse retured data
//            guard let json = try? JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) else {
//                return
//            }
//            print(json)
//        }
//    }
 

}
