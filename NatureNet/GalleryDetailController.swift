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
    
    @IBOutlet weak var commentLabel: UILabel!
    var observationObj: NNObservation?
    
    var pages = 0
    var maxNV = 0
    var maxNB = false

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
    
    override func viewWillAppear(_ animated: Bool) {
        if let obsv = self.observationObj {
            if let user = DataService.ds.GetUser(by: obsv.observer) {
                self.username.text = user.displayName
                self.affiliation.text = DataService.ds.GetSiteName(with: user.affiliation)
                
                self.profileImage.image = ICON_DEFAULT_USER_AVATAR
                // requesting the avatar icon
                MediaManager.md.getOrDownloadIcon(requesterId: "GalleryDetailController", urlString: user.avatarUrl, completion: { img, err in
                    if let i = img {
                        DispatchQueue.main.async {
                            self.profileImage.image = i
                        }
                    }
                })
            }
            self.postDate.text = UtilityFunctions.convertTimestampToDateString(date: obsv.updatedAt)
            self.descriptionText.text = obsv.observationText
            if DataService.ds.GetCommentsOnObservation(with: obsv.id).count == 0 {
                self.commentLabel.text = NO_COMMENTS_TEXT
            }
            self.numLikes.text = "\(obsv.Likes.count)"
            self.numDislikes.text = "\(obsv.Dislikes.count)"
            
            // load the observation image
            self.observation.image = IMAGE_DEFAULT_OBSERVATION
            // requesting the icon
            MediaManager.md.getOrDownloadImage(requesterId: "GalleryDetailController.img", urlString: obsv.observationImageUrl, completion: { img, err in
                if let i = img {
                    DispatchQueue.main.async {
                        self.observation.image = i
                    }
                }
            })
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        galleryDetailsTable.FixHeaderLayout()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let n = COMMENT_LIST_INIT_COUNT + pages * COMMENT_LIST_LOAD_MORE_COUNT
        var total = 0
        if let obsv = self.observationObj {
            total = DataService.ds.GetCommentsOnObservation(with: obsv.id).count
        }
        var ret_val = 0
        if n < total {
            maxNV = n
            maxNB = true
            ret_val = n + 1
        } else {
            maxNV = total
            maxNB = false
            ret_val = total
        }
        return ret_val
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if maxNB && maxNV == indexPath.row {
            return CGFloat(SHOW_MORE_CELL_HEIGHT)
        }
        return CGFloat(COMMENT_CELL_ESTIMATED_HEIGHT)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // the case which we should dequeue a ShowMoreCell
        if maxNB && maxNV == indexPath.row {
            if let cell = tableView.dequeueReusableCell(withIdentifier: SHOW_MORE_CELL_ID) as? ShowMoreCell {
                cell.configureCell()
                return cell
            } else {
                return ShowMoreCell()
            }
        }
        
        // the case which we should dequeue a regular cell (CommentCell)
        if let cell = tableView.dequeueReusableCell(withIdentifier: COMMENT_CELL_ID) as? CommentCell {
            if let obsv = self.observationObj {
                let listComments = DataService.ds.GetCommentsOnObservation(with: obsv.id)
                if indexPath.row < listComments.count {
                    let comment = listComments[indexPath.row]
                    if let user = DataService.ds.GetUser(by: comment.commenter) {
                        cell.configureCell(name: user.displayName, comment: comment.comment)
                    }
                }
            }
            return cell
        } else {
            return CommentCell()
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
    
    // this fixes the height of the comments text box under the screen. (the box that user should input comment text)
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
            let activityVC = UIActivityViewController(activityItems: [self.descriptionText.text ?? "", self.observation.image ?? ""], applicationActivities: nil)
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
    
    // send the observation image to the ImageViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            if id == SEGUE_DETAILS {
                if let dest = segue.destination as? ImageViewController {
                    dest.observationImageUrl = self.observationObj?.observationImageUrl
                }
            }
        }
    }
    
    @IBAction func showMoreTapped(_ sender: Any) {
        self.pages = self.pages + 1
        galleryDetailsTable.reloadData()
    }
    
}
