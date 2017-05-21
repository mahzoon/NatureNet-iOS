//
//  DesignIdeasCell.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/16/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class DesignIdeasCell: UITableViewCell {

    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var affiliation: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var Ideatext: UILabel!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var dislikes: UILabel!
    @IBOutlet weak var comments: UILabel!
    @IBOutlet weak var status: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func draw(_ rect: CGRect) {
        avatar.layer.cornerRadius = avatar.frame.size.width / 2
    }

    func configureCell(username: String, affiliation: String, avatar: String, text: String,
                       num_likes: String, num_dislikes: String, num_comments: String,
                       status: String) {
        self.username.text = username
        self.affiliation.text = affiliation
        self.Ideatext.text = text
        self.likes.text = num_likes
        self.dislikes.text = num_dislikes
        self.comments.text = num_comments
        
        // load the avatar
        
        // load the status image
        
    }
}
