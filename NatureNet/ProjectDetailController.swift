//
//  ProjectDetailController.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/17/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class ProjectDetailController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var projectDetailTable: UITableView!
    
    @IBOutlet weak var projectIcon: UIImageView!
    @IBOutlet weak var projectName: UILabel!
    @IBOutlet weak var postDate: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    
    var project: NNProject?

    var pages = 0
    var maxNV = 0
    var maxNB = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        projectDetailTable.delegate = self
        projectDetailTable.dataSource = self
        
        DataService.ds.registerTableView(group: DB_COMMENTS_PATH, tableView: projectDetailTable)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.projectName.text = project?.name
        if let timestamp = project?.latestContribution {
            if timestamp == 0 {
                if let updatedAt = project?.updatedAt {
                    self.postDate.text = UtilityFunctions.convertTimestampToDateString(date: updatedAt)
                    self.postDate.isHidden = false
                } else {
                    self.postDate.isHidden = true
                }
            } else {
                self.postDate.text = UtilityFunctions.convertTimestampToDateString(date: timestamp)
                self.postDate.isHidden = false
            }
        } else {
            self.postDate.isHidden = true
        }
        if let sites = project?.sites {
            self.location.text = sites.map({ (e) -> String in
                return DataService.ds.GetSiteName(with: e)
            }).joined(separator: ", ")
        }
        self.descriptionText.text = project?.descriptionText
        self.title = self.projectName.text
        
        self.projectIcon.image = ICON_PROJECT_DEFAULT
        // requesting the icon
        if let p = project {
            MediaManager.md.getOrDownloadIcon(requesterId: "ProjectDetailController", urlString: p.iconUrl, completion: { img, err in
                if let i = img {
                    DispatchQueue.main.async {
                        self.projectIcon.image = i
                    }
                }
            })
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        projectDetailTable.FixHeaderLayout()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let n = DETAILED_OBSV_LIST_INIT_COUNT + pages * DETAILED_OBSV_LIST_LOAD_MORE_COUNT
        var total = 0
        if let project = self.project {
            total = DataService.ds.GetObservationsForProject(with: project.id).count
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
        
        // the case which we should dequeue a ShowMoreCell
        if maxNB && maxNV == indexPath.row {
            if let cell = tableView.dequeueReusableCell(withIdentifier: SHOW_MORE_CELL_ID) as? ShowMoreCell {
                cell.configureCell()
                return cell
            } else {
                return ShowMoreCell()
            }
        }
        
        // the case which we should dequeue a regular cell (GalleryCell)
        if let cell = tableView.dequeueReusableCell(withIdentifier: GALLERY_CELL_ID) as? GalleryCell {
            if let project = self.project {
                let listObsv = DataService.ds.GetObservationsForProject(with: project.id)
                if indexPath.row < listObsv.count {
                    let observation = listObsv[indexPath.row]
                    if let user = DataService.ds.GetUser(by: observation.observer) {
                        let numComment = DataService.ds.GetCommentsOnObservation(with: observation.id).count
                        let numLikes = observation.Likes.count
                        let numDislikes = observation.Dislikes.count
                        cell.configureCell(id: GALLERY_CELL_ID + "\(indexPath.section).\(indexPath.row)",
                            username: user.displayName, affiliation: DataService.ds.GetSiteName(with: user.affiliation), project: project.name, avatar: user.avatarUrl, obsImage: observation.observationImageUrl, text: observation.observationText, num_likes: "\(numLikes)", num_dislikes: "\(numDislikes)", num_comments: "\(numComment)", date: observation.updatedAt, observation: observation, controller: self)
                    }
                }
            }
            return cell
        } else {
            return GalleryCell()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            if id == SEGUE_DETAILS {
                if let cell = sender as? GalleryCell {
                    if let dest = segue.destination as? GalleryDetailController {
                        dest.observationObj = cell.observation
                    }
                }
            }
        }
    }
    
    @IBAction func showMoreTapped(_ sender: Any) {
        pages = pages + 1
        projectDetailTable.reloadData()
    }
}
