//
//  AddDesignIdeasController.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/17/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class AddDesignIdeasController: UITableViewController, UITextViewDelegate {

    // top description for adding idea
    @IBOutlet weak var ideaDescription: UITextView!
    // the entire tableview
    @IBOutlet var addIdeaTableView: UITableView!
    
    var categories = [String]()
    var switchValues = [Int: Bool]()
    var designIdeaText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ideaText.becomeFirstResponder()
        if !DataService.ds.LoggedIn() {
            UtilityFunctions.showAuthenticationRequiredMessage(theView: self, completion: { 
                self.performSegue(withIdentifier: SEGUE_SIGNIN, sender: nil)
            })
        }
        categories = DESIGN_IDEA_All_TYPES
        hideKeyboardWhenTappedOutside()
        ideaDescription.attributedText = ADD_DESIGN_IDEA_DESCRIPTION()
        
        for (index, _) in categories.enumerated() {
            switchValues[index] = false
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addIdeaTableView.FixHeaderLayout()
    }
    
    // returns the height of each cell
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return CGFloat(ADD_DESIGNIDEA_DESCRIPTION_CELL_HEIGHT)
        }
        return CGFloat(ADD_DESIGNIDEA_CATEGORY_CELL_HEIGHT)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        if section == 1 {
            return categories.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(ADD_DESIGNIDEA_HEADER_CELL_HEIGHT)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return DESIGNIDEA_TEXT
        }
        if section == 1 {
            return DESIGNIDEA_CATEGORY_TEXT
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return DESIGNIDEA_TEXT_INSTRUCTIONS
        }
        if section == 1 {
            return DESIGNIDEA_CATEGORIES_INSTRUCTIONS
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: TEXT_VIEW_CELL_ID) as? TextViewCell {
                cell.configureCell()
                cell.textBox.delegate = self
                return cell
            } else {
                return TextViewCell()
            }
        }
        if indexPath.section == 1 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: SITE_SWITCH_CELL_ID) as? SiteSwitchCell {
                if let val = switchValues[indexPath.row] {
                    cell.configureCell(siteName: categories[indexPath.row], value: val, index: indexPath.row)
                } else {
                    cell.configureCell(siteName: categories[indexPath.row], value: false, index: indexPath.row)
                }
                return cell
            } else {
                return SiteSwitchCell()
            }
        }
        return UITableViewCell()
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        view.endEditing(true)
        if !DataService.ds.LoggedIn() {
            UtilityFunctions.showAuthenticationRequiredMessage(theView: self, completion: {
                self.performSegue(withIdentifier: SEGUE_SIGNIN, sender: nil)
            })
        } else {
            if designIdeaText == "" {
                UtilityFunctions.showErrorMessage(theView: self, title: DESIGNIDEA_EMPTY_ERROR_TITLE,
                                                  message: DESIGNIDEA_EMPTY_ERROR_MESSAGE,
                                                  buttonText: DESIGNIDEA_EMPTY_ERROR_BUTTON_TEXT)
            } else {
                if let currentUserId = DataService.ds.GetCurrentUserId() {
                    let idea = NNDesignIdea(submitter: currentUserId, content: designIdeaText, id: "", created: 0, updated: 0, status: DESIGN_IDEA_STATUS_DISCUSSING, type: getCheckedCategories(), group: DESIGN_IDEA_GROUP, likes: [String : Bool]())
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
    
    func getCheckedCategories() -> String {
        var selectedCategories = ""
        for (index, category) in categories.enumerated() {
            if let b = switchValues[index], b {
                if selectedCategories != "" {
                    selectedCategories = selectedCategories + ", "
                }
                selectedCategories = selectedCategories + category
            }
        }
        return selectedCategories
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true) {}
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.designIdeaText = textView.text
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        switchValues[sender.tag] = sender.isOn
    }
}
