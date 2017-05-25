//
//  DesignIdeasViewController.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/16/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class DesignIdeasViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    // reference to the search textbox at the top of the view
    @IBOutlet weak var searchBar: UISearchBar!
    // reference to the design ideas list in the tableview
    @IBOutlet weak var designIdeasTable: UITableView!
    // reference to the profile icon button on the top left corner
    @IBOutlet weak var profileButton: UIButton!
    
    var pages = 0
    var maxNV = 0
    var maxNB = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        designIdeasTable.delegate = self
        designIdeasTable.dataSource = self
        searchBar.delegate = self
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
        let n = DESIGN_IDEA_LIST_INIT_COUNT + pages * DESIGN_IDEA_LIST_LOAD_MORE_COUNT
        let searchText = self.searchBar.text ?? ""
        let total = DataService.ds.GetNumDesignIdeas(searchFilter: searchText)
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
        return CGFloat(DESIGN_IDEA_CELL_ITEM_HEIGHT)
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
        
        // the case which we should dequeue a regular cell (DesignIdeasCell)
        if let cell = tableView.dequeueReusableCell(withIdentifier: DESIGN_IDEAS_CELL_ID) as? DesignIdeasCell {
            let searchText = self.searchBar.text ?? ""
            if let idea = DataService.ds.GetDesignIdea(at: indexPath.row, searchFilter: searchText) {
                if let user = DataService.ds.GetUser(by: idea.submitter) {
                    let numComment = DataService.ds.GetCommentsOnDesignIdea(with: idea.id).count
                    let numLikes = idea.Likes.count
                    let numDislikes = idea.Dislikes.count
                    cell.configureCell(id: DESIGN_IDEAS_CELL_ID + "\(indexPath.section).\(indexPath.row)",
                        username: user.displayName, affiliation: DataService.ds.GetSiteName(with: user.affiliation), avatar: user.avatarUrl, text: idea.content, num_likes: "\(numLikes)", num_dislikes: "\(numDislikes)", num_comments: "\(numComment)", status: idea.status, date: idea.updatedAt, designIdea: idea, controller: self)
                }
            }
            return cell
        } else {
            return DesignIdeasCell()
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
        designIdeasTable.reloadData()
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
            if id == SEGUE_DETAILS {
                if let cell = sender as? DesignIdeasCell {
                    if let dest = segue.destination as? DesignIdeaDetailController {
                        dest.designIdea = cell.designIdea
                    }
                }
            }
        }
    }
    
    // remove the focus from the search bar if the user clicked on the cross button on the search bar. This will also causes the keyboard to hide.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    @IBAction func showMoreTapped(_ sender: Any) {
        pages = pages + 1
        designIdeasTable.reloadData()
    }
    
}
