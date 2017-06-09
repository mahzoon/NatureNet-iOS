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
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    
    @IBOutlet weak var bottomInfoStackView: UIStackView!
    
    @IBOutlet weak var affiliationIcon: UILabel!
    
    var observation: NNObservation?
    
    // an id for the cell. This id is used for requesting icons and images
    var cellId: String = ""
    
    var tappedCommentButton = false
    
    // this is a reference to the super view controller and used to display messages
    var parentController :UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // in CommunityDetailsController we use a header-less version of this gallery cell, so avatar might be nil in this case.
        if avatar != nil {
            avatar.layer.cornerRadius = avatar.frame.size.width / 2
            avatar.clipsToBounds = true
        }
        observationImage.clipsToBounds = true
    }
    
    func configureCell(id: String, username: String, affiliation: String, project: String, avatar: String, obsImage: String, text: String, num_likes: String, num_dislikes: String, num_comments: String, date: NSNumber, observation: NNObservation?, controller: UIViewController) {
        self.cellId = id
        // in CommunityDetailsController we use a header-less version of this gallery cell, so username/affiliation might be nil in this case.
        if (self.username != nil) {
            self.username.text = username
        }
        if (self.affiliation != nil) {
            self.affiliation.text = affiliation
        }
        self.projectName.text = project
        self.descriptionText.text = text
        self.likes.text = num_likes
        self.dislikes.text = num_dislikes
        self.comments.text = num_comments
        self.parentController = controller
        self.postDate.text = UtilityFunctions.convertTimestampToDateString(date: date)
        
        self.observation = observation
        
        // load the avatar if there is any
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
        
//        if text != "" {
//            self.descriptionText.isHidden = false
//        } else {
//            self.descriptionText.isHidden = true
//        }
        
        // load the observation image
        self.observationImage.image = IMAGE_DEFAULT_OBSERVATION
        // requesting the icon
        MediaManager.md.getOrDownloadImage(requesterId: cellId + ".img", urlString: obsImage, completion: { img, err in
            if let i = img {
                DispatchQueue.main.async {
                    self.observationImage.image = i
                }
            }
        })
        
        updateLikeAndDislikeButtonImages()
    }
    
    @IBAction func likeTapped(_ sender: Any) {
        if !DataService.ds.LoggedIn() {
            if let controller = parentController {
                UtilityFunctions.showAuthenticationRequiredMessage(theView: controller, completion: {
                    controller.performSegue(withIdentifier: SEGUE_SIGNIN, sender: nil)
                })
            }
        } else {
            if let obsv = observation {
                DataService.ds.ToggleLikeOrDislikeOnObservation(like: true, observationId: obsv.id, completion: { success in
                    if (success) { self.updateLikeAndDislikeButtonImages() }
                })
            }
            updateLikeAndDislikeButtonImages()
        }
    }
    
    @IBAction func dislikeTapped(_ sender: Any) {
        if !DataService.ds.LoggedIn() {
            if let controller = parentController {
                UtilityFunctions.showAuthenticationRequiredMessage(theView: controller, completion: {
                    controller.performSegue(withIdentifier: SEGUE_SIGNIN, sender: nil)
                })
            }
        } else {
            if let obsv = observation {
                DataService.ds.ToggleLikeOrDislikeOnObservation(like: false, observationId: obsv.id, completion: { success in
                    if (success) { self.updateLikeAndDislikeButtonImages() }
                })
            }
        }
    }
    
    private func updateLikeAndDislikeButtonImages() {
        // update self.observation
        if let obsv = self.observation {
            self.observation = DataService.ds.GetObservation(with: obsv.id)
        }
        if let obsv = self.observation {
            // update like/dislike labels
            self.likes.text = "\(obsv.Likes.count)"
            self.dislikes.text = "\(obsv.Dislikes.count)"
            // update buttons
            if let currentUserId = DataService.ds.GetCurrentUserId() {
                if let like = obsv.likes[currentUserId] {
                    if like {
                        likeButton.setImage(ICON_LIKE_GREEN, for: .normal)
                        dislikeButton.setImage(ICON_DISLIKE_GRAY, for: .normal)
                    } else {
                        likeButton.setImage(ICON_LIKE_GRAY, for: .normal)
                        dislikeButton.setImage(ICON_DISLIKE_RED, for: .normal)
                    }
                } else {
                    likeButton.setImage(ICON_LIKE_GRAY, for: .normal)
                    dislikeButton.setImage(ICON_DISLIKE_GRAY, for: .normal)
                }
            } else {
                likeButton.setImage(ICON_LIKE_GRAY, for: .normal)
                dislikeButton.setImage(ICON_DISLIKE_GRAY, for: .normal)
            }
        }
    }
    
    @IBAction func commentTapped(_ sender: Any) {
        tappedCommentButton = true
        if let p = parentController {
            p.performSegue(withIdentifier: SEGUE_DETAILS, sender: self)
        }
    }
}
