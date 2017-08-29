//
//  ExploreViewController.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/16/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class ExploreViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var mapSegmentView: UIView!
    @IBOutlet weak var listSegmentView: UIView!
    
    // reference to the search bar
    @IBOutlet weak var searchBar: UISearchBar!
    
    // reference to the profile icon button on the top left corner
    @IBOutlet weak var profileButton: UIButton!
    
    public var transitionItemId = ""
    
    var mapSegmentController: MapViewController!
    var listSegmentController: ListViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        hideKeyboardWhenTappedOutside()
        
        mapSegmentView.isHidden = true
        listSegmentView.isHidden = false
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
    
    override func viewDidAppear(_ animated: Bool) {
        if transitionItemId != "" {
            performSegue(withIdentifier: SEGUE_DETAILS, sender: nil)
        }
    }
    
        
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchText == "" {
            searchBar.perform(#selector(resignFirstResponder), with: nil, afterDelay: 0.1)
        }
        listSegmentController.searchText = searchText
        listSegmentController.reloadData()
        
        mapSegmentController.searchText = searchText
        mapSegmentController.reloadData()
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
            if id == SEGUE_EMBED_MAP {
                self.mapSegmentController = segue.destination as! MapViewController
            }
            if id == SEGUE_EMBED_LIST {
                self.listSegmentController = segue.destination as! ListViewController
            }
            if id == SEGUE_SIGNIN {
                // the sign in screen is embedded in a nav controller
                let signInNav = segue.destination as! UINavigationController
                // and the nav controller has only one child i.e the sign in view controller
                let signInVC = signInNav.viewControllers.first as! SigninViewController
                signInVC.parentVC = self
                signInVC.successSegueId = SEGUE_PROFILE
            }
            if id == SEGUE_DETAILS {
                if let dest = segue.destination as? GalleryDetailController {
                    if sender as? UITapGestureRecognizer != nil {
                        if let view = (sender as! UITapGestureRecognizer).view {
                            if let observationId = view.accessibilityIdentifier {
                                if let observation = DataService.ds.GetObservation(with: observationId) {
                                    dest.observationObj = observation
                                }
                            }
                        }
                    } else {
                        if let cell = sender as? GalleryCell {
                            dest.observationObj = cell.observation
                            dest.commentTextShouldBeSelected = cell.tappedCommentButton
                            cell.tappedCommentButton = false
                        } else {
                            if transitionItemId != "" {
                                if let observation = DataService.ds.GetObservation(with: transitionItemId) {
                                    dest.observationObj = observation
                                }
                                transitionItemId = ""
                            }
                        }
                    }
                }
            }
        }
    }
    
    // remove the focus from the search bar if the user clicked on the cross button on the search bar. This will also causes the keyboard to hide.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    @IBAction func segmentSelectionChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mapSegmentView.isHidden = true
            listSegmentView.isHidden = false
        case 1:
            mapSegmentView.isHidden = false
            listSegmentView.isHidden = true
        default:
            break;
        }
    }
}
