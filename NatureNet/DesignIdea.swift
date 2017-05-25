//
//  DesignIdea.swift
//  NatureNet
//
//  Created by Mohammad Javad Mahzoon on 5/22/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import Foundation

class NNDesignIdea {
    // submitter is the user id who made this idea
    var submitter: String!
    // id of the idea
    var id: String!
    // content is a text
    var content: String!
    // timestamp of the creation time
    var createdAt: NSNumber!
    // timestamp of the updated time
    var updatedAt: NSNumber!
    // status
    var status: String!
    // type
    var type: String!
    // group
    var group: String!
    // likes is a dictionary of users who liked/disliked this idea. If the value of the dictionary is true the user liked this else disliked it. So, the key is user id and the value is true(like) or false(dislike).
    var likes: [String: Bool]
    // return likes
    var Likes: [String: Bool] {
        let l = likes.filter({ (_: String, value: Bool) -> Bool in
            return value
        })
        var ret_val = [String:Bool]()
        for result in l {
            ret_val[result.0] = result.1
        }
        return ret_val
    }
    // return dislikes
    var Dislikes: [String: Bool] {
        let l = likes.filter({ (_: String, value: Bool) -> Bool in
            return !value
        })
        var ret_val = [String:Bool]()
        for result in l {
            ret_val[result.0] = result.1
        }
        return ret_val
    }
    
    // the initializer.
    init(submitter: String, content: String, id: String, created: NSNumber, updated: NSNumber, status: String, type: String, group: String, likes: [String: Bool]) {
        self.submitter = submitter
        self.content = content
        self.id = id
        self.createdAt = created
        self.updatedAt = updated
        self.status = status
        self.type = type
        self.group = group
        self.likes = likes
    }
    
    func getDictionaryRepresentation() -> [String: AnyObject] {
        var retVal = [String: AnyObject]()
        retVal["created_at"] = self.createdAt
        retVal["updated_at"] = self.updatedAt
        retVal["id"] = self.id as AnyObject
        retVal["group"] = self.group as AnyObject
        retVal["type"] = self.type as AnyObject
        retVal["content"] = self.content as AnyObject
        retVal["submitter"] = self.submitter as AnyObject
        retVal["status"] = self.status as AnyObject
        retVal["source"] = DB_SOURCE as AnyObject
        return retVal
    }

    
    static func createDesignIdeaFromFirebase(with snapshot: [String: AnyObject]) -> NNDesignIdea {
        // setting default values
        var ideaSubmitter = ""
        var ideaId = ""
        var ideaContent = ""
        var ideaGroup = ""
        var ideaType = ""
        var ideaCreated: NSNumber = 0
        var ideaUpdated: NSNumber = 0
        var ideaStatus = ""
        var ideaLikes = [String: Bool]()
        // setting values when possible
        if let tmp = snapshot["submitter"], (tmp as? String) != nil {
            ideaSubmitter = tmp as! String
        }
        if let tmp = snapshot["id"], (tmp as? String) != nil {
            ideaId = tmp as! String
        }
        if let tmp = snapshot["content"], (tmp as? String) != nil {
            ideaContent = tmp as! String
        }
        if let tmp = snapshot["group"], (tmp as? String) != nil {
            ideaGroup = tmp as! String
        }
        if let tmp = snapshot["type"], (tmp as? String) != nil {
            ideaType = tmp as! String
        }
        if let tmp = snapshot["created_at"], (tmp as? NSNumber) != nil {
            ideaCreated = tmp as! NSNumber
        }
        if let tmp = snapshot["updated_at"], (tmp as? NSNumber) != nil {
            ideaUpdated = tmp as! NSNumber
        }
        if let tmp = snapshot["status"], (tmp as? String) != nil {
            ideaStatus = tmp as! String
        }
        if let tmp = snapshot["likes"], (tmp as? [String: Bool]) != nil {
            ideaLikes = tmp as! [String: Bool]
        }
        let idea = NNDesignIdea(submitter: ideaSubmitter, content: ideaContent, id: ideaId, created: ideaCreated, updated: ideaUpdated, status: ideaStatus, type: ideaType, group: ideaGroup, likes: ideaLikes)
        return idea
    }

}
