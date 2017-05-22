//
//  CommunityDetailController.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/17/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class CommunityDetailController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var userDetailTable: UITableView!
    
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var lastActivityDate: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var numObservations: UILabel!
    @IBOutlet weak var numDesignIdeas: UILabel!
    
    var user: NNUser?
    
    var pages = 0
    var maxNV = 0
    var maxNB = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userDetailTable.delegate = self
        userDetailTable.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.username.text = user?.displayName
        if let timestamp = user?.latestContribution {
            if timestamp == 0 {
                if let updatedAt = user?.updatedAt {
                    self.lastActivityDate.text = UtilityFunctions.convertTimestampToDateString(date: updatedAt)
                    self.lastActivityDate.isHidden = false
                } else {
                    self.lastActivityDate.isHidden = true
                }
            } else {
                self.lastActivityDate.text = UtilityFunctions.convertTimestampToDateString(date: timestamp)
                self.lastActivityDate.isHidden = false
            }
        } else {
            self.lastActivityDate.isHidden = true
        }
        if let affiliation = self.user?.affiliation {
            self.location.text = DataService.ds.GetSiteName(with: affiliation)
        } else {
            self.location.isHidden = true
        }
        
        self.descriptionText.text = user?.bio
        if let t = self.descriptionText.text, t == "" {
            self.descriptionText.isHidden = true
        }
        self.title = self.user?.displayName
        
        if let user = self.user {
            self.numDesignIdeas.text = "\(DataService.ds.GetDesignIdeasForUser(with: user.id).count)"
            self.numObservations.text = "\(DataService.ds.GetObservationsForUser(with: user.id).count)"
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        userDetailTable.FixHeaderLayout()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let n = DETAILED_OBSV_LIST_INIT_COUNT + pages * DETAILED_OBSV_LIST_LOAD_MORE_COUNT
        var total = 0
        if let user = self.user {
            total = DataService.ds.GetObservationsForUser(with: user.id).count
        }
        var ret_val = 0
        if n < total {
            maxNV = n
            maxNB = true
            ret_val = n + 1
        } else {
            maxNV = total
            maxNB = false
            ret_val = total
        }
        return ret_val
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if maxNB && maxNV == indexPath.row {
            return CGFloat(SHOW_MORE_CELL_HEIGHT)
        }
        return CGFloat(RECENT_OBSV_ESTIMATED_HEIGHT)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "GalleryCell") as? GalleryCell {
            if maxNB && maxNV == indexPath.row {
                cell.configureCell(username: "", affiliation: LISTS_SHOW_MORE_TEXT, project: "", avatar: "", obsImage: "", text: "", num_likes: "", num_dislikes: "", num_comments: "", date: 0, isShowMore: true, observation: nil)
                return cell
            }
            if let user = self.user {
                let listObsv = DataService.ds.GetObservationsForUser(with: user.id)
                if indexPath.row < listObsv.count {
                    let observation = listObsv[indexPath.row]
                    let projectName = DataService.ds.GetProject(by: observation.project)?.name ?? ""
                    cell.configureCell(username: user.displayName, affiliation: DataService.ds.GetSiteName(with: user.affiliation), project: projectName, avatar: user.avatarUrl, obsImage: observation.observationImageUrl, text: observation.observationText, num_likes: "0", num_dislikes: "0", num_comments: "0", date: observation.updatedAt, isShowMore: false, observation: observation)
                }
            }
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    // When seeing details of an observation, we need to check if the sender (the cell) is a "show more" cell or not. If so, then the transition is not possible, instead another "page" should be added to the data.
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == SEGUE_DETAILS {
            if let cell = sender as? GalleryCell {
                if cell.isShowMore {
                    pages = pages + 1
                    userDetailTable.reloadData()
                    return false
                }
            }
        }
        return true
    }
}
