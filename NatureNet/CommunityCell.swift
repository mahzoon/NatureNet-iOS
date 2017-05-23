//
//  CommunityCell.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/16/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class CommunityCell: UITableViewCell {

    // reference to the username label of the community cell
    @IBOutlet weak var username: UILabel!
    // reference to the icon image of the community cell
    @IBOutlet weak var avatar: UIImageView!
    
    // Community cells are two types: a regular cell containing user info, and a special cell for "show more". This variable tell us which type of cell this cell is.
    var isShowMore = false
    // This variable stores the section number which this cell belongs to in the tableview.
    var sectionIndex = -1
    // reference to the Model object
    var user: NNUser?
    // an id for the cell. This id is used for requesting icons and images
    var cellId: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // making the avatar look circular
        avatar.layer.cornerRadius = avatar.frame.size.width / 2
        avatar.clipsToBounds = true
    }
    
    // This function is called when creating a community cell. The content usaully should have a string (username) and an icon. The only case that we might not expect to have icon is when the cell is "show more...". In that case the call would be like: configureCell(name: "Show more...", icon: "", useDefaultIcon: false, isShowMore: true, section: X, user: nil)
    func configureCell(id: String, name: String, icon: String, useDefaultIcon: Bool, isShowMore: Bool, section: Int, user: NNUser?) {
        self.cellId = id
        self.username.text = name
        self.isShowMore = isShowMore
        self.sectionIndex = section
        self.user = user
        
        if isShowMore {
            self.avatar.image = nil
        } else {
            self.avatar.image = ICON_DEFAULT_USER_AVATAR
        }
        
        if !useDefaultIcon {
            // requesting the icon
            MediaManager.md.getOrDownloadIcon(requesterId: cellId, urlString: icon, completion: { img, err in
                if let i = img {
                    DispatchQueue.main.async {
                        self.avatar.image = i
                    }
                }
            })
        }
    }
}
