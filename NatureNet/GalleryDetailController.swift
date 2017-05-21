//
//  GalleryDetailController.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/17/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class GalleryDetailController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {

    @IBOutlet weak var galleryDetailsTable: UITableView!
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var postDate: UILabel!
    @IBOutlet weak var affiliation: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var numLikes: UILabel!
    @IBOutlet weak var numDislikes: UILabel!
    @IBOutlet weak var observation: UIImageView!
    
    @IBOutlet weak var commentText: RoundedTextView!
    @IBOutlet weak var commentContainer: UIView!
    @IBOutlet weak var commentTextHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var keyboardViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        galleryDetailsTable.delegate = self
        galleryDetailsTable.dataSource = self
        commentText.delegate = self
        
        keyboardViewHeightConstraint.constant = 0
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        
        FixTextViewHeight()
        
        hideKeyboardWhenTappedOutside()
        
        commentText.text = COMMENT_TEXTBOX_PLACEHOLDER
        commentText.textColor = UIColor.lightGray
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        galleryDetailsTable.FixHeaderLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(COMMENT_CELL_ESTIMATED_HEIGHT)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as? CommentCell {
            cell.configureCell(name: "Username", comment: "comment text...")
            return cell
        } else {
            return UITableViewCell()
        }
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        FixTextViewHeight()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        self.commentText.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = COMMENT_TEXTBOX_PLACEHOLDER
            textView.textColor = UIColor.lightGray
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.1, delay: 0.1, animations: {
                // move comment text up
                if let bottomTabHight = self.tabBarController?.tabBar.frame.size.height {
                    self.keyboardViewHeightConstraint.constant = keyboardSize.height - bottomTabHight
                } else {
                    self.keyboardViewHeightConstraint.constant = keyboardSize.height
                }
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.1, delay: 0.1, animations: {
            // move comment text down
            self.keyboardViewHeightConstraint.constant = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func FixTextViewHeight() {
        self.commentTextHeightConstraint.constant = self.commentText.GetFixTextRowHight(maxHeight: CGFloat(COMMENT_TEXTBOX_MAX_HEIGHT))
    }
    
    @IBAction func observationHoldGesture(_ sender: UILongPressGestureRecognizer) {
        let alert = UIAlertController(title: SAVE_OBSV_ALERT_TITLE, message: SAVE_OBSV_ALERT_MESSAGE, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: SAVE_OBSV_ALERT_OPTION_CANCEL, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: SAVE_OBSV_ALERT_OPTION_SAVE_PHOTO, style: .default, handler: { (action: UIAlertAction) in
            if let img = self.observation.image {
                UIImageWriteToSavedPhotosAlbum(img, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }))
        alert.addAction(UIAlertAction(title: SAVE_OBSV_ALERT_OPTION_SHARE, style: .default, handler: { (action: UIAlertAction) in
            // GET CONTENTS OF THE OBSERVATION
            let activityVC = UIActivityViewController(activityItems: ["Observation Content", self.observation.image ?? ""], applicationActivities: nil)
            self.present(activityVC, animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: SAVE_OBSV_ERROR_MESSAGE, message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: SAVE_OBSV_ERROR_BUTTON_TEXT, style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: SAVE_OBSV_SUCCESS_TITLE, message: SAVE_OBSV_SUCCESS_MESSAGE, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: SAVE_OBSV_SUCCESS_BUTTON_TEXT, style: .default))
            present(ac, animated: true)
        }
    }
}
