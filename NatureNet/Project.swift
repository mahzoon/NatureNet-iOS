//
//  Project.swift
//  NatureNet
//
//  Created by Mohammad Javad Mahzoon on 5/21/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import Foundation

// Modeling the "activities" key from the Firebase database.
// Even though the corresponding model in Firebase is called activities, here in NatureNet we call them Projects
class NNProject {
    // describes what is the project about
    var descriptionText: String!
    // url to the icon for the project
    var iconUrl: String!
    // id of the project
    var id: String!
    // the time of the latest contribution made for this project in "timestamp" format
    var latestContribution: String!
    // the name of the project
    var name: String!
    // sites that this project belongs to
    var sites: [String]!
    // timestamp of the creation time
    var createdAt: String!
    // timestamp of the updated time
    var updatedAt: String!
    
    // the initializer. Note that sites is a dictionary of siteId -> true
    init(desc: String, icon: String, id: String, latestContrib: String, name: String, sites: [String: AnyObject], created: String, updated: String) {
        self.descriptionText = desc
        self.iconUrl = icon
        self.id = id
        self.latestContribution = latestContrib
        self.name = name
        self.sites = []
        // to extract sites we need only the key of the passed dictionary
        for (k, _) in sites {
            self.sites.append(k)
        }
        self.createdAt = created
        self.updatedAt = updated
    }
    
    static func createProjectFromFirebase(with snapshot: [String: AnyObject]) -> NNProject {
        // setting default values
        var activityName = ""
        var activityId = ""
        var activityDesc = ""
        var activityIcon = ""
        var activityLatest = ""
        var activitySites: [String:AnyObject] = ["": "" as AnyObject]
        var activityCreated = ""
        var activityUpdated = ""
        // setting values when possible
        if let tmp = snapshot["name"], (tmp as? String) != nil {
            activityName = tmp as! String
        }
        if let tmp = snapshot["id"], (tmp as? String) != nil {
            activityId = tmp as! String
        }
        if let tmp = snapshot["description"], (tmp as? String) != nil {
            activityDesc = tmp as! String
        }
        if let tmp = snapshot["icon_url"], (tmp as? String) != nil {
            activityIcon = tmp as! String
        }
        if let tmp = snapshot["latest_contribution"], (tmp as? String) != nil {
            activityLatest = tmp as! String
        }
        if let tmp = snapshot["sites"], (tmp as? [String:AnyObject]) != nil {
            activitySites = tmp as! [String:AnyObject]
        }
        if let tmp = snapshot["created_at"], (tmp as? String) != nil {
            activityCreated = tmp as! String
        }
        if let tmp = snapshot["updated_at"], (tmp as? String) != nil {
            activityUpdated = tmp as! String
        }
        let project = NNProject(desc: activityDesc, icon: activityIcon, id: activityId, latestContrib: activityLatest, name: activityName, sites: activitySites, created: activityCreated, updated: activityUpdated)
        return project
    }
    
}
