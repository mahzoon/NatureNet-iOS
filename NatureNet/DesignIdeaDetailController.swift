//
//  DesignIdeaDetailController.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/17/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import UIKit

class DesignIdeaDetailController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {

    @IBOutlet weak var designIdeaDetailsTable: UITableView!
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var postDate: UILabel!
    @IBOutlet weak var affiliation: UILabel!
    @IBOutlet weak var ideaText: UILabel!
    @IBOutlet weak var numLikes: UILabel!
    @IBOutlet weak var numDislikes: UILabel!
    @IBOutlet weak var status: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    
    @IBOutlet weak var commentText: RoundedTextView!
    @IBOutlet weak var commentContainer: UIView!
    @IBOutlet weak var commentTextHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var keyboardViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var commentLabel: UILabel!
    var designIdea: NNDesignIdea?
    
    var pages = 0
    var maxNV = 0
    var maxNB = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        designIdeaDetailsTable.delegate = self
        designIdeaDetailsTable.dataSource = self
        commentText.delegate = self
        
        keyboardViewHeightConstraint.constant = 0
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        
        FixTextViewHeight()
        
        hideKeyboardWhenTappedOutside()
        
        commentText.text = COMMENT_TEXTBOX_PLACEHOLDER
        commentText.textColor = UIColor.lightGray
        
