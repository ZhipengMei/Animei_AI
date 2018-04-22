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
    
    //MARK:- Properties
    var originalImage:UIImage?
    
    //MARK:- ViewController life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.imageView.layer.cornerRadius = 4
        self.imageView.layer.borderWidth = 1.0
        self.imageView.layer.borderColor = UIColor.black.cgColor
        
//        self.imageView.image = UIImage(named:"girl")!
        self.imageView.image = UIImage(named:"Vegeta_Sketched")!
        
        
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
        colorize_button.isEnabled = false
        
        // make an API call here
        print("\n\n\ncolorize clicked\n")
        
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
                    let json = try? JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as! [String:AnyObject]
                    
                    print(json!["path"]!)
                    
                    self.post_path_request(path: json!["path"]! as! String)
                    
                    if json!["path"] != nil {
                        let vc = ResultVC()
                        vc.path = json!["path"]! as? String
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                return
            case .failure(let encodingError):
                print(encodingError)
            }
        }
    }
    
    func post_path_request(path: String) {
        print(path)
        let urlString = "http://localhost:3000/tasks/path"
        Alamofire.request(urlString, method: .post, parameters: ["path" : path], encoding: URLEncoding.default)
        colorize_button.isEnabled = true
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
    }

}
