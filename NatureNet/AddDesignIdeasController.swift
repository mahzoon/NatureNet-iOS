//
//  AddDesignIdeasController.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/17/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class AddDesignIdeasController: UITableViewController {

    @IBOutlet weak var ideaText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ideaText.becomeFirstResponder()
        if !DataService.ds.LoggedIn() {
            UtilityFunctions.showAuthenticationRequiredMessage(theView: self, completion: { 
                self.performSegue(withIdentifier: SEGUE_SIGNIN, sender: nil)
            })
        }
    }

    @IBAction func addButtonTapped(_ sender: Any) {
        if !DataService.ds.LoggedIn() {
            UtilityFunctions.showAuthenticationRequiredMessage(theView: self, completion: {
                self.performSegue(withIdentifier: SEGUE_SIGNIN, sender: nil)
            })
        } else {
            if ideaText.text == "" {
                UtilityFunctions.showErrorMessage(theView: self, title: DESIGNIDEA_EMPTY_ERROR_TITLE,
                                                  message: DESIGNIDEA_EMPTY_ERROR_MESSAGE,
                                                  buttonText: DESIGNIDEA_EMPTY_ERROR_BUTTON_TEXT)
            } else {
                if let currentUserId = DataService.ds.GetCurrentUserId() {
                    let idea = NNDesignIdea(submitter: currentUserId, content: ideaText.text, id: "", created: 0, updated: 0, status: DESIGN_IDEA_STATUS_DISCUSSING, type: DESIGN_IDEA_TYPE, group: DESIGN_IDEA_GROUP, likes: [String : Bool]())
                    DataService.ds.AddDesignIdea(idea: idea)
                }
                // this is not an error message! actually a thank you message!!
                UtilityFunctions.showErrorMessage(theView: self, title: ADD_IDEA_SUCCESS_TITLE,
                                                  message: ADD_IDEA_SUCCESS_MESSAGE,
                                                  buttonText: ADD_IDEA_SUCCESS_BUTTON_TEXT)
                self.dismiss(animated: true) {}
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true) {}
    }
}
