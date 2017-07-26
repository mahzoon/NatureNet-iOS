//
//  ViewController.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/15/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    // activity indicator for loading observations
    var activityIndicator = UIActivityIndicatorView()
    var progressBar = UIProgressView()
    var connectionTimer = Timer()
    
    var connectionMessage = UIAlertController(title: OFFLINE_WARNING_TITLE, message: OFFLINE_WARNING_MESSAGE, preferredStyle: .alert)
    var messageIsShowing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        connectionMessage.addAction(UIAlertAction(title: OFFLINE_WARNING_BUTTON_TEXT, style: .cancel, handler: { (UIAlertAction) in
            self.messageIsShowing = false
            UIApplication.shared.beginIgnoringInteractionEvents()
        }))
        
        activityIndicator.frame = self.view.frame
        //activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.layer.backgroundColor = UIColor(white: 0, alpha: ACTIVITY_INDICATOR_OPACITY).cgColor
        progressBar.frame = CGRect(x: self.view.frame.width / 3,
                                   y: self.view.center.y + 50,
                                   width: self.view.frame.width / 3,
                                   height: 5)
        progressBar.progress = 0
        progressBar.progressTintColor = UIColor.white
        activityIndicator.addSubview(progressBar)
        self.view.addSubview(activityIndicator)
    }

    // when the main view appears, we need to check if the user logged in.
    // if the user is already logged in (from a previous session), then we go straight into "explore" screen
    override func viewDidAppear(_ animated: Bool) {
        if DataService.ds.LoggedIn() {
            self.presentExploreScreen()
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
        }
    }
    
    @IBAction func exploreButtonTapped(_ sender: Any) {
        self.presentExploreScreen()
    }
    
    func presentExploreScreen() {
        
        // start activity spinner
        self.activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        DataService.ds.initializeObservers { success in
            if self.progressBar.progress == 1.0 {
                return
            }
            self.progressBar.progress = self.progressBar.progress + 1.0/6.0
            if self.progressBar.progress == 1.0 {
                self.connectionTimer.invalidate()
                if self.messageIsShowing {
                    self.connectionMessage.dismiss(animated: true, completion: { 
                        // stop activity spinner
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        self.performSegue(withIdentifier: SEGUE_EXPLORE, sender: nil)
                    })
                } else {
                    // stop activity spinner
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.performSegue(withIdentifier: SEGUE_EXPLORE, sender: nil)
                }
            }
        }
        
        connectionTimer = Timer.scheduledTimer(timeInterval: 5, target: self,
                                               selector: #selector(self.CheckConnection),
                                               userInfo: nil, repeats: true)
    }
    
    func CheckConnection() {
        if self.progressBar.progress < 1.0 {
            if !DataService.ds.IsConnected() && !self.messageIsShowing {
                self.present(connectionMessage, animated: true, completion: {
                    self.messageIsShowing = true
                    UIApplication.shared.endIgnoringInteractionEvents()
                })
                return
            }
        }
    }
}

