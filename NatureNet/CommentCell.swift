//
//  CommentCell.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/18/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var comment: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureCell(name: String, comment: String) {
        self.username.text = name
        self.comment.text = comment
    }
}
