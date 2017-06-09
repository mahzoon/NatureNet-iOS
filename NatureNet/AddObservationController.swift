//
//  AddObservationController.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/17/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Photos
import AVFoundation

class AddObservationController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate,
UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {

    
    @IBOutlet weak var observationTableView: UITableView!
    
    @IBOutlet weak var observationImageButton: UIButton!
    @IBOutlet weak var observationImage: UIImageView!
    
    @IBOutlet weak var descriptionText: UITextField!
    @IBOutlet weak var locationText: UITextField!
    
    @IBOutlet weak var projectPicker: UIPickerView!
    @IBOutlet weak var submitButton: UIBarButtonItem!
    
    var imagePicker: UIImagePickerController!
    var pickedImage = false
    
    var pickedImageLocation: CLLocationCoordinate2D?
    
    var siteList = [String]()
    
    // activity indicator for upload
    var activityIndicator = UIActivityIndicatorView()
    
    // to capture user's location when taking picture
    let locationManager = CLLocationManager()
    
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

        siteList = DataService.ds.GetSiteIds()
        
        activityIndicator.frame = self.view.frame
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.layer.backgroundColor = UIColor(white: 0, alpha: ACTIVITY_INDICATOR_OPACITY).cgColor
        let activityIndicatorLabel = UILabel(frame: CGRect(x: 0, y: 0, width: activityIndicator.frame.width, height: ACTIVITY_INDICATOR_TEXT_HEIGHT))
        activityIndicatorLabel.text = ACTIVITY_INDICATOR_TEXT_UPLOADING
        activityIndicatorLabel.textColor = UIColor.white
        activityIndicatorLabel.textAlignment = .center
        activityIndicatorLabel.center = CGPoint(x: activityIndicator.center.x, y: activityIndicator.center.y + ACTIVITY_INDICATOR_TEXT_HEIGHT)
        activityIndicator.addSubview(activityIndicatorLabel)
        self.view.addSubview(activityIndicator)
        
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        
        self.observationImageButtonTapped("")
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
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return siteList.count
        }
        if component == 1 {
            //return projectList.count + 1
            let selectedIndex = self.projectPicker.selectedRow(inComponent: 0)
            if selectedIndex >= 0 && selectedIndex < self.siteList.count {
                // the first item would be "select a project"
                return DataService.ds.GetProjects(in: self.siteList[selectedIndex]).count + 1
            }
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            self.projectPicker.reloadComponent(1)
            self.projectPicker.selectRow(0, inComponent: 1, animated: true)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if component == 0 {
            return self.projectPicker.frame.size.width / 3
        }
        if component == 1 {
            return 2 * (self.projectPicker.frame.size.width / 3)
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var label: UILabel
        if let view = view as? UILabel { label = view }
        else { label = UILabel() }
        
        label.text = getTitleForPickerView(row: row, component: component)
        label.font = UIFont.systemFont(ofSize: ADD_OBSV_PROJECT_PICKER_FONT_SIZE)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        
        return label
        
    }
    
    func getTitleForPickerView(row: Int, component: Int) -> String? {
        if component == 0 {
            return DataService.ds.GetSiteName(with: self.siteList[row])
        }
        if component == 1 {
            if row == 0 {
                return PICKER_NO_SELECTION
            }
            let selectedIndex = self.projectPicker.selectedRow(inComponent: 0)
            if selectedIndex >= 0 && selectedIndex < self.siteList.count {
                let projectList = DataService.ds.GetProjects(in: self.siteList[selectedIndex])
                if row - 1 < projectList.count {
                    return projectList[row - 1].name
                }
            }
        }
        return nil
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if picker.sourceType == UIImagePickerControllerSourceType.camera {
                self.locationManager.stopUpdatingLocation()
                MediaManager.md.saveImageToPhotosLib(img: pickedImage, completion: { success, error, loc in
                    if !success {
                        let ac = UIAlertController(title: SAVE_OBSV_ERROR_MESSAGE, message: error, preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: SAVE_OBSV_ERROR_BUTTON_TEXT, style: .default))
                        self.present(ac, animated: true)
                    } else {
                        //self.pickedImageLocation = loc
                        DispatchQueue.main.async {
                            self.observationImage.image = pickedImage
                            self.pickedImage = true
                        }
                    }
                })
            }
            if picker.sourceType == UIImagePickerControllerSourceType.photoLibrary {
                imagePicker.dismiss(animated: true, completion: {
                    DispatchQueue.main.async {
                        self.observationImage.image = pickedImage
                        self.pickedImage = true
                    }
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
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) &&
                (PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized ||
                 PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.notDetermined) {
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
                self.present(self.imagePicker, animated: true, completion: nil)
            } else {
                UtilityFunctions.showErrorMessage(theView: self, title: ADD_OBSV_IMAGE_OPTIONS_ERR_LIB_TITLE, message: ADD_OBSV_IMAGE_OPTIONS_ERR_LIB_MSG, buttonText: ADD_OBSV_IMAGE_OPTIONS_ERR_LIB_BTN_TXT)
            }
        }))
        alert.addAction(UIAlertAction(title: ADD_OBSV_IMAGE_OPTIONS_TAKE_NEW, style: .default, handler: { (action: UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) &&
                (AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == AVAuthorizationStatus.authorized ||
                    AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == AVAuthorizationStatus.notDetermined) {
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
                self.locationManager.startUpdatingLocation()
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
            } else if projectPicker.selectedRow(inComponent: 1) == 0 {
                UtilityFunctions.showErrorMessage(theView: self, title: OBSERVATION_NO_PROJECT_ERROR_TITLE,
                                                  message: OBSERVATION_NO_PROJECT_ERROR_MESSAGE,
                                                  buttonText: OBSERVATION_NO_PROJECT_ERROR_BUTTON_TEXT)
            } else {
                view.endEditing(true)
                
                var data = ["text": self.descriptionText.text ?? "", "image": ""]
                // upload image to Cloudinary
                if let img = self.observationImage.image {
                    // start activity spinner
                    self.activityIndicator.startAnimating()
                    self.submitButton.isEnabled = false
                    //UIApplication.shared.beginIgnoringInteractionEvents()
                    MediaManager.md.uploadImage(image: img, progressHandler: { (Progress) in
                        // progress handler
                    }, completionHandler: { result, error in
                        // stop activity spinner
                        self.activityIndicator.stopAnimating()
                        self.submitButton.isEnabled = true
                        //UIApplication.shared.endIgnoringInteractionEvents()
                        if let e = error {
                            if e.localizedDescription == "cancelled" {
                                UtilityFunctions.showErrorMessage(theView: self, title: ADD_OBSV_UPLOAD_CANCELED_TITLE, message: ADD_OBSV_UPLOAD_CANCELED_MESSAGE, buttonText: ADD_OBSV_UPLOAD_CANCELED_BUTTON_TEXT)
                            } else {
                                // had with error
                                UtilityFunctions.showErrorMessage(theView: self, title: ADD_OBSV_UPLOAD_FAILED_TITLE, message: ADD_OBSV_UPLOAD_FAILED_MESSAGE + e.localizedDescription, buttonText: ADD_OBSV_UPLOAD_FAILED_BUTTON_TEXT)
                            }
                        } else {
                            // completed successfully
                            if let r = result {
                                data["image"] = r.secureUrl
                                // send to Firebase
                                if let currentUser = DataService.ds.GetCurrentUser() {
                                    let selectedSiteIndex = self.projectPicker.selectedRow(inComponent: 0)
                                    let projectList = DataService.ds.GetProjects(in: self.siteList[selectedSiteIndex])
                                    if let projectId = projectList[self.projectPicker.selectedRow(inComponent: 1) - 1].id {
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
        if self.activityIndicator.isAnimating {
            MediaManager.md.cancelUploadImage()
        } else {
            self.dismiss(animated: true) {}
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.pickedImageLocation = locations[0].coordinate
    }
}
