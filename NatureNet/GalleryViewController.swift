//
//  GalleryViewController.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/16/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class GalleryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    // reference to the search textbox at the top
    @IBOutlet weak var searchBar: UISearchBar!
    // reference to the observation feed which is in a table view
    @IBOutlet weak var galleryTable: UITableView!
    // reference to the profile icon button on the top left corner
    @IBOutlet weak var profileButton: UIButton!
    
    var pages = 0
    var maxNV = 0
    var maxNB = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.galleryTable.delegate = self
        self.galleryTable.dataSource = self
        self.searchBar.delegate = self
    }

    // Whenever this view appears, it should update user's status on the profile icon on the top left corner.
    override func viewWillAppear(_ animated: Bool) {
        // set the status of the user (i.e signed in or not) on the profile icon
        if DataService.ds.LoggedIn() {
            profileButton.setImage(ICON_PROFILE_ONLINE, for: .normal)
        } else {
            profileButton.setImage(ICON_PROFILE_OFFLINE, for: .normal)
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let n = GALLERY_LIST_INIT_COUNT + pages * GALLERY_LIST_LOAD_MORE_COUNT
        let searchText = self.searchBar.text ?? ""
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
        if let cell = tableView.dequeueReusableCell(withIdentifier: "GalleryCell") as? GalleryCell {
            if maxNB && maxNV == indexPath.row {
                cell.configureCell(username: LISTS_SHOW_MORE_TEXT, affiliation: "", project: "", avatar: "", obsImage: "", text: "", num_likes: "", num_dislikes: "", num_comments: "", date: 0, isShowMore: true, observation: nil)
                return cell
            }
            let searchText = self.searchBar.text ?? ""
            if let observation = DataService.ds.GetObservation(at: indexPath.row, searchFilter: searchText) {
                if let user = DataService.ds.GetUser(by: observation.observer) {
                    if let project = DataService.ds.GetProject(by: observation.project) {
                        cell.configureCell(username: user.displayName, affiliation: DataService.ds.GetSiteName(with: user.affiliation), project: project.name, avatar: user.avatarUrl, obsImage: observation.observationImageUrl, text: observation.observationText, num_likes: "0", num_dislikes: "0", num_comments: "0", date: observation.updatedAt, isShowMore: false, observation: observation)
                    }
                }
            }
            return cell
        } else {
            return UITableViewCell()
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // reset the pages for each section
        self.pages = 0
        // hide the keyboard if the user cleared the text in the search bar
        if searchBar.text == nil || searchText == "" {
            searchBar.perform(#selector(resignFirstResponder), with: nil, afterDelay: 0.1)
        }
        // reload the data
        galleryTable.reloadData()
    }
    
    // When the profile button is tapped, we need to check if the user is authenticated, if not it should go to the sign in screen
    @IBAction func profileButtonTapped(_ sender: Any) {
        if DataService.ds.LoggedIn() {
            performSegue(withIdentifier: SEGUE_PROFILE, sender: nil)
        } else {
            performSegue(withIdentifier: SEGUE_SIGNIN, sender: nil)
        }
    }
    
    // In case we needed to go to the profile screen but authentication was required we need to go to the sign in screen and set the "parentVC" and the "successSegueId" so that when the sign in was successful the segue to the profile screen is performed
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            if id == SEGUE_SIGNIN {
                // the sign in screen is embedded in a nav controller
                let signInNav = segue.destination as! UINavigationController
                // and the nav controller has only one child i.e the sign in view controller
                let signInVC = signInNav.viewControllers.first as! SigninViewController
                signInVC.parentVC = self
                signInVC.successSegueId = SEGUE_PROFILE
            }
        }
    }
    
    // When seeing details of an observation, we need to check if the sender (the cell) is a "show more" cell or not. If so, then the transition is not possible, instead another "page" should be added to the data.
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == SEGUE_DETAILS {
            if let cell = sender as? GalleryCell {
                if cell.isShowMore {
                    pages = pages + 1
                    galleryTable.reloadData()
                    return false
                }
            }
        }
        return true
    }
    
    // remove the focus from the search bar if the user clicked on the cross button on the search bar. This will also causes the keyboard to hide.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}
