//
//  GalleryCell.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/16/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class GalleryCell: UITableViewCell {

    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var affiliation: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var observationImage: UIImageView!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var dislikes: UILabel!
    @IBOutlet weak var comments: UILabel!
    @IBOutlet weak var postDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func draw(_ rect: CGRect) {
        if avatar != nil {
            avatar.layer.cornerRadius = avatar.frame.size.width / 2
            avatar.clipsToBounds = true
        }
        observationImage.clipsToBounds = true
    }
    
    func configureCell(username: String, affiliation: String, avatar: String, obsImage: String, text: String,
                       num_likes: String, num_dislikes: String, num_comments: String, date: String) {
        self.username.text = username
        self.affiliation.text = affiliation
        self.descriptionText.text = text
        self.likes.text = num_likes
        self.dislikes.text = num_dislikes
        self.comments.text = num_comments
        self.postDate.text = date
        
        // load the avatar
        
        // load the observation image
        
    }

}
