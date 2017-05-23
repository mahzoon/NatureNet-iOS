//
//  ProjectCell.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/16/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class ProjectCell: UITableViewCell {

    // reference to the project name label of the project cell
    @IBOutlet weak var projectName: UILabel!
    // reference to the project icon of the project cell
    @IBOutlet weak var projectIcon: UIImageView!
    
    // Project cells are two types: a regular cell containing project info, and a special cell for "show more". This variable tell us which type of cell this cell is.
    var isShowMore = false
    // This variable stores the section number which this cell belongs to in the tableview.
    var sectionIndex = -1
    // reference to the Model object
    var project: NNProject?
    
    // an id for the cell. This id is used for requesting icons and images
    var cellId: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // making the project icon look circular
        //projectIcon.layer.cornerRadius = projectIcon.frame.size.width / 2
        //projectIcon.clipsToBounds = true
    }
    
    // This function is called when creating a project cell. The content usaully should have a string (project name) and an icon. The only case that we might not expect to have icon is when the cell is "show more...". In that case the call would be like: configureCell(name: "Show more...", icon: "", useDefaultIcon: false, isShowMore: true, section: X, project: nil)
    func configureCell(id: String, name: String, icon: String, useDefaultIcon: Bool, isShowMore: Bool, section: Int, project: NNProject?) {
        self.cellId = id
        self.projectName.text = name
        self.isShowMore = isShowMore
        self.sectionIndex = section
        self.project = project
        
        if isShowMore {
            self.projectIcon.image = nil
        } else {
            self.projectIcon.image = ICON_DEFAULT_PROJECT
        }
        
        if !useDefaultIcon {
            // requesting the icon
            MediaManager.md.getOrDownloadIcon(requesterId: cellId, urlString: icon, completion: { img, err in
                if let i = img {
                    DispatchQueue.main.async {
                        self.projectIcon.image = i
                    }
                }
            })
        }
    }

}
