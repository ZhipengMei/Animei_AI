//
//  ViewController.swift
//  Colorization
//
//  Created by Adrian on 4/21/18.
//  Copyright © 2018 Mei. All rights reserved.
//

import UIKit
import Alamofire

class colorizeVC: UIViewController, UINavigationControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource {
    
    //MARK:- IBOutlets
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var colorize_button: UIButton!
    @IBOutlet weak var result_button: UIButton!
    
    //MARK:- Properties
    var originalImage:UIImage?
    
    //user default
    let defaults = UserDefaults.standard
    
    //MARK:- ViewController life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        button_swap()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.imageView.layer.cornerRadius = 4
        self.imageView.layer.borderWidth = 1.0
        self.imageView.layer.borderColor = UIColor.black.cgColor
        
        if let image_data = UserDefaults.standard.data(forKey: "chosen_image") {
            self.imageView.image = UIImage(data:image_data)
        } else {
            self.imageView.image = UIImage(named:"girl")!
        }
        
    }
    
    func button_swap() {
        let isColorize = UserDefaults.standard.bool(forKey: "colorize_button")
        
        if isColorize == true {
            colorize_button.isHidden = true
            result_button.isHidden = false
        } else {
            result_button.isHidden = true
            colorize_button.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.originalImage = self.imageView.image
        CollectionView.delegate = self
        CollectionView.dataSource = self
        
    }
    //MARK:- Memory Management
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openLibrary(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    //MARK:- CollectionView datasource and delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:FilterCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "filter", for: indexPath) as! FilterCollectionViewCell
        switch indexPath.item {
        case 0:
            cell.lbl.text = "Mosaic"
            cell.imageView.image = #imageLiteral(resourceName: "mosaicImg")
        case 1:
            cell.lbl.text = "Scream"
            cell.imageView.image = #imageLiteral(resourceName: "screamImg")
        case 2:
            cell.lbl.text = "Muse"
            cell.imageView.image = #imageLiteral(resourceName: "museImg")
        case 3:
            cell.lbl.text = "Udnie"
            cell.imageView.image = #imageLiteral(resourceName: "Udanie")
        case 4:
            cell.lbl.text = "Candy"
            cell.imageView.image = #imageLiteral(resourceName: "candy")
        case 5:
            cell.lbl.text = "Feathers"
            cell.imageView.image = #imageLiteral(resourceName: "Feathers")
            
        default:
            cell.lbl.text = ""
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //select reference images here
    }
    
    //colorize function call
    @IBAction func colorize(_ sender: Any) {
        // make an API call here
        let urlString = "http://localhost:3000/tasks"
        post_request(urlString: urlString)
    }
    
    
    func post_request(urlString: String) {
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
                        
                        var path = json["path"]! as! String
                        self.post_path_request(path: path)
                        
                        path = String((path.split(separator: ".").first!)) + "_fin.jpg"
                        //save the file path
                        self.defaults.set(path, forKey: "result_path")
                        
                        // swap buttons
                        self.defaults.set(true, forKey: "colorize_button")
                        self.button_swap()
                    }
                }
                return
            case .failure(let encodingError):
                print(encodingError)
            }
        }
    }
    
    func post_path_request(path: String) {
        let urlString = "http://localhost:3000/tasks/path"
        Alamofire.request(urlString, method: .post, parameters: ["path" : path], encoding: URLEncoding.default)
    }
    
}

extension colorizeVC: UIImagePickerControllerDelegate {
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
        
        //userdefault to remember which one chosed
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        self.defaults.set(imageData, forKey: "chosen_image")
        
        //button swap
        self.defaults.set(false, forKey: "colorize_button")
        button_swap()
    }

}
