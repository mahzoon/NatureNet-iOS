//
//  SiteSwitchCell.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 6/8/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class SiteSwitchCell: UITableViewCell {

    @IBOutlet weak var siteLabel: UILabel!
    @IBOutlet weak var siteSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        siteSwitch.isOn = false
    }
    
    func configureCell(siteName: String, value: Bool, index: Int) {
        siteLabel.text = siteName
        siteSwitch.isOn = value
        siteSwitch.tag = index
    }
}
