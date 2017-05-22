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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if avatar != nil {
            avatar.layer.cornerRadius = avatar.frame.size.width / 2
            avatar.clipsToBounds = true
        }
        observationImage.clipsToBounds = true
    }
    
    func configureCell(username: String, affiliation: String, project: String, avatar: String, obsImage: String, text: String,
                       num_likes: String, num_dislikes: String, num_comments: String, date: NSNumber, observation: NNObservation?) {
        if (self.username != nil) {
            self.username.text = username
        }
        self.affiliation.text = affiliation
        self.projectName.text = project
        self.descriptionText.text = text
        self.likes.text = num_likes
        self.dislikes.text = num_dislikes
        self.comments.text = num_comments
        
        self.postDate.text = UtilityFunctions.convertTimestampToDateString(date: date)
        
        self.observation = observation
        
        if (self.avatar != nil) {
            self.avatar.image = UIImage(named: JOIN_PROFILE_IMAGE)
        }
        
        if text != "" {
            self.descriptionText.isHidden = false
        } else {
            self.descriptionText.isHidden = true
        }
        
        self.observationImage.image = UIImage(named: "sample_image3")
        
        
        // load the avatar if there is any
        
        // load the observation image
        
    }

}
