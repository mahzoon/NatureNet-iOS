//
//  RoundedTextView.swift
//  NatureNet
//
//  Created by Mohammad Javad Mahzoon on 5/19/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class RoundedTextView: UITextView {

    override func awakeFromNib() {
        layer.cornerRadius = 5.0
    }
    
    func GetFixTextRowHight(maxHeight: CGFloat) -> CGFloat {
        let fixedWidth = self.frame.size.width
        self.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = self.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newHeight = min(newSize.height, maxHeight)
        return newHeight
    }
}
