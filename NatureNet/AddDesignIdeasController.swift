//
//  AddDesignIdeasController.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/17/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class AddDesignIdeasController: UITableViewController {

    @IBOutlet weak var ideaDescription: UITextView!
    @IBOutlet weak var ideaText: UITextView!
    
    @IBOutlet var addIdeaTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ideaText.becomeFirstResponder()
        if !DataService.ds.LoggedIn() {
            UtilityFunctions.showAuthenticationRequiredMessage(theView: self, completion: { 
                self.performSegue(withIdentifier: SEGUE_SIGNIN, sender: nil)
            })
        }
        hideKeyboardWhenTappedOutside()
        ideaDescription.attributedText = ADD_DESIGN_IDEA_DESCRIPTION()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addIdeaTableView.FixHeaderLayout()
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        view.endEditing(true)
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
                    DataService.ds.AddDesignIdea(idea: idea, completion: { success in
                        if (success) {
                            let alert = UIAlertController(title: ADD_IDEA_SUCCESS_TITLE, message: ADD_IDEA_SUCCESS_MESSAGE, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: ADD_IDEA_SUCCESS_BUTTON_TEXT, style: .default, handler: { val in
                                self.dismiss(animated: true) {}
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                    })
                }
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true) {}
    }
}
