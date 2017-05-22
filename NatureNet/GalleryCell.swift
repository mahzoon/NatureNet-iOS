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
    @IBOutlet weak var projectName: UILabel!
    
    
    @IBOutlet weak var bottomInfoStackView: UIStackView!
    
    @IBOutlet weak var affiliationIcon: UILabel!
    
    var observation: NNObservation?
    var isShowMore = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if avatar != nil {
            avatar.layer.cornerRadius = avatar.frame.size.width / 2
            avatar.clipsToBounds = true
        }
        observationImage.clipsToBounds = true
    }
    
    func configureCell(username: String, affiliation: String, project: String, avatar: String, obsImage: String, text: String,
                       num_likes: String, num_dislikes: String, num_comments: String, date: NSNumber, isShowMore: Bool, observation: NNObservation?) {
        self.username.text = username
        self.affiliation.text = affiliation
        self.projectName.text = project
        self.descriptionText.text = text
        self.likes.text = num_likes
        self.dislikes.text = num_dislikes
        self.comments.text = num_comments
        
        self.postDate.text = UtilityFunctions.convertTimestampToDateString(date: date)
        
        self.observation = observation
        self.isShowMore = isShowMore
        
        self.avatar.image = nil
        self.observationImage.image = nil
        self.observationImage.isHidden = true
        
        if isShowMore {
            self.postDate.isHidden = true
            self.comments.isHidden = true
            self.dislikes.isHidden = true
            self.likes.isHidden = true
            self.descriptionText.isHidden = true
            self.affiliation.isHidden = true
            self.affiliationIcon.isHidden = true
            self.bottomInfoStackView.isHidden = true
        } else {
            
            self.postDate.isHidden = false
            self.comments.isHidden = false
            self.dislikes.isHidden = false
            self.likes.isHidden = false
            self.descriptionText.isHidden = false
            self.affiliation.isHidden = false
            self.affiliationIcon.isHidden = false
            self.bottomInfoStackView.isHidden = false
            
            self.avatar.image = UIImage(named: JOIN_PROFILE_IMAGE)
            self.observationImage.isHidden = false
            self.observationImage.image = UIImage(named: "sample_image3")
        }
        
        // load the avatar
        
        // load the observation image
        
    }

}
