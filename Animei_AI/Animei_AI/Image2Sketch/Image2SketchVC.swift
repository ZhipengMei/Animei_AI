//
//  Image2SketchVC.swift
//  Animei_AI
//
//  Created by Adrian on 4/22/18.
//  Copyright © 2018 Mei. All rights reserved.
//

import UIKit
import Alamofire

class Image2SketchVC: UIViewController, UINavigationControllerDelegate {
    
    
    //MARK:- IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    
    
    //MARK:- Properties
    var originalImage:UIImage?
    
    //MARK:- ViewController life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.imageView.layer.cornerRadius = 4
        self.imageView.layer.borderWidth = 1.0
        self.imageView.layer.borderColor = UIColor.black.cgColor
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.originalImage = self.imageView.image
    }
    

    
    @IBAction func openLibrary(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    @IBAction func fire_api_request(_ sender: Any) {
        let urlString = "http://localhost:3000/tasks"
        
        let image = self.originalImage!
        let imgData = UIImageJPEGRepresentation(image, 0.2)!
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData, withName: "profileImage",fileName: "file.jpg", mimeType: "image/jpg")
        },
        to: urlString)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.responseString { response in
                    
                    //parse retured data
                    if let json = try? JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! [String:AnyObject] {
                        
//                        var path = json["path"]! as! String
//                        self.post_path_request(path: path)
//                        
//                        path = String((path.split(separator: ".").first!)) + "_fin.jpg"
//                        //save the file path
//                        self.defaults.set(path, forKey: "result_path")
                        
                    }
                }
                return
            case .failure(let encodingError):
                print(encodingError)
            }
        }
    }
    
    
}


extension Image2SketchVC: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true)
        
        guard let image = info["UIImagePickerControllerOriginalImage"] as? UIImage else {
            return
        }
        originalImage = image
        imageView.image = image
    }
}
