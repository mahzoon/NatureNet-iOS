//
//  ProfileViewController.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/17/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class ProfileViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate,
UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileTableView: UITableView!
    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var displayName: UITextField!
    @IBOutlet weak var fullName: UITextField!
    
    @IBOutlet weak var affiliationPicker: UIPickerView!
    
    var imagePicker: UIImagePickerController!
    var pickedImage = false
    
    var user: NNUser?

    override func viewDidLoad() {
        super.viewDidLoad()
        affiliationPicker.delegate = self
        affiliationPicker.dataSource = self
        affiliationPicker.selectedRow(inComponent: 0)
        
        emailAddress.delegate = self
        password.delegate = self
        displayName.delegate = self
        fullName.delegate = self
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
        
        self.user = DataService.ds.GetCurrentUser()
        
        self.displayName.text = user?.displayName
        self.emailAddress.text = DataService.ds.GetCurrentUserEmail()
        if let affiliationId = self.user?.affiliation {
            let affiliationName = DataService.ds.GetSiteName(with: affiliationId)
            if let index = DataService.ds.GetSiteNames().index(of: affiliationName) {
                self.affiliationPicker.selectRow(index + 1, inComponent: 0, animated: true)
            } else {
                self.affiliationPicker.selectRow(0, inComponent: 0, animated: true)
            }
        } else {
            self.affiliationPicker.selectRow(0, inComponent: 0, animated: true)
        }
        DataService.ds.GetCurrentUserFullName { success, result in
            if success {
                self.fullName.text = result
            }
        }
        self.profileImage.image = ICON_DEFAULT_USER_AVATAR
        if let u = self.user {
            // requesting the avatar icon
            MediaManager.md.getOrDownloadIcon(requesterId: "ProfileViewController", urlString: u.avatarUrl, completion: { img, err in
                if let i = img {
                    DispatchQueue.main.async {
                        self.profileImage.image = i
                    }
                }
            })
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let scrollOffset = CGPoint(x: textField.frame.minX, y: self.view.frame.maxY - textField.frame.maxY)
        profileTableView.setContentOffset(scrollOffset, animated: true)
        
        let cell = textField.superview?.superview
        if let _cell = cell as? UITableViewCell {
            if let _idx = profileTableView.indexPath(for: _cell) {
                profileTableView.scrollToRow(at: _idx, at: UITableViewScrollPosition.top, animated: true)
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
    
    // This function is called when the user picked the image from the library. After picking the image we need to change the avatar icon (here called "profileButton") to the new image.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePicker.dismiss(animated: true, completion: {
                self.profileImage.image = pickedImage
                self.pickedImage = true
            })
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    // This function is called when the avatar icon is tapped. Tapping the icon will bring up a prompt asking if the user wants to choose from an existing photo from the library or take a new one using the camera. In case the photo is already selected the user has the option to remove the photo (the icon switches to the default avatar)
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
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = self.profileImage
            popoverPresentationController.sourceRect = self.profileImage.bounds
        }
        present(alert, animated: true, completion: nil)
    }
    
    // When signing out, if successful, dismiss to the caller view, else show the error message
    @IBAction func signOutTapped(_ sender: Any) {
        let (result, result_str) = DataService.ds.SignOut()
        if !result {
            UtilityFunctions.showErrorMessage(theView: self, title: PROFILE_ERRORS_TITLE, message: result_str, buttonText: PROFILE_ERRORS_BUTTON_TEXT)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        self.dismiss(animated: true) {}
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true) {}
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            if id == SEGUE_MY_OBSERVATIONS {
                if let dest = segue.destination as? MyObservationsController {
                    dest.user = self.user
                }
            }
            if id == SEGUE_MY_DESIGNIDEAS {
                
            }
            if id == SEGUE_MY_PROJECTS {
                
            }
        }
    }
}
