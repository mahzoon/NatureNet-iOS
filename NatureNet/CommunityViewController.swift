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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        communityTable.delegate = self
        communityTable.dataSource = self
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
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Aspen"
        } else if section == 1 {
            return "Anacostia"
        } else {
            return "Reedy Creek"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(COMMUNITY_CELL_ITEM_HEIGHT)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CommunityCell") as? CommunityCell {
            return cell
        } else {
            return UITableViewCell()
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text != nil && searchText != "" {
            //let lowerText = searchBar.text!.lowercased()
        } else {
            searchBar.perform(#selector(resignFirstResponder), with: nil, afterDelay: 0.1)
        }
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
    
    // remove the focus from the search bar if the user clicked on the cross button on the search bar. This will also causes the keyboard to hide.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}
