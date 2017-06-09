//
//  TextViewCell.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 6/8/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class TextViewCell: UITableViewCell {

    @IBOutlet weak var textBox: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textBox.text = ""
    }
    
    func configureCell() {
    }
}
