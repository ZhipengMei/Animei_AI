//
//  ViewController.swift
//  Animei_AI
//
//  Created by Adrian on 4/21/18.
//  Copyright © 2018 Mei. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
   
    //MARK:- ViewController life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pink = UIColor(red: 219/255, green: 00/255, blue: 170/255, alpha: 1.0)
        let textAttributes = [NSAttributedStringKey.foregroundColor:pink]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
    }
    
}
