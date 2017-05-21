//
//  AddObservationController.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/17/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class AddObservationController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate,
UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var observationTableView: UITableView!
    
    @IBOutlet weak var observationImageButton: UIButton!
    @IBOutlet weak var observationImage: UIImageView!
    
    @IBOutlet weak var descriptionText: UITextField!
    @IBOutlet weak var locationText: UITextField!
    
    var items = ["Project 1", "Project 2", "Project 3", "Project 4"]
    
    @IBOutlet weak var projectPicker: UIPickerView!
    
    var imagePicker: UIImagePickerController!
    var pickedImage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        projectPicker.delegate = self
        projectPicker.dataSource = self
        projectPicker.selectedRow(inComponent: 0)
        
        descriptionText.delegate = self
        locationText.delegate = self
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return items[row]
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePicker.dismiss(animated: true, completion: {
                self.observationImage.image = pickedImage
                self.pickedImage = true
            })
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func observationImageButtonTapped(_ sender: Any) {
        //present(imagePicker, animated: true, completion: nil)
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
        self.dismiss(animated: true) {}
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true) {}
    }
}
