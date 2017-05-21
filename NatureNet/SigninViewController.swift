//
//  SigninViewController.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/15/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class SigninViewController: UITableViewController, UITextFieldDelegate {

    // reference to the email text box
    @IBOutlet weak var emailAddress: UITextField!
    // reference to the password text box
    @IBOutlet weak var password: UITextField!
    // reference to the table view containing textboxes for sign in
    @IBOutlet var signInTableView: UITableView!
    
    // reference to the main window that opened this signin window, this will be set in the "prepare for segue" function in the main controller. (before this view appears) The main controller could be any view that needs authentication.
    var parentVC: UIViewController?
    // This variable is set by the main view controller (the caller) to contain the segue identifier which is performed in case of success authentication
    var successSegueId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailAddress.delegate = self
        password.delegate = self
        
        // when user taps outside the textbox area the keyboard should disappear
        hideKeyboardWhenTappedOutside()
    }
    
    // When this view is appeared, if the user is already signed in, dismiss this view
    override func viewWillAppear(_ animated: Bool) {
        if DataService.ds.LoggedIn() {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // This simulates a behavior similar to having "tab" for a real keyboard when interacting with textboxes
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // if the "next" button clicked and email is under focus, then the next focus should be the password textbox
        if textField == self.emailAddress {
            // set focus to the password text box
            self.password.becomeFirstResponder()
        } else {
            // if the last item has focus then "next" should finish editing and make the keyboard disappear
            self.view.endEditing(true)
        }
        return true
    }
    
    // This scrolls the text box up if it will be obscured under the keyboard when the keyboard appears
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let scrollOffset = CGPoint(x: textField.frame.minX, y: self.view.frame.maxY - textField.frame.maxY)
        signInTableView.setContentOffset(scrollOffset, animated: true)
        
        // we need to get a reference to the cell in the table view, the cell has a container view and the text box is in the container view, so we need two "superview"
        let cell = textField.superview?.superview
        if let _cell = cell as? UITableViewCell {
            if let _idx = signInTableView.indexPath(for: _cell) {
                signInTableView.scrollToRow(at: _idx, at: UITableViewScrollPosition.top, animated: true)
            }
        }
    }

    // This is called when the user taps the sign in button
    @IBAction func submitSignIn(_ sender: Any) {
        // proceed with sign in if email and password text boxes are not empty
        if let email = emailAddress.text, email != "" {
            if let pass = password.text, pass != "" {
                DataService.ds.Authenticate(email: email, pass: pass, completion: { wasSuccess, err in
                    if wasSuccess {
                        // if authentication was successful then go to the explore screen. To do this we need to dismiss this view and upon completion ask the parent (main controller) to perform the segue to the explore screen
                        self.dismiss(animated: true) {
                            if let p = self.parentVC, let segueId = self.successSegueId  {
                                p.performSegue(withIdentifier: segueId, sender: nil)
                            }
                        }
                    } else {
                        UtilityFunctions.showErrorMessage(theView: self, title: SIGN_IN_ERRORS_TITLE, message: err, buttonText: SIGN_IN_ERRORS_BUTTON_TEXT)
                    }
                })
            } else {
                UtilityFunctions.showErrorMessage(theView: self, title: SIGN_IN_ERRORS_TITLE, message: SIGN_IN_NO_PASSWORD_PROVIDED, buttonText: SIGN_IN_ERRORS_BUTTON_TEXT)
            }
        } else {
            UtilityFunctions.showErrorMessage(theView: self, title: SIGN_IN_ERRORS_TITLE, message: SIGN_IN_NO_EMAIL_PROVIDED, buttonText: SIGN_IN_ERRORS_BUTTON_TEXT)
        }
    }
    
    // This is called when the user taps the cancel button which just dismisses this view
    @IBAction func cancelSignIn(_ sender: Any) {
        self.dismiss(animated: true) {}
    }
}
