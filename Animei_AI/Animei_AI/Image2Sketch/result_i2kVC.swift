//
//  result_i2kVC.swift
//  Animei_AI
//
//  Created by Adrian on 4/22/18.
//  Copyright © 2018 Mei. All rights reserved.
//

import UIKit
import Alamofire

class result_i2kVC: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageView.loadGif(asset: "loading")
//        
//        //var filepath = "/uploads/1524378659588/file.jpg"
//        let path = UserDefaults.standard.string(forKey: "result_path")
//        
//        let urlString = "http://localhost:3000/tasks/path2"
//        get_image_request(urlString: urlString, path: path!)
    }
    
    func get_image_request(urlString: String, path: String) {
        print("inside get_image_request")
        print(path)
        
        // Alamofire 4
        Alamofire.request(urlString, method: .post, parameters: ["path" : path], encoding: URLEncoding.default).response(completionHandler: { response in
            
            //parse retured data
            if let json = try? JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! [String:AnyObject] {
                
                let pic_url = "file://" + (json["url"]! as! String)
                let url = URL(string: pic_url)
                print(url!)
                
                //make sure your image in this url does exist,
                //otherwise unwrap in a if let check / try-catch
                if let data = try? Data(contentsOf: url!) {
                    self.imageView.image = UIImage(data: data)
                }
                
            }
            
        })
    }
    

}
