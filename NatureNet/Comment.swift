//
//  Comment.swift
//  NatureNet
//
//  Created by Mohammad Javad Mahzoon on 5/22/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import Foundation

// Modeling the "comments" key from the Firebase database.
class NNComment {
    // the comment text
    var comment: String!
    // the user who commented
    var commenter: String!
    // id of the comment
    var id: String!
    // if comment is for an observation or design idea. current possible values: "observations", "ideas"
    var context: String!
    // parent is the id of the contribution which this comment is on. Either an observation or a design idea.
    var parentContribution: String!
    // timestamp of the creation time
    var createdAt: NSNumber!
    // timestamp of the updated time
    var updatedAt: NSNumber!
    // status
    var status: String!
    
    var isCommentOnObservation: Bool {
        return context == "observations"
    }
    
    var isCommentOnDesignIdea: Bool {
        return context == "ideas"
    }
    
    // the initializer. Note that sites is a dictionary of siteId -> true
    init(comment: String, commenter: String, id: String, context: String, parentContrib: String, status: String, created: NSNumber, updated: NSNumber) {
        self.comment = comment
        self.commenter = commenter
        self.id = id
        self.context = context
        self.parentContribution = parentContrib
        self.status = status
        self.createdAt = created
        self.updatedAt = updated
    }
    
    func getDictionaryRepresentation() -> [String: AnyObject] {
        var retVal = [String: AnyObject]()
        retVal["created_at"] = self.createdAt
        retVal["updated_at"] = self.updatedAt
        retVal["id"] = self.id as AnyObject
        retVal["parent"] = self.parentContribution as AnyObject
        retVal["context"] = self.context as AnyObject
        retVal["comment"] = self.comment as AnyObject
        retVal["commenter"] = self.commenter as AnyObject
        retVal["status"] = self.status as AnyObject
        retVal["source"] = DB_SOURCE as AnyObject
        return retVal
    }
    
    static func createCommentFromFirebase(with snapshot: [String: AnyObject]) -> NNComment {
        // setting default values
        var commentText = ""
        var commentId = ""
        var commentCommenter = ""
        var commentContext = ""
        var commentParent = ""
        var commentStatus = ""
        var commentCreated: NSNumber = 0
        var commentUpdated: NSNumber = 0
        // setting values when possible
        if let tmp = snapshot["comment"], (tmp as? String) != nil {
            commentText = tmp as! String
        }
        if let tmp = snapshot["id"], (tmp as? String) != nil {
            commentId = tmp as! String
        }
        if let tmp = snapshot["commenter"], (tmp as? String) != nil {
            commentCommenter = tmp as! String
        }
        if let tmp = snapshot["context"], (tmp as? String) != nil {
            commentContext = tmp as! String
        }
        if let tmp = snapshot["parent"], (tmp as? String) != nil {
            commentParent = tmp as! String
        }
        if let tmp = snapshot["status"], (tmp as? String) != nil {
            commentStatus = tmp as! String
        }
        if let tmp = snapshot["created_at"], (tmp as? NSNumber) != nil {
            commentCreated = tmp as! NSNumber
        }
        if let tmp = snapshot["updated_at"], (tmp as? NSNumber) != nil {
            commentUpdated = tmp as! NSNumber
        }
        let comment = NNComment(comment: commentText, commenter: commentCommenter, id: commentId, context: commentContext, parentContrib: commentParent, status: commentStatus, created: commentCreated, updated: commentUpdated)
        return comment
    }
}
