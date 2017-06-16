//
//  CommunityViewController.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/16/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class CommunityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    // reference to the search text box at the top of the view
    @IBOutlet weak var searchBar: UISearchBar!
    // reference to the list of members in the table
    @IBOutlet weak var communityTable: UITableView!
    // reference to the profile icon button on the top left corner
    @IBOutlet weak var profileButton: UIButton!
    
    // the page values for each section is stored in "pages". An example of the contents would be: pages[0] = 3. This means that we are displaying 3 pages of users associated with the first site i.e: "aspen". The actual number of users that are shown in the example is equal to 3 * COMMUNITY_LIST_LOAD_MORE_COUNT + COMMUNITY_LIST_INIT_COUNT
    var pages = [Int: Int]()
    // maxNV is a dictionary of number of cells currently shown in each section. maxNV[1] = 2 means that in section 1 two pages of cells (2* COMMUNITY_LIST_LOAD_MORE_COUNT + COMMUNITY_LIST_INIT_COUNT cells) are currently being displayed.
    var maxNV = [Int: Int]()
    // maxNB states that if all possible cells for each section is being displayed or not. For example, maxNB[0] = false means that in section 0 (first section) we are not showing all possible items (i.e we have "show more" button being displayed in the first section).
    var maxNB = [Int: Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        communityTable.delegate = self
        communityTable.dataSource = self
        searchBar.delegate = self
        
        DataService.ds.registerTableView(group: DB_USERS_PATH, tableView: communityTable)
        
        hideKeyboardWhenTappedOutside()
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
    
    // returns the number of sections in the tableview which is equal to the number of sites
    func numberOfSections(in tableView: UITableView) -> Int {
        return DataService.ds.GetNumSites()
    }
    
    // The title of each section of the tableview is site name.
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return DataService.ds.GetSiteNames()[section]
    }
    
    // returns number of items in each section. To calculate this we need to look at the "pages" variable.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var n = COMMUNITY_LIST_INIT_COUNT
        if let page_section = self.pages[section] {
            n = n + page_section * COMMUNITY_LIST_LOAD_MORE_COUNT
        }
        let searchText = self.searchBar.text ?? ""
        let total = DataService.ds.GetNumUsers(in: section, searchFilter: searchText)
        var ret_val = 0
        if n < total {
            maxNV[section] = n
            maxNB[section] = true
            ret_val = n + 1
        } else {
            maxNV[section] = total
            maxNB[section] = false
            ret_val = total
        }
        return ret_val
    }
    
    // returns the height of each project cell which is equal to COMMUNITY_CELL_ITEM_HEIGHT
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(COMMUNITY_CELL_ITEM_HEIGHT)
    }
    
    // this is the main function for the tableview to draw each cell based on the provided data.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: COMMUNITY_CELL_ID) as? CommunityCell {
            if let more = maxNB[indexPath.section], more {
                if let n = maxNV[indexPath.section], indexPath.row == n {
                    cell.configureCell(id: COMMUNITY_CELL_ID, name: LISTS_SHOW_MORE_TEXT, icon: "", useDefaultIcon: false, isShowMore: true, section: indexPath.section, user: nil)
                    return cell
                }
            }
            let searchText = self.searchBar.text ?? ""
            if let user = DataService.ds.GetUser(in: indexPath.section, at: indexPath.row, searchFilter: searchText) {
                cell.configureCell(id: COMMUNITY_CELL_ID + "\(indexPath.section).\(indexPath.row)",
                    name: user.displayName, icon: user.avatarUrl, useDefaultIcon: false, isShowMore: false, section: indexPath.section, user: user)
            }
            return cell
        } else {
            return UITableViewCell()
        }
        
    }
    
    // this function is being called every time the user types anything in the search bar.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // reset the pages for each section
        pages.removeAll()
        // hide the keyboard if the user cleared the text in the search bar
        if searchBar.text == nil || searchText == "" {
            searchBar.perform(#selector(resignFirstResponder), with: nil, afterDelay: 0.1)
        }
        // reload the data
        communityTable.reloadData()
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
                if let cell = sender as? CommunityCell, !cell.isShowMore {
                    if let dest = segue.destination as? CommunityDetailController {
                        dest.user = cell.user
                    }
                }
            }
        }
    }
    
    // When seeing details info of a user, we need to check if the sender (the cell) is a "show more" cell or not. If so, then the transition is not possible, instead another "page" should be added to the data.
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == SEGUE_DETAILS {
            if let cell = sender as? CommunityCell {
                if cell.isShowMore {
                    if let p = pages[cell.sectionIndex] {
                        pages[cell.sectionIndex] = p + 1
                    } else {
                        pages[cell.sectionIndex] = 1
                    }
                    communityTable.reloadSections([cell.sectionIndex], with: .automatic)
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
