//
//  FilterCollectionViewCell.swift
//  Colorization
//
//  Created by Adrian on 4/21/18.
//  Copyright © 2018 Mei. All rights reserved.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var lbl: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 8
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth =  1
    }
}
 
