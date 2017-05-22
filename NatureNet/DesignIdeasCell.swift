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
    
    @IBOutlet weak var affiliationIcon: UILabel!
    @IBOutlet weak var postDate: UILabel!
    @IBOutlet weak var Ideatext: UILabel!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var dislikes: UILabel!
    @IBOutlet weak var comments: UILabel!
    @IBOutlet weak var status: UIImageView!
    
    @IBOutlet weak var bottomIdeaInfoStackView: UIStackView!
    
    var designIdea: NNDesignIdea?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if avatar != nil {
            avatar.layer.cornerRadius = avatar.frame.size.width / 2
            avatar.clipsToBounds = true
        }
    }
    
    func configureCell(username: String, affiliation: String, avatar: String, text: String,
                       num_likes: String, num_dislikes: String, num_comments: String,
                       status: String, date: NSNumber, designIdea: NNDesignIdea?) {
        self.username.text = username
        self.affiliation.text = affiliation
        self.Ideatext.text = text
        self.likes.text = num_likes
        self.dislikes.text = num_dislikes
        self.comments.text = num_comments
        
        self.postDate.text = UtilityFunctions.convertTimestampToDateString(date: date)
        
        self.designIdea = designIdea
        
        self.avatar.image = UIImage(named: JOIN_PROFILE_IMAGE)
        
        // load the avatar
        
        // load the status image
    }
}
