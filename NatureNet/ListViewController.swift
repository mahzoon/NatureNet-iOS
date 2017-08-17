//
//  ListViewController.swift
//  NatureNet
//
//  Created by Mohammad Javad Mahzoon on 8/17/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    // reference to the observation feed which is in a table view
    @IBOutlet weak var galleryTable: UITableView!
    
    public var searchText = ""
    
    var pages = 0
    var maxNV = 0
    var maxNB = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.galleryTable.delegate = self
        self.galleryTable.dataSource = self
        
        DataService.ds.registerTableView(group: DB_OBSERVATIONS_PATH, tableView: galleryTable)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let n = GALLERY_LIST_INIT_COUNT + pages * GALLERY_LIST_LOAD_MORE_COUNT
        let total = DataService.ds.GetNumObervations(searchFilter: searchText)
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
        return CGFloat(GALLERY_CELL_ITEM_HEIGHT)
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
            //let searchText = self.searchBar.text ?? ""
            if let observation = DataService.ds.GetObservation(at: indexPath.row, searchFilter: searchText) {
                if let user = DataService.ds.GetUser(by: observation.observer) {
                    if let project = DataService.ds.GetProject(by: observation.project) {
                        let numComment = DataService.ds.GetCommentsOnObservation(with: observation.id).count
                        let numLikes = observation.Likes.count
                        let numDislikes = observation.Dislikes.count
                        cell.configureCell(id: GALLERY_CELL_ID + "\(indexPath.section).\(indexPath.row)",
                            username: user.displayName, affiliation: DataService.ds.GetSiteName(with: user.affiliation), project: project.name, avatar: user.avatarUrl, obsImage: observation.observationImageUrl, text: observation.observationText, num_likes: "\(numLikes)", num_dislikes: "\(numDislikes)", num_comments: "\(numComment)", date: observation.updatedAt, observation: observation, controller: self.parent!)
                    }
                }
            }
            return cell
        } else {
            return GalleryCell()
        }
    }
    
    public func reloadData() {
        galleryTable.reloadData()
    }
    
    @IBAction func showMoreTapped(_ sender: Any) {
        pages = pages + 1
        galleryTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? GalleryCell {
            self.parent!.performSegue(withIdentifier: SEGUE_DETAILS, sender: cell)
        }
    }
}
