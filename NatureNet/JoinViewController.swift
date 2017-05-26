//
//  JoinViewController.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/15/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class JoinViewController: UITableViewController,
UIPickerViewDataSource, UIPickerViewDelegate,
UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var joinTableView: UITableView!
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var displayName: UITextField!
    @IBOutlet weak var fullName: UITextField!
    
    @IBOutlet weak var affiliationPicker: UIPickerView!
    
    var imagePicker: UIImagePickerController!
    var pickedImage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.affiliationPicker.delegate = self
        self.affiliationPicker.dataSource = self
        affiliationPicker.selectedRow(inComponent: 0)
        
        emailAddress.delegate = self
        password.delegate = self
        displayName.delegate = self
        fullName.delegate = self
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let scrollOffset = CGPoint(x: textField.frame.minX, y: self.view.frame.maxY - textField.frame.maxY)
        joinTableView.setContentOffset(scrollOffset, animated: true)
        
        let cell = textField.superview?.superview
        if let _cell = cell as? UITableViewCell {
            if let _idx = joinTableView.indexPath(for: _cell) {
                joinTableView.scrollToRow(at: _idx, at: UITableViewScrollPosition.top, animated: true)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailAddress {
            self.password.becomeFirstResponder()
        } else if textField == self.password {
            self.displayName.becomeFirstResponder()
        } else if textField == self.displayName {
            self.fullName.becomeFirstResponder()
        } else {
            self.view.endEditing(true)
        }
        return true
    }
    
    // the affiliation picker has only one section
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // returns the number of options for affiliation picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // considering the [no selection] option we have sites + 1 objects to return
        return DataService.ds.GetNumSites() + 1
    }
    
    // returns the values for options of affiliation picker
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // the first option is [no selection]
        if row == 0 {
            return PICKER_NO_SELECTION
        } else {
            return DataService.ds.GetSiteNames()[row-1]
        }

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePicker.dismiss(animated: true, completion: {
                self.profileImage.image = pickedImage
                self.pickedImage = true
            })
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func profileButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: JOIN_PROFILE_IMAGE_OPTIONS_TITLE, message: JOIN_PROFILE_IMAGE_OPTIONS_MSG, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: JOIN_PROFILE_IMAGE_OPTIONS_CANCEL, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: JOIN_PROFILE_IMAGE_OPTIONS_PICK_EXISTING, style: .default, handler: { (action: UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
                self.present(self.imagePicker, animated: true, completion: nil)
            } else {
                UtilityFunctions.showErrorMessage(theView: self, title: JOIN_PROFILE_IMAGE_OPTIONS_ERR_LIB_TITLE, message: JOIN_PROFILE_IMAGE_OPTIONS_ERR_LIB_MSG, buttonText: JOIN_PROFILE_IMAGE_OPTIONS_ERR_LIB_BTN_TXT)
            }
        }))
        alert.addAction(UIAlertAction(title: JOIN_PROFILE_IMAGE_OPTIONS_TAKE_NEW, style: .default, handler: { (action: UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
                self.present(self.imagePicker, animated: true, completion: nil)
            } else {
                UtilityFunctions.showErrorMessage(theView: self, title: JOIN_PROFILE_IMAGE_OPTIONS_ERR_CAM_TITLE, message: JOIN_PROFILE_IMAGE_OPTIONS_ERR_CAM_MSG, buttonText: JOIN_PROFILE_IMAGE_OPTIONS_ERR_CAM_BTN_TXT)
            }
        }))
        if pickedImage {
            alert.addAction(UIAlertAction(title: JOIN_PROFILE_IMAGE_OPTIONS_REMOVE_CURRENT, style: .destructive, handler: { (action: UIAlertAction) in
                self.profileImage.image = UIImage(named: JOIN_PROFILE_IMAGE)
                self.pickedImage = false
            }))
        }
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func joinButtonTapped(_ sender: Any) {
        
        // validation check
        if let email = self.emailAddress.text, let pass = self.password.text,
            let display_name = self.displayName.text, let full_name = self.fullName.text,
        affiliationPicker.selectedRow(inComponent: 0) > 0 {
            
        // upload image to Cloudinary (if selected)
        if pickedImage {
            if let img = self.profileImage.image {
                MediaManager.md.uploadImage(image: img, progressHandler: nil, completionHandler: { result, error in
                    if let e = error {
                        // completed but with error
                        UtilityFunctions.showErrorMessage(theView: self, title: "", message: "" + e.localizedDescription, buttonText: "")
                    } else {
                        // completed successfully
                        if let r = result {
                            if let url = r.secureUrl {
                                self.trySubmitJoinRequest(iconUrl: url, email: email, pass: pass, display_name: display_name, full_name: full_name)
                            }
                        }
                    }
                })
            }
        } else {
            self.trySubmitJoinRequest(iconUrl: "", email: email, pass: pass, display_name: display_name, full_name: full_name)
        }
            
            
        } else {
            UtilityFunctions.showErrorMessage(theView: self, title: JOIN_ERROR_VALIDATION_TITLE, message: JOIN_ERROR_VALIDATION_MESSAGE, buttonText: JOIN_ERROR_VALIDATION_BUTTON_TEXT)
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true) {}
    }
    
    func trySubmitJoinRequest(iconUrl: String, email: String, pass: String, display_name: String, full_name: String) {
        if let affiliation = DataService.ds.GetSiteId(by: affiliationPicker.selectedRow(inComponent: 0)) {
            let user = NNUser(affiliation: affiliation, icon: iconUrl, id: "", bio: "", latestContrib: 0, name: display_name, groups: [String : AnyObject](), created: 0, updated: 0)
            DataService.ds.Join(nnuser: user, email: email, pass: pass, fullName: full_name, completion: { wasSuccess, err in
                if wasSuccess {
                    // this is actually a welcome message, not an error!
                    UtilityFunctions.showErrorMessage(theView: self, title: JOIN_SUCCESS_TITLE, message: JOIN_SUCCESS_MESSAGE, buttonText: JOIN_SUCCESS_BUTTON_TEXT)
                    self.dismiss(animated: true) {}
                } else {
                    UtilityFunctions.showErrorMessage(theView: self, title: JOIN_ERRORS_TITLE, message: err, buttonText: JOIN_ERRORS_BUTTON_TEXT)
                }
            })
        }
    }
}