        designIdeaDetailsTable.estimatedRowHeight = CGFloat(COMMENT_CELL_ESTIMATED_HEIGHT)
    }

    override func viewWillAppear(_ animated: Bool) {
        if let idea = self.designIdea {
            if let user = DataService.ds.GetUser(by: idea.submitter) {
                self.username.text = user.displayName
                self.affiliation.text = DataService.ds.GetSiteName(with: user.affiliation)
                
                self.profileImage.image = ICON_DEFAULT_USER_AVATAR
                // requesting the avatar icon
                MediaManager.md.getOrDownloadIcon(requesterId: "DesignIdeaDetailController", urlString: user.avatarUrl, completion: { img, err in
                    if let i = img {
                        DispatchQueue.main.async {
                            self.profileImage.image = i
                        }
                    }
                })
            }
            self.postDate.text = UtilityFunctions.convertTimestampToDateString(date: idea.updatedAt)
            self.ideaText.text = idea.content
            if DataService.ds.GetCommentsOnDesignIdea(with: idea.id).count == 0 {
                self.commentLabel.text = NO_COMMENTS_TEXT
            }
            self.numLikes.text = "\(idea.Likes.count)"
            self.numDislikes.text = "\(idea.Dislikes.count)"
            
            // load the status image
            self.status.image = nil
            if idea.status.lowercased() == DESIGN_IDEA_STATUS_DONE {
                self.status.image = ICON_DESIGN_IDEA_STATUS_DONE
            }
            if idea.status.lowercased() == DESIGN_IDEA_STATUS_DISCUSSING || idea.status.lowercased() == DESIGN_IDEA_STATUS_TO_DO {
                self.status.image = ICON_DESIGN_IDEA_STATUS_DISCUSSING
            }
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        designIdeaDetailsTable.FixHeaderLayout()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let n = COMMENT_LIST_INIT_COUNT + pages * COMMENT_LIST_LOAD_MORE_COUNT
        var total = 0
        if let idea = self.designIdea {
            total = DataService.ds.GetCommentsOnDesignIdea(with: idea.id).count
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
        //return CGFloat(COMMENT_CELL_ESTIMATED_HEIGHT)
        if let cell = designIdeaDetailsTable.dequeueReusableCell(withIdentifier: COMMENT_CELL_ID) {
            let c = cell as! CommentCell
            if let idea = self.designIdea {
                let listComments = DataService.ds.GetCommentsOnDesignIdea(with: idea.id)
                if indexPath.row < listComments.count {
                    let comment = listComments[indexPath.row]
                    if let user = DataService.ds.GetUser(by: comment.commenter) {
                        c.configureCell(name: user.displayName, comment: comment.comment)
                        return c.getSize() + CGFloat(5.0)
                    }
                }
            }
        }
        return UITableViewAutomaticDimension
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
            if let idea = self.designIdea {
                let listComments = DataService.ds.GetCommentsOnDesignIdea(with: idea.id)
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
    
    func FixTextViewHeight() {
        self.commentTextHeightConstraint.constant = self.commentText.GetFixTextRowHight(maxHeight: CGFloat(COMMENT_TEXTBOX_MAX_HEIGHT))
    }
    
    @IBAction func showMoreTapped(_ sender: Any) {
        self.pages = self.pages + 1
        designIdeaDetailsTable.reloadData()
    }
    
    @IBAction func likeTapped(_ sender: Any) {
        if !DataService.ds.LoggedIn() {
            UtilityFunctions.showAuthenticationRequiredMessage(theView: self, completion: {
                self.performSegue(withIdentifier: SEGUE_SIGNIN, sender: nil)
            })
        } else {
            if let idea = designIdea {
                DataService.ds.ToggleLikeOrDislikeOnDesignIdea(like: true, designIdeaId: idea.id, completion: { success in
                    if (success) { self.updateLikeAndDislikeButtonImages() }
                })
            }
        }
    }
    
    @IBAction func dislikeTapped(_ sender: Any) {
        if !DataService.ds.LoggedIn() {
            UtilityFunctions.showAuthenticationRequiredMessage(theView: self, completion: {
                self.performSegue(withIdentifier: SEGUE_SIGNIN, sender: nil)
            })
        } else {
            if let idea = designIdea {
                DataService.ds.ToggleLikeOrDislikeOnDesignIdea(like: false, designIdeaId: idea.id, completion: { success in
                    if (success) { self.updateLikeAndDislikeButtonImages() }
                })
            }
        }
    }
    
    private func updateLikeAndDislikeButtonImages() {
        // update designIdea
        if let idea = self.designIdea {
            self.designIdea = DataService.ds.GetDesignIdea(with: idea.id)
        }
        if let idea = self.designIdea {
            // update like/dislike labels
            self.numLikes.text = "\(idea.Likes.count)"
            self.numDislikes.text = "\(idea.Dislikes.count)"
            // update buttons
            if let currentUserId = DataService.ds.GetCurrentUserId() {
                if let like = idea.likes[currentUserId] {
                    if like {
                        likeButton.setImage(ICON_LIKE_GREEN, for: .normal)
                        dislikeButton.setImage(ICON_DISLIKE_GRAY, for: .normal)
                    } else {
                        likeButton.setImage(ICON_LIKE_GRAY, for: .normal)
                        dislikeButton.setImage(ICON_DISLIKE_RED, for: .normal)
                    }
                } else {
                    likeButton.setImage(ICON_LIKE_GRAY, for: .normal)
                    dislikeButton.setImage(ICON_DISLIKE_GRAY, for: .normal)
                }
            } else {
                likeButton.setImage(ICON_LIKE_GRAY, for: .normal)
                dislikeButton.setImage(ICON_DISLIKE_GRAY, for: .normal)
            }
        }
    }
    
    @IBAction func commentSendTapped(_ sender: Any) {
        if !DataService.ds.LoggedIn() {
            UtilityFunctions.showAuthenticationRequiredMessage(theView: self, completion: {
                self.performSegue(withIdentifier: SEGUE_SIGNIN, sender: nil)
            })
        } else {
            if commentText.text == "" {
                UtilityFunctions.showErrorMessage(theView: self, title: COMMENT_EMPTY_ERROR_TITLE,
                                                  message: COMMENT_EMPTY_ERROR_MESSAGE,
                                                  buttonText: COMMENT_EMPTY_ERROR_BUTTON_TEXT)
            } else {
                if let idea = designIdea {
                    DataService.ds.WriteCommentOn(context: DB_DESIGNIDEAS_PATH,
                                                  comment: commentText.text,
                                                  contributionId: idea.id)
                    self.designIdeaDetailsTable.reloadData()
                }
            }
        }
    }
}
