//
//  RoundedButton.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/16/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {

    override func awakeFromNib() {
        layer.cornerRadius = 5.0
        backgroundColor = APP_COLOR_LIGHT
        setTitleColor(APP_COLOR_DARK, for: .normal)
    }
}
