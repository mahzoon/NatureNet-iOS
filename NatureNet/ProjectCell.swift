//
//  ProjectCell.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/16/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class ProjectCell: UITableViewCell {

    
    @IBOutlet weak var projectName: UILabel!
    @IBOutlet weak var projectIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(name: String, icon: String) {
        self.projectName.text = name
        // load icon
    }

}
