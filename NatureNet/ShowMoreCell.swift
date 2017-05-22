//
//  ShowMoreCell.swift
//  NatureNet
//
//  Created by Mohammad Javad Mahzoon on 5/22/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class ShowMoreCell: UITableViewCell {

    @IBOutlet weak var showMoreButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell() {
        self.showMoreButton.setTitle(LISTS_SHOW_MORE_TEXT, for: .normal)
    }
}
