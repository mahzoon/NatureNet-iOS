//
//  ViewController.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/15/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // when the main view appears, we need to check if the user logged in.
    // if the user is already logged in (from a previous session), then we go straight into "explore" screen
    override func viewDidAppear(_ animated: Bool) {
        if DataService.ds.LoggedIn() {
            performSegue(withIdentifier: SEGUE_EXPLORE, sender: nil)
        }
    }
    
    // when the signin screen appears, if the signin was successful, we need to come back to this controller and perform a segue to the explore screen. We need to pass "self" to the sign in controller so that it can perform the segue in case sign in was successful
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            if id == SEGUE_SIGNIN {
                // the sign in screen is embedded in a nav controller
                let signInNav = segue.destination as! UINavigationController
                // and the nav controller has only one child i.e the sign in view controller
                let signInVC = signInNav.viewControllers.first as! SigninViewController
                signInVC.parentVC = self
                signInVC.successSegueId = SEGUE_EXPLORE
            }
            if id == SEGUE_EXPLORE {
                DataService.ds.initializeObservationsObserver()
            }
        }
    }
    
}

