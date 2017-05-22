//
//  User.swift
//  NatureNet
//
//  Created by Mohammad Javad Mahzoon on 5/21/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import Foundation

// Modeling the "user" key from the Firebase database.
class NNUser {
    // siteId of the user's affiliation
    var affiliation: String!
    // url to the avataro for the user
    var avatarUrl: String!
    // id of the user
    var id: String!
    // bio of the user
    var bio: String!
    // the time of the latest contribution made by this user in "timestamp" format
    var latestContribution: NSNumber!
    // the display name of the user
    var displayName: String!
    // groups that this user belongs to
    var groups: [String]!
    // timestamp of the creation time
    var createdAt: NSNumber!
    // timestamp of the updated time
    var updatedAt: NSNumber!
    
    // the initializer. Note that groups is a dictionary of groupId -> true
    init(affiliation: String, icon: String, id: String, bio: String, latestContrib: NSNumber, name: String, groups: [String: AnyObject], created: NSNumber, updated: NSNumber) {
        self.affiliation = affiliation
        self.avatarUrl = icon
        self.id = id
        self.bio = bio
        self.latestContribution = latestContrib
        self.displayName = name
        self.groups = []
        // to extract groups we need only the key of the passed dictionary
        for (k, _) in groups {
            self.groups.append(k)
        }
        self.createdAt = created
        self.updatedAt = updated
    }
    
    static func createUserFromFirebase(with snapshot: [String: AnyObject]) -> NNUser {
        // setting default values
        var userName = ""
        var userId = ""
        var userBio = ""
        var userAffil = ""
        var userIcon = ""
        var userLatest: NSNumber = 0
        var userGroups: [String:AnyObject] = ["": "" as AnyObject]
        var userCreated: NSNumber = 0
        var userUpdated: NSNumber = 0
        // setting values when possible
        if let tmp = snapshot["display_name"], (tmp as? String) != nil {
            userName = tmp as! String
        }
        if let tmp = snapshot["id"], (tmp as? String) != nil {
            userId = tmp as! String
        }
        if let tmp = snapshot["bio"], (tmp as? String) != nil {
            userBio = tmp as! String
        }
        if let tmp = snapshot["affiliation"], (tmp as? String) != nil {
            userAffil = tmp as! String
        }
        if let tmp = snapshot["avatar"], (tmp as? String) != nil {
            userIcon = tmp as! String
        }
        if let tmp = snapshot["latest_contribution"], (tmp as? NSNumber) != nil {
            userLatest = tmp as! NSNumber
        }
        if let tmp = snapshot["groups"], (tmp as? [String:AnyObject]) != nil {
            userGroups = tmp as! [String:AnyObject]
        }
        if let tmp = snapshot["created_at"], (tmp as? NSNumber) != nil {
            userCreated = tmp as! NSNumber
        }
        if let tmp = snapshot["updated_at"], (tmp as? NSNumber) != nil {
            userUpdated = tmp as! NSNumber
        }
        let user = NNUser(affiliation: userAffil, icon: userIcon, id: userId, bio: userBio, latestContrib: userLatest, name: userName, groups: userGroups, created: userCreated, updated: userUpdated)
        return user
    }
}
