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
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    
    var designIdea: NNDesignIdea?
    
    // an id for the cell. This id is used for requesting icons and images
    var cellId: String = ""
    
    // this is a reference to the super view controller and used to display messages
    var parentController :UIViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.avatar.layer.cornerRadius = self.avatar.frame.size.width / 2
        self.avatar.clipsToBounds = true
    }
    
    func configureCell(id: String, username: String, affiliation: String, avatar: String, text: String,
                       num_likes: String, num_dislikes: String, num_comments: String,
                       status: String, date: NSNumber, designIdea: NNDesignIdea?, controller: UIViewController) {
        self.cellId = id
        self.username.text = username
        self.affiliation.text = affiliation
        self.Ideatext.text = text
        self.likes.text = num_likes
        self.dislikes.text = num_dislikes
        self.comments.text = num_comments
        self.parentController = controller
        
        self.postDate.text = UtilityFunctions.convertTimestampToDateString(date: date)
        
        self.designIdea = designIdea
        
        self.avatar.image = ICON_DEFAULT_USER_AVATAR
        
        // load the avatar
        // requesting the icon
        MediaManager.md.getOrDownloadIcon(requesterId: cellId, urlString: avatar, completion: { img, err in
            if let i = img {
                DispatchQueue.main.async {
                    self.avatar.image = i
                }
            }
        })
        
        // load the status image
        self.status.image = nil
        if status.lowercased() == DESIGN_IDEA_STATUS_DONE {
            self.status.image = ICON_DESIGN_IDEA_STATUS_DONE
        }
        if status.lowercased() == DESIGN_IDEA_STATUS_DISCUSSING || status.lowercased() == DESIGN_IDEA_STATUS_TO_DO {
            self.status.image = ICON_DESIGN_IDEA_STATUS_DISCUSSING
        }
        
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
            if let idea = designIdea {
                DataService.ds.ToggleLikeOrDislikeOnDesignIdea(like: true, designIdeaId: idea.id)
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
            if let idea = designIdea {
                DataService.ds.ToggleLikeOrDislikeOnDesignIdea(like: false, designIdeaId: idea.id)
            }
            updateLikeAndDislikeButtonImages()
        }
    }
    
    private func updateLikeAndDislikeButtonImages() {
        if let currentUserId = DataService.ds.GetCurrentUserId() {
            if let like = designIdea?.likes[currentUserId] {
                if like {
                    likeButton.setImage(ICON_LIKE_GREEN, for: .normal)
                } else {
                    dislikeButton.setImage(ICON_DISLIKE_GREEN, for: .normal)
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
    
    @IBAction func commentTapped(_ sender: Any) {
    }
    
}
