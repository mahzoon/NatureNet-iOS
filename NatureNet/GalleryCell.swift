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
    
    // an id for the cell. This id is used for requesting icons and images
    var cellId: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // in CommunityDetailsController we use a header-less version of this gallery cell, so avatar might be nil in this case.
        if avatar != nil {
            avatar.layer.cornerRadius = avatar.frame.size.width / 2
            avatar.clipsToBounds = true
        }
        observationImage.clipsToBounds = true
    }
    
    func configureCell(id: String, username: String, affiliation: String, project: String, avatar: String, obsImage: String, text: String,
                       num_likes: String, num_dislikes: String, num_comments: String, date: NSNumber, observation: NNObservation?) {
        self.cellId = id
        // in CommunityDetailsController we use a header-less version of this gallery cell, so username might be nil in this case.
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
            self.avatar.image = ICON_DEFAULT_USER_AVATAR
            // requesting the icon
            MediaManager.md.getOrDownloadIcon(requesterId: cellId, urlString: avatar, completion: { img, err in
                if let i = img {
                    DispatchQueue.main.async {
                        self.avatar.image = i
                    }
                }
            })
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
