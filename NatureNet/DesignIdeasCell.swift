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
    var isShowMore = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if avatar != nil {
            avatar.layer.cornerRadius = avatar.frame.size.width / 2
            avatar.clipsToBounds = true
        }
    }
    
    func configureCell(username: String, affiliation: String, avatar: String, text: String,
                       num_likes: String, num_dislikes: String, num_comments: String,
                       status: String, date: NSNumber, isShowMore: Bool, designIdea: NNDesignIdea?) {
        self.username.text = username
        self.affiliation.text = affiliation
        self.Ideatext.text = text
        self.likes.text = num_likes
        self.dislikes.text = num_dislikes
        self.comments.text = num_comments
        
        let d = NSDate(timeIntervalSince1970:Double(date)/1000)
        let formatter = DateFormatter()
        formatter.locale = NSLocale.current
        formatter.timeZone = NSTimeZone.local
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        self.postDate.text = formatter.string(from: d as Date)
        
        self.designIdea = designIdea
        self.isShowMore = isShowMore
        
        self.avatar.image = nil
        if (isShowMore) {
            self.bottomIdeaInfoStackView.isHidden = true
            self.postDate.isHidden = true
            self.affiliation.isHidden = true
            self.affiliationIcon.isHidden = true
            self.Ideatext.isHidden = true
        } else {
            self.bottomIdeaInfoStackView.isHidden = false
            self.postDate.isHidden = false
            self.affiliation.isHidden = false
            self.affiliationIcon.isHidden = false
            self.Ideatext.isHidden = false
            
            // load the avatar
            self.avatar.image = UIImage(named: JOIN_PROFILE_IMAGE)
            // load the status image
        }
    }
}
