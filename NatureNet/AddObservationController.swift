//
//  AddObservationController.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/17/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit
import MapKit

class AddObservationController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate,
UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var observationTableView: UITableView!
    
    @IBOutlet weak var observationImageButton: UIButton!
    @IBOutlet weak var observationImage: UIImageView!
    
    @IBOutlet weak var descriptionText: UITextField!
    @IBOutlet weak var locationText: UITextField!
    
    @IBOutlet weak var projectPicker: UIPickerView!
    
    var imagePicker: UIImagePickerController!
    var pickedImage = false
    
    var pickedImageLocation: CLLocationCoordinate2D?
    
    var projectList = [NNProject]()
    
    // activity indicator for upload
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        projectPicker.delegate = self
        projectPicker.dataSource = self
        projectPicker.selectedRow(inComponent: 0)
        
        descriptionText.delegate = self
        locationText.delegate = self
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        if !DataService.ds.LoggedIn() {
            UtilityFunctions.showAuthenticationRequiredMessage(theView: self, completion: {
                self.performSegue(withIdentifier: SEGUE_SIGNIN, sender: nil)
            })
        }
        
        projectList = DataService.ds.GetAllProjects()
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .gray
        self.view.addSubview(activityIndicator)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let scrollOffset = CGPoint(x: textField.frame.minX, y: self.view.frame.maxY - textField.frame.maxY)
        observationTableView.setContentOffset(scrollOffset, animated: true)
        
        let cell = textField.superview?.superview
        if let _cell = cell as? UITableViewCell {
            if let _idx = observationTableView.indexPath(for: _cell) {
                observationTableView.scrollToRow(at: _idx, at: UITableViewScrollPosition.top, animated: true)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.descriptionText {
            self.locationText.becomeFirstResponder()
        } else {
            self.view.endEditing(true)
        }
        return true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // the first item would be "select a project"
        return projectList.count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return PICKER_NO_SELECTION
        }
        if row - 1 < projectList.count {
            return projectList[row - 1].name
        }
        return nil
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if picker.sourceType == UIImagePickerControllerSourceType.camera {
                MediaManager.md.saveImageToPhotosLib(img: pickedImage, completion: { success, error, loc in
                    self.pickedImageLocation = loc
                    if !success {
                        let ac = UIAlertController(title: SAVE_OBSV_ERROR_MESSAGE, message: error, preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: SAVE_OBSV_ERROR_BUTTON_TEXT, style: .default))
                        self.present(ac, animated: true)
                    }
                })
            }
            if picker.sourceType == UIImagePickerControllerSourceType.photoLibrary {
                imagePicker.dismiss(animated: true, completion: {
                    self.observationImage.image = pickedImage
                    self.pickedImage = true
                    if let url = info[UIImagePickerControllerReferenceURL] as? URL {
                        self.pickedImageLocation = MediaManager.md.getImageCoordinates(url: url)
                    }
                })
            }
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func observationImageButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: ADD_OBSV_IMAGE_OPTIONS_TITLE, message: ADD_OBSV_IMAGE_OPTIONS_MSG, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: ADD_OBSV_IMAGE_OPTIONS_CANCEL, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: ADD_OBSV_IMAGE_OPTIONS_PICK_EXISTING, style: .default, handler: { (action: UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
                self.present(self.imagePicker, animated: true, completion: nil)
            } else {
                UtilityFunctions.showErrorMessage(theView: self, title: ADD_OBSV_IMAGE_OPTIONS_ERR_LIB_TITLE, message: ADD_OBSV_IMAGE_OPTIONS_ERR_LIB_MSG, buttonText: ADD_OBSV_IMAGE_OPTIONS_ERR_LIB_BTN_TXT)
            }
        }))
        alert.addAction(UIAlertAction(title: ADD_OBSV_IMAGE_OPTIONS_TAKE_NEW, style: .default, handler: { (action: UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
                self.present(self.imagePicker, animated: true, completion: nil)
            } else {
                UtilityFunctions.showErrorMessage(theView: self, title: ADD_OBSV_IMAGE_OPTIONS_ERR_CAM_TITLE, message: ADD_OBSV_IMAGE_OPTIONS_ERR_CAM_MSG, buttonText: ADD_OBSV_IMAGE_OPTIONS_ERR_CAM_BTN_TXT)
            }
        }))
        if pickedImage {
            alert.addAction(UIAlertAction(title: ADD_OBSV_IMAGE_OPTIONS_REMOVE_CURRENT, style: .destructive, handler: { (action: UIAlertAction) in
                self.observationImage.image = UIImage(named: ADD_OBSV_IMAGE)
                self.pickedImage = false
            }))
        }
        present(alert, animated: true, completion: nil)
    }

    @IBAction func addButtonTapped(_ sender: Any) {
        if !DataService.ds.LoggedIn() {
            UtilityFunctions.showAuthenticationRequiredMessage(theView: self, completion: {
                self.performSegue(withIdentifier: SEGUE_SIGNIN, sender: nil)
            })
        } else {
            // validation checks
            if !pickedImage {
                UtilityFunctions.showErrorMessage(theView: self, title: OBSERVATION_NO_IMAGE_ERROR_TITLE,
                                                  message: OBSERVATION_NO_IMAGE_ERROR_MESSAGE,
                                                  buttonText: OBSERVATION_NO_IMAGE_ERROR_BUTTON_TEXT)
            } else if projectPicker.selectedRow(inComponent: 0) == 0 {
                UtilityFunctions.showErrorMessage(theView: self, title: OBSERVATION_NO_PROJECT_ERROR_TITLE,
                                                  message: OBSERVATION_NO_PROJECT_ERROR_MESSAGE,
                                                  buttonText: OBSERVATION_NO_PROJECT_ERROR_BUTTON_TEXT)
            } else {
                
                var data = ["text": self.descriptionText.text ?? "", "image": ""]
                // upload image to Cloudinary
                if let img = self.observationImage.image {
                    // start activity spinner
                    self.activityIndicator.startAnimating()
                    UIApplication.shared.beginIgnoringInteractionEvents()
                    MediaManager.md.uploadImage(image: img, progressHandler: { (Progress) in
                        // progress handler
                    }, completionHandler: { result, error in
                        // stop activity spinner
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        if let e = error {
                            // completed but with error
                            UtilityFunctions.showErrorMessage(theView: self, title: ADD_OBSV_UPLOAD_FAILED_TITLE, message: ADD_OBSV_UPLOAD_FAILED_MESSAGE + e.localizedDescription, buttonText: ADD_OBSV_UPLOAD_FAILED_BUTTON_TEXT)
                        } else {
                            // completed successfully
                            if let r = result {
                                data["image"] = r.secureUrl
                                // send to Firebase
                                if let currentUser = DataService.ds.GetCurrentUser() {
                                    if let projectId = self.projectList[self.projectPicker.selectedRow(inComponent: 0)].id {
                                        var location: [Double] = [0, 0]
                                        if let l = self.pickedImageLocation {
                                            location[0] = Double(l.latitude)
                                            location[1] = Double(l.longitude)
                                        }
                                        let obsv = NNObservation(project: projectId, site: currentUser.affiliation, observer: currentUser.id, id: "", data: data, location: location, created: 0, updated: 0, status: "", likes: [String: Bool]())
                                        DataService.ds.AddObservation(observation: obsv, completion: { success in
                                            if success {
                                                let alert = UIAlertController(title: ADD_OBSV_SUCCESS_TITLE, message: ADD_OBSV_SUCCESS_MESSAGE, preferredStyle: .alert)
                                                alert.addAction(UIAlertAction(title: ADD_OBSV_SUCCESS_BUTTON_TEXT, style: .default, handler: { val in
                                                    self.dismiss(animated: true) {}
                                                }))
                                                self.present(alert, animated: true, completion: nil)
                                            }
                                        })
                                    }
                                }
                            }
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
